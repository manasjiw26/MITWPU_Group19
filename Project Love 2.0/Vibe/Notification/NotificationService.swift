//
//  NotificationService.swift
//  Project Love 2.0
//
//  Created by SDC-USER on 04/03/26.
//

import Foundation
import Supabase

final class NotificationService {
    static let shared = NotificationService()
    private init() {}

    private var supabase: SupabaseClient { SupabaseManager.shared.client }
  
    func fetchNotifications(for userId: UUID) async throws -> [AppNotification] {
        let rows: [NotificationRow] = try await supabase
            .from("notifications")
            .select("notification_id,sent_by_user_id,received_user_id,type,message,is_read,created_at")
            .eq("received_user_id", value: userId.uuidString)
            .order("created_at", ascending: false)
            .execute()
            .value

        return rows.map { row in
            AppNotification(
                id: row.notification_id,
                senderName: row.sender_name ?? "Partner",
                message: row.message,
                type: mapType(row.type),
                createdAt: row.created_at,
                isRead: row.is_read
            )
        }
    }

    func markAsRead(notificationId: UUID) async throws {
        try await supabase
            .from("notifications")
            .update(["is_read": true])
            .eq("notification_id", value: notificationId.uuidString)
            .execute()
    }
    func sendPartnerNotification(
        relationshipId: UUID,
        type: String,
        message: String,
        entityType: String? = nil,
        entityId: String? = nil
    ) async throws {
        var params: [String: String] = [
            "p_relationship_id": relationshipId.uuidString,
            "p_type": type,
            "p_message": message
        ]

        if let entityType {
            params["p_entity_type"] = entityType
        }
        if let entityId {
            params["p_entity_id"] = entityId
        }

        try await supabase
            .rpc("create_partner_notification", params: params)
            .execute()
    }

    
    private func mapType(_ raw: String) -> NotificationType {
        switch raw {
        case "activity_started": return .activityStarted
        case "love_note_sent": return .loveNoteSent
        case "memory_added": return .memoryAdded
        case "mood_updated": return .moodUpdated
        default: return .activityStarted
        }
    }

}
