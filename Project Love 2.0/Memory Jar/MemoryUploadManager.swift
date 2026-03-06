import Foundation
import UIKit
import Supabase

final class MemoryUploadManager {
    static let shared = MemoryUploadManager()
    
    private let supabase = SupabaseManager.shared.client

    private init() {}
    
    /// Starts the upload process in a background task so it continues even if the app closes.
    func uploadMemory(
        userId: String,
        relationshipId: UUID,
        imageData: Data,
        title: String,
        description: String,
        isoDate: String
    ) {
        // Request background execution time from the system
        var backgroundTaskID: UIBackgroundTaskIdentifier = .invalid
        backgroundTaskID = UIApplication.shared.beginBackgroundTask(withName: "MemoryUpload") {
            // End the task if time expires
            UIApplication.shared.endBackgroundTask(backgroundTaskID)
            backgroundTaskID = .invalid
        }
        
        Task {
            do {
                print("Starting background upload for memory: \(title)")
                
                let timestamp = Int(Date().timeIntervalSince1970)
                let fileName = "\(timestamp)_\(UUID().uuidString).jpg"
                
                // 1. Upload the image
                try await supabase.storage
                    .from("memory-images")
                    .upload(path: fileName, file: imageData)
                
                // 2. Insert the record into the database
                try await supabase
                    .from("memories")
                    .insert([
                        [
                            "relationship_id": relationshipId.uuidString,
                            "user_id": userId,
                            "title": title,
                            "description": description,
                            "image_path": fileName,
                            "memory_date": isoDate
                        ]
                    ])
                    .execute()
                
                // 3. Send notification to partner
                do {
                    try await NotificationService.shared.sendPartnerNotification(
                        relationshipId: relationshipId,
                        type: "memory_added",
                        message: "Your partner added a new memory for you 💌",
                        entityType: "memory",
                        entityId: nil
                    )
                } catch {
                    print("Failed to notify partner: \(error)")
                }
                
                print("Background upload completed successfully for memory: \(title)")
                
            } catch {
                print("Background upload failed: \(error)")
                // Note: Consider adding local retry logic or a database of "failed uploads" if required
            }
            
            // Mark background task as complete
            if backgroundTaskID != .invalid {
                UIApplication.shared.endBackgroundTask(backgroundTaskID)
                backgroundTaskID = .invalid
            }
        }
    }
}
