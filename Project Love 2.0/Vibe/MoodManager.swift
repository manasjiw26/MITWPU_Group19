//
//  MoodManager.swift
//  Project Love 2.0
//
//  Created by SDC-USER on 20/01/26.
//

import Foundation

class MoodManager {

    static let shared = MoodManager()

    private let keyLastChange = "lastMoodChangeTime"

    func canChangeMood() -> Bool {

        guard let last = UserDefaults.standard.object(forKey: keyLastChange) as? Date else {
            return true
        }
        let minutes = Calendar.current.dateComponents([.minute], from: last, to: Date()).minute ?? 0
        return minutes >= 180
    }

    func registerMoodChange() {
        UserDefaults.standard.set(Date(), forKey: keyLastChange)
    }

    func remainingTimeText() -> String {

        guard let last = UserDefaults.standard.object(forKey: keyLastChange) as? Date else {
            return ""
        }

        let nextAllowed = Calendar.current.date(byAdding: .hour, value: 3, to: last)!

        let minutes = Calendar.current.dateComponents([.minute], from: Date(), to: nextAllowed).minute ?? 0

        if minutes <= 0 {
            return "You can change now"
        }

        let h = minutes / 60
        let m = minutes % 60

        if h > 0 {
            return "Try again in \(h)h \(m)m"
        } else {
            return "Try again in \(m)m"
        }
    }
}
