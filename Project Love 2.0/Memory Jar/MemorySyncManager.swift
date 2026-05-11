import Foundation
import UIKit
import Supabase

/// Manages the partner-side of the photo sync loop:
///
/// 1. Listens for new memory rows via Supabase Realtime.
/// 2. Downloads and locally saves the image from Supabase Storage.
/// 3. Marks `is_synced = true` in the DB so the uploader knows to clean up.
/// 4. Listens for `is_synced` updates so the uploader's side deletes the file
///    from Supabase Storage (keeping the bucket near-empty at all times).
///
/// Call `MemorySyncManager.shared.start(relationshipId:currentUserId:)` once
/// the relationship ID is known (e.g. right after login / pairing).
final class MemorySyncManager {

    // MARK: Singleton
    static let shared = MemorySyncManager()
    private init() {}

    // MARK: State
    private let supabase              = SupabaseManager.shared.client
    private var channel: RealtimeChannelV2?
    private var currentUserId: UUID?
    private var currentRelationshipId: UUID?   // guards against repeated re-subscription

    // MARK: - Lifecycle

    /// Starts listening for memory changes for this couple.
    /// If already subscribed to the SAME relationship, this is a no-op —
    /// the live channel is preserved and no events are missed.
    func start(relationshipId: UUID, currentUserId: UUID) {
        // Already subscribed to this relationship — do NOT tear down and rebuild
        if currentRelationshipId == relationshipId { return }
        currentRelationshipId = relationshipId
        self.currentUserId    = currentUserId
        Task { await subscribe(relationshipId: relationshipId) }
    }

    func stop() {
        currentRelationshipId = nil
        guard let ch = channel else { return }
        Task { await supabase.removeChannel(ch); channel = nil }
    }


    private func subscribe(relationshipId: UUID) async {
        if let existing = channel { await supabase.removeChannel(existing) }

        
        let ch = supabase.channel("memory_sync_\(relationshipId.uuidString)")
        self.channel = ch

        let changesStream = ch.postgresChange(
            AnyAction.self,
            schema: "public",
            table:  "memories",
            filter: "relationship_id=eq.\(relationshipId.uuidString)"
        )
        await ch.subscribe()
        print("[ MemoryJar] Realtime channel subscribed")

        Task {
            for await change in changesStream {
                switch change {
                case .insert(let action): await handleInsert(record: action.record)
                case .update(let action): await handleUpdate(record: action.record)
                case .delete(let action): await handleDelete(record: action.oldRecord)
                default: break
                }
            }
        }
    }


    private func handleInsert(record: [String: AnyJSON]) async {
    

        // Use the proven encode→decode path to extract fields from the Realtime payload
        guard
            let jsonData = try? JSONEncoder().encode(record),
            let item     = try? JSONDecoder().decode(MemoryModel.self, from: jsonData)
        else {
            
            return
        }

        guard item.user_id.uuidString != currentUserId?.uuidString else {
            
            return
        }

        print("[🫙 MemoryJar] Partner memory received: '\(item.title)' image=\(item.image_path)")

        // Already saved locally?
        if MemoryFileManager.loadImage(fileName: item.image_path) != nil {
            
            await buildAndNotify(item: item)
            return
        }

        do {
            
            let imageData = try await supabase.storage
                .from("memory-images")
                .download(path: item.image_path)

            MemoryFileManager.saveImage(data: imageData, fileName: item.image_path)
            

            try await supabase
                .from("memories")
                .update(["is_synced": true])
                .eq("memory_id", value: item.id.uuidString)
                .execute()
            

        } catch {
            
        }

        await buildAndNotify(item: item)
    }

    private func handleUpdate(record: [String: AnyJSON]) async {
        guard let uploaderIdStr = stringValue(record["user_id"]) else { return }

        // ── Case 1: My own row got is_synced = true → clean up Supabase Storage ──
        if uploaderIdStr == currentUserId?.uuidString {
            guard
                let imagePath = stringValue(record["image_path"]),
                boolValue(record["is_synced"]) == true
            else { return }

            do {
                try await supabase.storage
                    .from("memory-images")
                    .remove(paths: [imagePath])
            } catch {
                print("[MemorySyncManager] Failed to delete \(imagePath): \(error)")
            }
            return
        }

        // ── Case 2: Partner updated metadata (location / title / description / date) ──
        // Decode the full record so we can read all fields.
        guard
            let jsonData = try? JSONEncoder().encode(record),
            let item     = try? JSONDecoder().decode(MemoryModel.self, from: jsonData)
        else { return }

        let updatedDate = ISO8601DateFormatter().date(from: item.memory_date) ?? Date()

        await MainActor.run {
            // Update the existing entry in the shared data store in-place.
            if let idx = dataStore.savedMemories.firstIndex(where: { $0.id == item.id }) {
                dataStore.savedMemories[idx].location    = item.location ?? ""
                dataStore.savedMemories[idx].title       = item.title
                dataStore.savedMemories[idx].description = item.description ?? ""
                dataStore.savedMemories[idx].date        = updatedDate
            }

            // Broadcast so any open UI (MemoryJarVC, memoryPhotoVC, etc.) can refresh.
            NotificationCenter.default.post(
                name: NSNotification.Name("MemoryUpdated"),
                object: item.id        // UUID of the changed memory
            )
        }
    }

    private func handleDelete(record: [String: AnyJSON]) async {

        // Try decode pattern first; fall back to direct string extraction
        let memoryIdStr: String?
        let imagePath:   String?

        if let jsonData = try? JSONEncoder().encode(record),
           let item     = try? JSONDecoder().decode(MemoryModel.self, from: jsonData) {
            memoryIdStr = item.id.uuidString
            imagePath   = item.image_path
            
        } else {
            memoryIdStr = stringValue(record["memory_id"])
            imagePath   = stringValue(record["image_path"])
            
        }

        guard let idStr = memoryIdStr, let memoryId = UUID(uuidString: idStr) else {
            
            return
        }

        // Delete the photo from this device's local storage (if we have it)
        if let path = imagePath {
            MemoryFileManager.deleteImage(fileName: path)
            
        }

        // Notify the UI to remove the heart and card immediately
        
        await MainActor.run {
            NotificationCenter.default.post(
                name: NSNotification.Name("MemoryDeleted"),
                object: memoryId
            )
        }
    }

    private func buildAndNotify(item: MemoryModel) async {
        let date = ISO8601DateFormatter().date(from: item.memory_date) ?? Date()

        let newMemory = Memory(
            id:             item.id,
            date:           date,
            imageName:      item.image_path,
            location:       item.location ?? "",
            title:          item.title,
            description:    item.description ?? "",
            uiImage:        MemoryFileManager.loadImage(fileName: item.image_path),
            localImagePath: MemoryFileManager.localURL(for: item.image_path).path
        )

        // Post notification only — do NOT append to dataStore here.
        // handleNewMemory in MemoryJarViewController owns the append + all UI updates
        // (addHeart, refreshMemoryLaneUI, scroll). If we append here first, the guard
        // in handleNewMemory returns early and the UI never updates.
        await MainActor.run {
            NotificationCenter.default.post(
                name: NSNotification.Name("MemoryAdded"),
                object: newMemory
            )
        }
    }

    private func stringValue(_ json: AnyJSON?) -> String? {
        guard let json = json else { return nil }
        if case .string(let s) = json { return s }
        return nil
    }

    /// Handles both `.bool(true)` and `.string("true")` representations
    private func boolValue(_ json: AnyJSON?) -> Bool? {
        guard let json = json else { return nil }
        switch json {
        case .bool(let b):   return b
        case .string(let s): return s.lowercased() == "true"
        default:             return nil
        }
    }
}
