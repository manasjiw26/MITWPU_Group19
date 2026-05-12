//
//  WidgetMemoryPayload.swift
//  Project Love 2.0
//
//  Lightweight Codable snapshot of a single memory.
//

import Foundation

struct WidgetMemoryPayload: Codable {
    let memoryId: String
    let title: String
    let subtitle: String
    let memoryDate: Date
    let imageIndex: Int // Links to widget_X.jpg
}

/// Container for multiple memories to support rotation.
struct WidgetTimelinePayload: Codable {
    let memories: [WidgetMemoryPayload]
}
