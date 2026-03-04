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
func startActivityForCouple(
        relationshipId: UUID,
        userId: UUID,
        activity: Activity
    ) async throws -> DBCoupleActivity

    func scheduleActivity(
        relationshipId: UUID,
        userId: UUID,
        activity: Activity,
        scheduledDate: Date
    ) async throws -> DBCoupleActivity

    func fetchActivities(
        relationshipId: UUID,
        status: String
    ) async throws -> [DBCoupleActivity]

    func fetchAllCoupleActivities(
        relationshipId: UUID
    ) async throws -> [DBCoupleActivity]

    func submitFeedback(
        coupleActivityId: UUID,
        userId: UUID,
        mood: String,
        message: String?
    ) async throws

    func listenForActivityChanges(
        relationshipId: UUID,
        onChange: @escaping () -> Void
    )

}
