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

    func startActivityForCouple( relationshipId: UUID, userId: UUID, activity: Activity ) async throws -> DBCoupleActivity {
        let insert = CoupleActivityInsert(
            relationshipId: relationshipId,
            activityId: activity.id ?? 0,
            activityName: activity.name,
            status: "ongoing",
            startedBy: userId,
            scheduledDate: nil,
            isCustom: false,
            description: nil
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

    func scheduleActivity( relationshipId: UUID, userId: UUID, activity: Activity, scheduledDate: Date ) async throws -> DBCoupleActivity {
        let insert = CoupleActivityInsert(
            relationshipId: relationshipId,
            activityId: activity.id ?? 0,
            activityName: activity.name,
            status: "scheduled",
            startedBy: userId,
            scheduledDate: scheduledDate,
            isCustom: false,
            description: nil
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

    func updateCoupleActivityStatus(coupleActivityId: UUID, status: String) async throws {
        try await client
            .from("couple_activities")
            .update(["status": status])
            .eq("couple_activity_id", value: coupleActivityId.uuidString)
            .execute()
    }

    func fetchActivities( relationshipId: UUID, status: String ) async throws -> [DBCoupleActivity] {
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

    func fetchAllCoupleActivities( relationshipId: UUID ) async throws -> [DBCoupleActivity] {
        let result: [DBCoupleActivity] = try await client
            .from("couple_activities")
            .select()
            .eq("relationship_id", value: relationshipId.uuidString)
            .order("started_at", ascending: false)
            .execute()
            .value

        return result
    }

    func submitFeedback( coupleActivityId: UUID, userId: UUID, mood: String, message: String?, feedbackTags: [String], feedbackScore: Int ) async throws {
        // 1. Determine if current user is user A (user1) or user B (user2)
        guard let relationshipId = DataStore.shared.currentRelationshipId else {
            return
        }

        let relationship: DBRelationship = try await client
            .from("relationships")
            .select()
            .eq("relationship_id", value: relationshipId.uuidString)
            .single()
            .execute()
            .value

        let isUserA = (userId == relationship.user1_id)

        // 2. Build a payload for ONLY this user's columns
        //    (encodeIfPresent skips nil fields, so the other user's data is never touched)
        var payload: ActivityFeedbackPayload
        if isUserA {
            payload = ActivityFeedbackPayload(
                userAId: userId,
                userAMood: mood,
                userAMessage: message,
                userATags: feedbackTags,
                userAScore: feedbackScore
            )
        } else {
            payload = ActivityFeedbackPayload(
                userBId: userId,
                userBMood: mood,
                userBMessage: message,
                userBTags: feedbackTags,
                userBScore: feedbackScore
            )
        }

        // 3. Check if a feedback row already exists for this activity
        struct FeedbackCheck: Decodable { let feedback_id: UUID }
        let existing: [FeedbackCheck] = try await client
            .from("activity_feedback")
            .select("feedback_id")
            .eq("couple_activity_id", value: coupleActivityId.uuidString)
            .limit(1)
            .execute()
            .value

        if existing.isEmpty {
            // No row yet → INSERT (include couple_activity_id)
            payload.coupleActivityId = coupleActivityId
            try await client
                .from("activity_feedback")
                .insert(payload)
                .execute()
        } else {
            // Row exists → UPDATE only this user's columns
            try await client
                .from("activity_feedback")
                .update(payload)
                .eq("couple_activity_id", value: coupleActivityId.uuidString)
                .execute()
        }

        // 4. Mark this user's feedback as done on couple_activities
        let column = isUserA ? "feedback_a_done" : "feedback_b_done"
        try await client
            .from("couple_activities")
            .update([column: true])
            .eq("couple_activity_id", value: coupleActivityId.uuidString)
            .execute()

        struct FeedbackFlags: Decodable {
            let feedback_a_done: Bool
            let feedback_b_done: Bool
        }

        let flags: FeedbackFlags = try await client
            .from("couple_activities")
            .select("feedback_a_done, feedback_b_done")
            .eq("couple_activity_id", value: coupleActivityId.uuidString)
            .single()
            .execute()
            .value

        if flags.feedback_a_done && flags.feedback_b_done {
            try await updateCoupleActivityStatus(
                coupleActivityId: coupleActivityId,
                status: "completed"
            )
        }
    }

    /// Fetch the single combined feedback row for an activity
    func fetchFeedbackForActivity(coupleActivityId: UUID) async throws -> DBActivityFeedback? {
        let result: [DBActivityFeedback] = try await client
            .from("activity_feedback")
            .select()
            .eq("couple_activity_id", value: coupleActivityId.uuidString)
            .limit(1)
            .execute()
            .value
        return result.first
    }

    /// Fetch ALL feedback rows for a relationship (for personalization / suggestions)
    func fetchAllFeedbackForRelationship(relationshipId: UUID) async throws -> [DBActivityFeedback] {
        let coupleActivities: [DBCoupleActivity] = try await client
            .from("couple_activities")
            .select()
            .eq("relationship_id", value: relationshipId.uuidString)
            .execute()
            .value

        let activityIds = coupleActivities.map { $0.coupleActivityId.uuidString }
        guard !activityIds.isEmpty else { return [] }

        let result: [DBActivityFeedback] = try await client
            .from("activity_feedback")
            .select()
            .in("couple_activity_id", values: activityIds)
            .order("created_at", ascending: false)
            .execute()
            .value

        return result
    }

    // Tracks channels we have already subscribed to (prevents duplicate listeners
    // when viewWillAppear fires multiple times for the same relationship ID).
    private var subscribedChannelIds: Set<String> = []

    func listenForActivityChanges( relationshipId: UUID, onChange: @escaping () -> Void ) {
        let channelId = "couple-activities-\(relationshipId.uuidString)"
        guard !subscribedChannelIds.contains(channelId) else { return }
        subscribedChannelIds.insert(channelId)

        let channel = client.realtimeV2.channel(channelId)

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

    //  Memory Delete

    /// Delete a memory using a server-side function.
    /// This calls the delete_memory() PostgreSQL function which handles the deletion.
    func deleteMemory(memoryId: UUID, imagePath: String) async throws {

        // 1. Call the database function to delete the row
        try await client
            .rpc("delete_memory", params: ["p_memory_id": memoryId.uuidString])
            .execute()


        // 2. Remove the image from storage (best-effort)
        if !imagePath.isEmpty {
            do {
                try await client.storage
                    .from("memory-images")
                    .remove(paths: [imagePath])
            } catch {
            }
        }
    }

    /// Persist edits to a memory's metadata fields in Supabase.
    /// Called after the user changes title, description, date, or location.
    /// All fields are written in a single UPDATE so Supabase Realtime fires
    /// one event that the partner's MemorySyncManager can act on immediately.
    func updateMemory(
        memoryId: UUID,
        title: String,
        description: String,
        date: Date,
        location: String
    ) async throws {
        let isoDate = ISO8601DateFormatter().string(from: date)

        try await client
            .from("memories")
            .update([
                "title":       title,
                "description": description,
                "memory_date": isoDate,
                "location":    location
            ])
            .eq("memory_id", value: memoryId.uuidString)
            .execute()
    }
    func updateUserMood(moodTitle: String) async throws {

            guard let currentUserId = currentUserId,

                  let relationshipId = DataStore.shared.currentRelationshipId else {


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

            


        }

    // MARK: - Special Dates

    /// Insert a new special date for the relationship
    func insertSpecialDate(_ insert: SpecialDateInsert) async throws -> DBSpecialDate {
        let result: DBSpecialDate = try await client
            .from("special_dates")
            .insert(insert)
            .select()
            .single()
            .execute()
            .value
        return result
    }

    /// Fetch all special dates for a given relationship
    func fetchSpecialDates(relationshipId: UUID) async throws -> [DBSpecialDate] {
        let result: [DBSpecialDate] = try await client
            .from("special_dates")
            .select()
            .eq("relationship_id", value: relationshipId.uuidString)
            .order("event_date", ascending: true)
            .execute()
            .value
        return result
    }

    /// Delete a special date by its ID
    func deleteSpecialDate(specialDateId: UUID) async throws {
        try await client
            .from("special_dates")
            .delete()
            .eq("special_date_id", value: specialDateId.uuidString)
            .execute()
    }

    /// Subscribe to Realtime changes on special_dates for this relationship
    func listenForSpecialDateChanges(
        relationshipId: UUID,
        onChange: @escaping () -> Void
    ) {
        let channel = client.realtimeV2.channel("special-dates-\(relationshipId.uuidString)")

        let changes = channel.postgresChange(
            AnyAction.self,
            schema: "public",
            table: "special_dates",
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

}
