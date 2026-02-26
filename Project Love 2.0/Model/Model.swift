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
    var savedPreferences: [Int: Set<Int>]
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
//adding special dates
struct SpecialDate {
    let title: String
    let date: Date
    let note: String
}

//Database model
struct DBUser: Codable {
    let user_id: UUID
    let name: String
    let profile_image: String?
    let created_at: Date?
    let birth_date: Date
    
    let partner_id: UUID?
    let relationship_id: UUID?
}
struct DBRelationship: Codable {
    let relationship_id: UUID
    let user1_id: UUID
    let user2_id: UUID
    let started_at: Date
    let status: String
}
struct PairingCodeInsert: Codable {
    let code: String
    let created_by: UUID
    let expires_at: Date
    let used: Bool?
}
struct DBMood: Codable {
    let mood_id: UUID
    let title: String
    let image: String
}

struct DBMoodLogWithMood: Codable {
    let created_at: String
    let moods: DBMood
}


//Datatstore activites according to mood
enum SuggestionGroup: String, CaseIterable {
    case A, B, C, D, E, F, G, H, I, J
}

struct DailyCheckInSelection {
    let mood: String
    let closeness: String
    let vibe: String
    let need: String
}

struct MemoryModel: Decodable {
    let id: UUID
    let relationship_id: UUID
    let created_by_user_id: UUID
    let title: String
    let description: String?
    let image_path: String
    let memory_date: String

    enum CodingKeys: String, CodingKey {
        case id = "memory_id"
        case relationship_id
        case created_by_user_id
        case title
        case description
        case image_path
        case memory_date
    }
    
}
