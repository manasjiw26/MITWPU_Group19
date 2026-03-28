//
//  NotificationService.swift
//  Project Love 2.0
//
//  Created by SDC-USER on 04/03/26.
//

import UIKit 
import Foundation
import Supabase

final class NotificationService {
    static let shared = NotificationService()
    private init() {}

    private var supabase: SupabaseClient { SupabaseManager.shared.client }
    
    /// Saves the Apple Push Notification device token to the user's profile in Supabase
    func saveDeviceToken(_ token: String) async throws {
        let session = try await supabase.auth.session
        let currentUserId = session.user.id
        
        // This assumes you have an 'apns_token' column in your 'users' table.
        // If you are using a separate table like 'user_device_tokens', change the table name here.
        try await supabase
            .from("users")
            .update(["apns_token": token])
            .eq("id", value: currentUserId.uuidString) // or whatever your primary key is for users
            .execute()
    }


       func fetchNotifications(for userId: UUID) async throws -> [AppNotification] {
            let rows: [NotificationRow] = try await supabase
                .from("notifications")
                .select("notification_id,sender_user_id,receiver_user_id,type,message,is_read,created_at,entity_id,entity_type,sender:users!sender_user_id(name)")
                .eq("receiver_user_id", value: userId.uuidString)
                .order("created_at", ascending: false)
                .execute()
                .value

            return rows.map { row in
                AppNotification(
                    id: row.notification_id,
                    senderName: row.sender?.name ?? "Partner",
                    message: row.message,
                    type: mapType(row.type),
                    createdAt: row.created_at,
                    isRead: row.is_read,
                    entityId: row.entity_id
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

    /// Send a notification to the current user's partner by inserting directly
    /// into the `notifications` table. Resolves the partner from the relationship.
    func sendPartnerNotification(
        relationshipId: UUID,
        type: String,
        message: String,
        entityType: String? = nil,
        entityId: String? = nil
    ) async throws {

        // 1. Get the current user
        let session = try await supabase.auth.session
        let currentUserId = session.user.id

        // 2. Find the partner from the relationship
        let relationships: [DBRelationship] = try await supabase
            .from("relationships")
            .select()
            .eq("relationship_id", value: relationshipId.uuidString)
            .limit(1)
            .execute()
            .value

        guard let relationship = relationships.first else {
            return
        }

        let partnerUserId = (relationship.user1_id == currentUserId)
            ? relationship.user2_id
            : relationship.user1_id

        // 3. Insert the notification row
        let insert = NotificationInsert(
            relationship_id: relationshipId.uuidString,
            sender_user_id: currentUserId.uuidString,
            receiver_user_id: partnerUserId.uuidString,
            type: type,
            message: message,
            entity_type: entityType,
            entity_id: entityId
        )

        try await supabase
            .from("notifications")
            .insert(insert)
            .execute()

    }

    
    private func mapType(_ raw: String) -> NotificationType {
        switch raw {
        case "activity_started": return .activityStarted
        case "love_note_sent": return .loveNoteSent
        case "memory_added": return .memoryAdded
        case "mood_updated": return .moodUpdated
        case "nudge_sent": return .nudgeSent
        case "love_tip_completed": return .loveTipCompleted
        case "love_tip_reacted": return .loveTipReacted
        case "feedback_completed": return .feedbackCompleted
        default: return .activityStarted
        }
    }
    func fetchLoveNote(id: String, currentUserId: UUID) async throws -> LoveNote {
        let row: DBLoveNote = try await supabase
               .from("love_notes")
               .select()
               .eq("love_note_id", value: id)
               .single()
               .execute()
               .value

           return LoveNote.fromDB(row, currentUserId: currentUserId)
       }

}
