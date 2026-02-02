//
//  Model.swift
//  Project Love 2.0
//
//  Created by SDC-USER on 26/11/25.
//

import Foundation
import UIKit

struct Activity{
    var name : String
    var description : String
    var image : String
    var time : String
    var status: ActivityStatus
    var category: String
    var scheduledDate: Date?
}

enum ActivityStatus {
    case none
    case ongoing
    case completed
    case scheduled
}

struct ActivityCategory{
    var name : String
    var description : String
    var image : String
}

struct Reward{
    var image : String
    var name : String
    var emoji: String
    var progressStep: Int
}

struct MakeSmile{
    var types: String
    var imageName: String    
}
struct BuildYourBond {
    var name : String
    var imageName: String
}

struct Question {
    let title: String
    let options: [String]
}
struct Tip {
    let id: UUID = UUID()
    let title: String
    var isSelected: Bool = false
}

struct MoodCheckIn {
    var label: String
    var imageName: String
    var moodLabel: String
}

struct ActivityStats{
    var types: String
    var imageName: String
    var count: Int
}

struct SmallModalData{
    var title: String
    var mainImageName: String
    var descriptionLabel: String
    var clockImageName: String
    var timerLabel: String
}
struct StepsToFollow{
    var number: Int
    var title: String
    var descriptionLabel: String
}
struct FeedBackGiven{
    var title: String
    var subTitle: String
    var imageName: String
    var userMessage: String?
    var selectedMood: String?
}

struct Mood {
    let id: Int
    let title: String
    let imageName: String
}
struct Message {
    let text: String
    let isSender: Bool
}

enum ActivityFlowSource {
    case activitiesForHer
    case explore
    
}
struct DailyCheckInResult {
    let activityTitle: String
    let activitySubtitle: String
    let imageName: String
}
struct BuildYourBondpage {
    var Name: String
    var SubHeading: String
    var stepLabel: String
    var step: [String]
    var activity : [Activity]
    
    var badge : String
    var badgesubHeading: String
    var badgeImageName: String
    
    var HIWStep : [String]
}

struct BadgePopupData {
    let title: String
    let subtitle: String
    let imageName: String
}

struct MemoryItem {
    let imageName: String
}
struct MemoryCategory {
    let title: String
    var items: [MemoryItem]
}
struct Memory {
    var id: UUID = UUID()
    var date: Date = Date()
    var imageName: String
    var location: String
    var title: String
    var description: String
    var uiImage: UIImage?
}

enum NotificationType {
    case memory
    case activity
    case loveNote
    case mood

    var titleText: String {
        switch self {
        case .memory:
            return "MEMORY ALERT"
        case .activity:
            return "ACTIVITY ALERT"
        case .loveNote:
            return "LOVE NOTE"
        case .mood:
            return "MOOD UPDATE"
        }
    }

    var iconName: String {
        switch self {
        case .memory:
            return "photo.on.rectangle"
        case .activity:
            return "checklist"
        case .loveNote:
            return "heart.text.square"
        case .mood:
            return "face.smiling"
        }
    }
}
struct DailyCheckInQuestion {
    let stepID: Int
    let title: String
    let options: [DailyOption]
}

struct DailyOption {
    let id: Int
    let label: String
    let imageName: String
}

struct AppNotification {
    let id: UUID
    let senderName: String
    let message: String
    let type: NotificationType
    let createdAt: Date
    var isRead: Bool
    var titleText: String { type.titleText }
    var iconName: String { type.iconName }
    var timeAgoText: String { createdAt.timeAgoText }
}

extension Date {
    var timeAgoText: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}

struct PhysicsCategory {
    static let jar: UInt32 = 0b1
    static let heart: UInt32 = 0b10
}
struct UserProfile {
    var name: String
    var email: String
    var profileImageName: String
}

struct ProfileSection {
    var title: String
    var items: [ProfileItem]
}

struct ProfileItem {
    var title: String
    var iconName: String
    var showsChevron: Bool
}
struct PersonalInfoItem {
    let title: String
    var value: String
    let showsChevron: Bool
}

struct PersonalInfoSection {
    let title: String
    var items: [PersonalInfoItem]
}
struct QnAOption {
    var text: String
    var isSelected: Bool
}

struct QnAQuestion {
    var questionText: String
    var options: [QnAOption]
}

struct QnAData {
    var title: String
    var questions: [QnAQuestion]
}
