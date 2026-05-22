//
//  SecretsManager.swift
//  Project Love 2.0
//
//  Centralised access to secrets stored in Secrets.plist.
//  This file is safe to commit — the actual values live in
//  Secrets.plist which is git-ignored.
//

import Foundation

enum SecretsManager {

    // MARK: - Public accessors

    static let supabaseURL: String = {
        guard let value = secret(forKey: "SUPABASE_URL"), !value.isEmpty else {
            fatalError("⚠️ SUPABASE_URL not found in Secrets.plist. "
                     + "Copy Secrets.plist.example → Secrets.plist and fill in your keys.")
        }
        return value
    }()

    static let supabaseAnonKey: String = {
        guard let value = secret(forKey: "SUPABASE_ANON_KEY"), !value.isEmpty else {
            fatalError("⚠️ SUPABASE_ANON_KEY not found in Secrets.plist. "
                     + "Copy Secrets.plist.example → Secrets.plist and fill in your keys.")
        }
        return value
    }()

    static let googleClientID: String = {
        guard let value = secret(forKey: "GOOGLE_CLIENT_ID"), !value.isEmpty else {
            fatalError("⚠️ GOOGLE_CLIENT_ID not found in Secrets.plist. "
                     + "Copy Secrets.plist.example → Secrets.plist and fill in your keys.")
        }
        return value
    }()

    static let googleReversedClientID: String = {
        guard let value = secret(forKey: "GOOGLE_REVERSED_CLIENT_ID"), !value.isEmpty else {
            fatalError("⚠️ GOOGLE_REVERSED_CLIENT_ID not found in Secrets.plist. "
                     + "Copy Secrets.plist.example → Secrets.plist and fill in your keys.")
        }
        return value
    }()

    // MARK: - Private helpers

    private static let secrets: [String: Any] = {
        guard let url = Bundle.main.url(forResource: "Secrets", withExtension: "plist"),
              let data = try? Data(contentsOf: url),
              let dict = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any]
        else {
            fatalError("⚠️ Secrets.plist is missing from the app bundle. "
                     + "Copy Secrets.plist.example → Secrets.plist and fill in your keys.")
        }
        return dict
    }()

    private static func secret(forKey key: String) -> String? {
        return secrets[key] as? String
    }
}
