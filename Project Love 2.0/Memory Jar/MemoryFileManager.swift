import Foundation
import UIKit

/// Centralised helpers for reading / writing memory photos on-device.
/// All images live in: <Documents>/Memories/<fileName>
enum MemoryFileManager {

    // MARK: - In-memory cache (survives the session, purged on memory pressure)
    private static let imageCache: NSCache<NSString, UIImage> = {
        let cache = NSCache<NSString, UIImage>()
        cache.countLimit = 200          // max images held in RAM
        cache.totalCostLimit = 100 * 1024 * 1024   // ~100 MB cap
        return cache
    }()

    static func clearCache() { imageCache.removeAllObjects() }

    // MARK: - Paths

    static var memoriesDirectory: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let dir  = docs.appendingPathComponent("Memories", isDirectory: true)
        if !FileManager.default.fileExists(atPath: dir.path) {
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }

    static func localURL(for fileName: String) -> URL {
        memoriesDirectory.appendingPathComponent(fileName)
    }

    // MARK: - Read (synchronous — use only when already off the main thread)

    /// Returns the cached image if available, otherwise loads from disk synchronously.
    /// Use `loadImageAsync` inside `cellForItemAt` to avoid blocking the main thread.
    static func loadImage(fileName: String) -> UIImage? {
        let key = fileName as NSString
        if let cached = imageCache.object(forKey: key) { return cached }
        let url = localURL(for: fileName)
        guard FileManager.default.fileExists(atPath: url.path),
              let image = UIImage(contentsOfFile: url.path) else { return nil }
        imageCache.setObject(image, forKey: key, cost: image.jpegData(compressionQuality: 0.5)?.count ?? 50_000)
        return image
    }

    // MARK: - Read (async — use in cellForItemAt to keep scrolling smooth)

    /// Loads image off the main thread, calls `completion` on the main thread.
    /// Checks the cache first — if already loaded, calls back synchronously on main.
    static func loadImageAsync(fileName: String, completion: @escaping (UIImage?) -> Void) {
        let key = fileName as NSString
        if let cached = imageCache.object(forKey: key) {
            completion(cached)   // already in cache — instant, still on caller's thread
            return
        }
        DispatchQueue.global(qos: .userInitiated).async {
            let image = loadImage(fileName: fileName)   // disk read on background thread
            DispatchQueue.main.async { completion(image) }
        }
    }

    // MARK: - Write

    @discardableResult
    static func saveImage(data: Data, fileName: String) -> URL? {
        let url = localURL(for: fileName)
        do {
            try data.write(to: url)
            // Pre-warm the cache so the image is instantly available
            if let image = UIImage(data: data) {
                imageCache.setObject(image, forKey: fileName as NSString, cost: data.count)
            }
            return url
        } catch {
            return nil
        }
    }

    // MARK: - Delete

    static func deleteImage(fileName: String) {
        imageCache.removeObject(forKey: fileName as NSString)
        let url = localURL(for: fileName)
        try? FileManager.default.removeItem(at: url)
    }
}

