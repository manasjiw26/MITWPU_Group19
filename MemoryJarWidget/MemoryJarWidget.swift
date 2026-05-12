//
//  MemoryJarWidget.swift
//  MemoryJarWidget
//
//  Rotates through multiple Memory Jar photos with a true edge-to-edge layout.
//

import WidgetKit
import SwiftUI

// MARK: - Timeline Entry

struct MemoryEntry: TimelineEntry {
    let date: Date
    let title: String?
    let subtitle: String?
    let memoryId: String?
    let image: UIImage?
}

// MARK: - Timeline Provider

struct MemoryProvider: TimelineProvider {

    func placeholder(in context: Context) -> MemoryEntry {
        MemoryEntry(date: Date(), title: "Our Memory", subtitle: "Just now", memoryId: nil, image: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (MemoryEntry) -> Void) {
        let memories = WidgetMemoryStore.loadTimeline()
        if let first = memories.first {
            let image = WidgetMemoryStore.loadImage(at: first.imageIndex)
            completion(MemoryEntry(date: Date(), title: first.title, subtitle: first.subtitle, memoryId: first.memoryId, image: image))
        } else {
            completion(placeholder(in: context))
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<MemoryEntry>) -> Void) {
        let memories = WidgetMemoryStore.loadTimeline()
        var entries: [MemoryEntry] = []
        let currentDate = Date()

        if memories.isEmpty {
            entries.append(placeholder(in: context))
        } else {
            // Create an aggressive timeline where memories rotate every 1 minute
            for (index, payload) in memories.enumerated() {
                let entryDate = Calendar.current.date(byAdding: .minute, value: index, to: currentDate)!
                let image = WidgetMemoryStore.loadImage(at: payload.imageIndex)
                
                let entry = MemoryEntry(
                    date: entryDate,
                    title: payload.title,
                    subtitle: payload.subtitle,
                    memoryId: payload.memoryId,
                    image: image
                )
                entries.append(entry)
            }
        }

        // Refresh the whole timeline once we cycle through the batch
        let reloadDate = Calendar.current.date(byAdding: .minute, value: max(1, entries.count), to: currentDate)!
        completion(Timeline(entries: entries, policy: .after(reloadDate)))
    }
}

// MARK: - Widget View

struct MemoryJarWidgetEntryView: View {
    var entry: MemoryProvider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if let title = entry.title {
                    // 1. Content Overlay (Text and Gradient)
                    VStack {
                        Spacer()
                        VStack(alignment: .leading, spacing: 2) {
                            if family != .systemSmall {
                                Text("Memory of the day")
                                    .font(.caption2)
                                    .fontWeight(.medium)
                                    .foregroundColor(.white.opacity(0.85))
                                    .textCase(.uppercase)
                                    .tracking(0.5)
                            }

                            Text(title)
                                .font(family == .systemSmall ? .caption : .subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .lineLimit(family == .systemSmall ? 1 : 2)

                            if family != .systemSmall, let subtitle = entry.subtitle {
                                Text(subtitle)
                                    .font(.caption2)
                                    .foregroundColor(.white.opacity(0.75))
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 12)
                        .background(
                            LinearGradient(
                                colors: [.clear, .black.opacity(0.7)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    }
                } else {
                    // 2. Empty State
                    VStack(spacing: 8) {
                        Image(systemName: "heart.text.square")
                            .font(.system(size: 32))
                            .foregroundColor(Color(red: 0.85, green: 0.60, blue: 0.70))
                        Text("Memory Jar").font(.caption).fontWeight(.semibold)
                        Text("Add your first memory").font(.caption2).foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .widgetURL(URL(string: "memorylane://open?id=\(entry.memoryId ?? "")"))
        }
        .containerBackground(for: .widget) {
            // 3. TRUE EDGE-TO-EDGE BACKGROUND
            if let image = entry.image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                LinearGradient(
                    colors: [Color(red: 0.95, green: 0.85, blue: 0.90), Color(red: 0.85, green: 0.75, blue: 0.88)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        }
    }
}

// MARK: - Widget Configuration

struct MemoryJarWidget: Widget {
    let kind: String = "MemoryJarWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: MemoryProvider()) { entry in
            MemoryJarWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Memory Jar")
        .description("Your shared memories, automatically rotating on your home screen.")
        .supportedFamilies([.systemSmall, .systemMedium])
        .contentMarginsDisabled()
    }
}

@main
struct MemoryJarWidgetBundle: WidgetBundle {
    var body: some Widget {
        MemoryJarWidget()
    }
}
