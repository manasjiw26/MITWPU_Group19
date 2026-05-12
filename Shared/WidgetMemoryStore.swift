//
//  WidgetMemoryStore.swift
//  Project Love 2.0
//
//  Handles saving/loading multiple memories for widget rotation.
//

import Foundation
import UIKit
import WidgetKit

/// Protocol to allow the App target to pass Memory objects without the 
/// Widget target needing to know about the full Memory struct.
protocol WidgetMemorySource {
    var id: UUID { get }
    var title: String { get }
    var date: Date { get }
    var uiImage: UIImage? { get }
    var imageName: String { get }
}

enum WidgetMemoryStore {

    static let appGroupId = "group.TwoOfUs.in"
    private static let payloadFileName = "widget_timeline.json"
    private static let targetPixelArea: CGFloat = 600_000.0

    static var sharedContainerURL: URL? {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupId)
    }

    // MARK: - Write

    /// Saves a collection of memories for the widget to rotate through.
    /// Uses a protocol to avoid dependency on the main app's Memory struct in the widget target.
    static func update(memories: [WidgetMemorySource]) {
        print("[WidgetStore] ═══════════════════════════════════════")
        print("[WidgetStore] MULTI-MEMORY UPDATE (\(memories.count) items)")

        guard let container = sharedContainerURL else { return }

        // 1. Prepare payload and save images
        var payloads: [WidgetMemoryPayload] = []
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none

        clearImages()

        // Save up to 5 memories for rotation
        let itemsToSave = Array(memories.suffix(5))
        
        for (index, memory) in itemsToSave.enumerated() {
            let imageName = "widget_\(index).jpg"
            let imageURL = container.appendingPathComponent(imageName)

            var resolvedImage = memory.uiImage
            if resolvedImage == nil {
                let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let localPath = docs.appendingPathComponent("Memories").appendingPathComponent(memory.imageName)
                resolvedImage = UIImage(contentsOfFile: localPath.path)
            }

            if let img = resolvedImage {
                let downsampled = downsampleToTargetArea(image: img, targetArea: targetPixelArea)
                if let data = downsampled.jpegData(compressionQuality: 0.6) {
                    try? data.write(to: imageURL, options: Data.WritingOptions.atomic)
                    
                    let payload = WidgetMemoryPayload(
                        memoryId: memory.id.uuidString,
                        title: memory.title,
                        subtitle: formatter.string(from: memory.date),
                        memoryDate: memory.date,
                        imageIndex: index
                    )
                    payloads.append(payload)
                    print("[WidgetStore] ✓ Saved image \(index)")
                }
            }
        }

        let timeline = WidgetTimelinePayload(memories: payloads)
        let payloadURL = container.appendingPathComponent(payloadFileName)
        if let data = try? JSONEncoder().encode(timeline) {
            try? data.write(to: payloadURL, options: Data.WritingOptions.atomic)
            print("[WidgetStore] ✓ Timeline JSON saved")
        }

        WidgetCenter.shared.reloadAllTimelines()
        print("[WidgetStore] ═══════════════════════════════════════")
    }

    private static func downsampleToTargetArea(image: UIImage, targetArea: CGFloat) -> UIImage {
        let currentArea = image.size.width * image.size.height
        if currentArea <= targetArea { return image }
        let ratio = sqrt(targetArea / currentArea)
        let newSize = CGSize(width: floor(image.size.width * ratio), height: floor(image.size.height * ratio))
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1.0
        return UIGraphicsImageRenderer(size: newSize, format: format).image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }

    private static func clearImages() {
        guard let container = sharedContainerURL else { return }
        for i in 0..<10 {
            let url = container.appendingPathComponent("widget_\(i).jpg")
            try? FileManager.default.removeItem(at: url)
        }
    }

    static func clear() {
        guard let container = sharedContainerURL else { return }
        clearImages()
        let payloadURL = container.appendingPathComponent(payloadFileName)
        try? FileManager.default.removeItem(at: payloadURL)
        WidgetCenter.shared.reloadAllTimelines()
    }

    // MARK: - Read (for Widget)

    static func loadTimeline() -> [WidgetMemoryPayload] {
        guard let url = sharedContainerURL?.appendingPathComponent(payloadFileName),
              let data = try? Data(contentsOf: url),
              let timeline = try? JSONDecoder().decode(WidgetTimelinePayload.self, from: data) else {
            return []
        }
        return timeline.memories
    }

    static func loadImage(at index: Int) -> UIImage? {
        guard let url = sharedContainerURL?.appendingPathComponent("widget_\(index).jpg"),
              let data = try? Data(contentsOf: url) else {
            return nil
        }
        return UIImage(data: data)
    }
}
