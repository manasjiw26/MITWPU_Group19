//
//  MemoryJarWidget.swift
//  MemoryJarWidget
//
//  Memory Jar home screen widget — shows the latest shared memory
//  with a soft, warm design matching the app's aesthetic.
//
//  Architecture: reads a JSON payload + JPEG image from the App Group
//  shared container. The main app writes these files atomically
//  whenever the latest memory changes.
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
        MemoryEntry(date: Date(), title: "Our Memory", subtitle: "Today", memoryId: nil, image: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (MemoryEntry) -> Void) {
        completion(buildEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<MemoryEntry>) -> Void) {
        let entry = buildEntry()
        // Refresh every 30 minutes; also refreshed on-demand by the app
        let next = Calendar.current.date(byAdding: .minute, value: 30, to: Date())!
        completion(Timeline(entries: [entry], policy: .after(next)))
    }

    private func buildEntry() -> MemoryEntry {
        let payload = WidgetMemoryStore.loadPayload()
        let image   = WidgetMemoryStore.loadImage()

        return MemoryEntry(
            date:     Date(),
            title:    payload?.title,
            subtitle: payload?.subtitle,
            memoryId: payload?.memoryId,
            image:    image
        )
    }
}

// MARK: - Widget View

struct MemoryJarWidgetEntryView: View {
    var entry: MemoryProvider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        if let title = entry.title {
            // Has memory data
            ZStack(alignment: .bottom) {
                // Background image or gradient fallback
                if let image = entry.image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    LinearGradient(
                        colors: [
                            Color(red: 0.95, green: 0.85, blue: 0.90),
                            Color(red: 0.85, green: 0.75, blue: 0.88)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }

                // Bottom overlay
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
                .padding(.vertical, 10)
                .background(
                    LinearGradient(
                        colors: [.clear, .black.opacity(0.65)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
            .widgetURL(URL(string: "memorylane://open?id=\(entry.memoryId ?? "")"))
        } else {
            // Empty state — no memories yet
            VStack(spacing: 8) {
                Image(systemName: "heart.text.square")
                    .font(.system(size: 32))
                    .foregroundColor(Color(red: 0.85, green: 0.60, blue: 0.70))

                Text("Memory Jar")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)

                Text("Add your first memory")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                LinearGradient(
                    colors: [
                        Color(red: 0.98, green: 0.94, blue: 0.96),
                        Color(red: 0.95, green: 0.90, blue: 0.94)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .widgetURL(URL(string: "memorylane://open"))
        }
    }
}

// MARK: - Widget Configuration

struct MemoryJarWidget: Widget {
    let kind: String = "MemoryJarWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: MemoryProvider()) { entry in
            MemoryJarWidgetEntryView(entry: entry)
                .containerBackground(.clear, for: .widget)
        }
        .configurationDisplayName("Memory Jar")
        .description("Relive your favourite moments together.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Widget Bundle (entry point)

@main
struct MemoryJarWidgetBundle: WidgetBundle {
    var body: some Widget {
        MemoryJarWidget()
    }
}
