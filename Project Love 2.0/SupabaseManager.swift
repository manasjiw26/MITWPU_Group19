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
}
