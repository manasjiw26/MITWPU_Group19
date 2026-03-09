//
//  SupabaseManager.swift
//  Project Love 2.0
//
//  Created by SDC-USER on 09/02/26.
//

import Foundation
import Supabase

final class SupabaseManager {

    static let shared = SupabaseManager()

    let client: SupabaseClient

    private init() {
        client = SupabaseClient(
            supabaseURL: URL(string: "https://wpvglekeytqkbngmbcqt.supabase.co")!,
            supabaseKey: "sb_publishable_1xXOrpx5EAM0MzXxMy0VFA_MXwaQh4B"

        )
    }
    var currentUserId: UUID? {
        return client.auth.currentUser?.id
    }

    // MARK: - Couple Activities

    /// Insert a new couple_activity with status "ongoing"
    func startActivityForCouple(
        relationshipId: UUID,
        userId: UUID,
        activity: Activity
    ) async throws -> DBCoupleActivity {
        let insert = CoupleActivityInsert(
            relationshipId: relationshipId,
            activityId: activity.id ?? 0,
            activityName: activity.name,
            status: "ongoing",
            startedBy: userId,
            scheduledDate: nil
        )

        let result: DBCoupleActivity = try await client
            .from("couple_activities")
            .insert(insert)
            .select()
            .single()
            .execute()
            .value

        return result
    }

    /// Insert a new couple_activity with status "scheduled" and a date
    func scheduleActivity(
        relationshipId: UUID,
        userId: UUID,
        activity: Activity,
        scheduledDate: Date
    ) async throws -> DBCoupleActivity {
        let insert = CoupleActivityInsert(
            relationshipId: relationshipId,
            activityId: activity.id ?? 0,
            activityName: activity.name,
            status: "scheduled",
            startedBy: userId,
            scheduledDate: scheduledDate
        )

        let result: DBCoupleActivity = try await client
            .from("couple_activities")
            .insert(insert)
            .select()
            .single()
            .execute()
            .value

        return result
    }

    /// Fetch couple_activities filtered by status for a given relationship
    func fetchActivities(
        relationshipId: UUID,
        status: String
    ) async throws -> [DBCoupleActivity] {
        let result: [DBCoupleActivity] = try await client
            .from("couple_activities")
            .select()
            .eq("relationship_id", value: relationshipId.uuidString)
            .eq("status", value: status)
            .order("started_at", ascending: false)
            .execute()
            .value

        return result
    }

    /// Fetch all couple_activities for a given relationship
    func fetchAllCoupleActivities(
        relationshipId: UUID
    ) async throws -> [DBCoupleActivity] {
        let result: [DBCoupleActivity] = try await client
            .from("couple_activities")
            .select()
            .eq("relationship_id", value: relationshipId.uuidString)
            .order("started_at", ascending: false)
            .execute()
            .value

        return result
    }

    /// Submit feedback for a couple_activity:
    /// 1. INSERT into activity_feedback
    /// 2. Determine if user is user1 or user2 from the relationship
    /// 3. UPDATE the correct feedback_a_done or feedback_b_done flag
    func submitFeedback(
        coupleActivityId: UUID,
        userId: UUID,
        mood: String,
        message: String?
    ) async throws {
        // 1. Insert the feedback row
        let feedbackInsert = ActivityFeedbackInsert(
            coupleActivityId: coupleActivityId,
            userId: userId,
            mood: mood,
            message: message
        )

        try await client
            .from("activity_feedback")
            .insert(feedbackInsert)
            .execute()

        // 2. Find the relationship to determine user1 vs user2
        guard let relationshipId = DataStore.shared.currentRelationshipId else {
            print("⚠️ submitFeedback: no currentRelationshipId")
            return
        }

        let relationship: DBRelationship = try await client
            .from("relationships")
            .select()
            .eq("relationship_id", value: relationshipId.uuidString)
            .single()
            .execute()
            .value

        // 3. Update the correct feedback flag
        let isUser1 = (userId == relationship.user1_id)
        let column = isUser1 ? "feedback_a_done" : "feedback_b_done"

        try await client
            .from("couple_activities")
            .update([column: true])
            .eq("couple_activity_id", value: coupleActivityId.uuidString)
            .execute()
    }

    /// Subscribe to Realtime changes on couple_activities for this relationship
    func listenForActivityChanges(
        relationshipId: UUID,
        onChange: @escaping () -> Void
    ) {
        let channel = client.realtimeV2.channel("couple-activities-\(relationshipId.uuidString)")

        let changes = channel.postgresChange(
            AnyAction.self,
            schema: "public",
            table: "couple_activities",
            filter: "relationship_id=eq.\(relationshipId.uuidString)"
        )

        Task {
            await channel.subscribe()

            for await _ in changes {
                DispatchQueue.main.async {
                    onChange()
                }
            }
        }
    }

    // MARK: - Memory Delete

    /// Delete a memory using a server-side function.
    /// This calls the delete_memory() PostgreSQL function which handles the deletion.
    func deleteMemory(memoryId: UUID, imagePath: String) async throws {
        print("🗑️ Attempting to delete memory: \(memoryId.uuidString)")

        // 1. Call the database function to delete the row
        try await client
            .rpc("delete_memory", params: ["p_memory_id": memoryId.uuidString])
            .execute()

        print("✅ Memory deleted from Supabase: \(memoryId.uuidString)")

        // 2. Remove the image from storage (best-effort)
        if !imagePath.isEmpty {
            do {
                try await client.storage
                    .from("memory-images")
                    .remove(paths: [imagePath])
                print("🗑️ Image removed from storage: \(imagePath)")
            } catch {
                print("⚠️ Could not remove image from storage: \(error.localizedDescription)")
            }
        }
    }
    func updateUserMood(moodTitle: String) async throws {

            guard let currentUserId = currentUserId,

                  let relationshipId = DataStore.shared.currentRelationshipId else {

                print("⚠️ updateUserMood: missing context")

                return

            }


            // 1. Get mood_id from titles

            let moods: [DBMood] = try await client

                .from("moods")

                .select()

                .eq("title", value: moodTitle)

                .limit(1)

                .execute()

                .value



            guard let selectedMood = moods.first else {

                print("❌ Mood '\(moodTitle)' not found in DB")

                return

            }



            // 2. Insert new log

            try await client

                .from("user_mood_logs")

                .insert([

                    "relationship_id": relationshipId.uuidString,

                    "user_id": currentUserId.uuidString,

                    "mood_id": selectedMood.mood_id.uuidString

                ])

                .execute()

            

            print("✅ Mood '\(moodTitle)' logged to Supabase")

        }

}

