//
//  Model.swift
//  Project Love 2.0
//
//  Created by SDC-USER on 26/11/25.
//

import Foundation
import UIKit

extension Notification.Name {
    static let preferencesDidChange = Notification.Name("preferencesDidChange")
}

// JSON wrapper for decoding activities.json
struct ActivitiesJSON: Codable {
    let activities: [JSONActivity]
}

struct JSONActivity: Codable {
    let id: Int
    let name: String?
    let title: String?
    let description: String
    let detailedDescription: String?
    let modalDescription: String?
    let image: String
    let category: String
    let time: String?
    let steps: [String]?
    let location: String?
}

struct Activity: Codable {
    var id: Int?
    var coupleActivityId: UUID?
    var name : String
    var description : String
    var detailedDescription: String?
    var modalDescription: String?
    var image : String
    var time : String
    var status: ActivityStatus
    var category: String
    var scheduledDate: Date?
    var steps: [String]? = nil
    var location: String? = nil
}

enum ActivityStatus: Codable {
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
struct LoveTipsPayload: Codable {
    let tips: [LoveTipRule]
}

struct LoveTipRule: Codable {
    let id: String
    let title: String
    let loveLanguages: [String]
    let relationshipTypes: [String]
    let carePreferences: [String]
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
struct Memory: WidgetMemorySource {
    var id: UUID = UUID()
    var date: Date = Date()
    var imageName: String
    var location: String
    var title: String
    var description: String
    var uiImage: UIImage?
    var localImagePath: String?
}

enum LoveNoteStatus {
    case sent
    case received
    case scheduled
    case loveTipCompleted
    
    var displayText: String {
        switch self {
            case .sent:
            return "SENT"
            case .received:
            return "RECEIVED"
            case .scheduled:
            return "SCHEDULED"
            case .loveTipCompleted:
            return "LOVE TIP COMPLETED"
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
    let id: UUID
    let relationshipId: UUID
    let userId: UUID
    let title: String
    let date: Date
    let note: String
    let createdAt: Date
}

struct DBSpecialDate: Codable {
    let special_date_id: UUID
    let relationship_id: UUID
    let user_id: UUID
    let title: String
    let event_date: String
    let note: String?
    let created_at: Date
}

struct SpecialDateInsert: Encodable {
    let relationship_id: String
    let user_id: String
    let title: String
    let event_date: String
    let note: String?
}


struct DBUser: Codable {
    let user_id: UUID
    let name: String
    let profile_image: String?
    let created_at: Date?
    let birth_date: Date
    let relationship_id: UUID?
    let gender: String?
    let assessment_answers: [String: [Int]]?
}

struct DBRelationship: Codable {
    let relationship_id: UUID
    let user1_id: UUID
    let user2_id: UUID
    let started_at: Date
    let status: String
}
struct PairingCodeUpdate: Encodable {
    let pairing_code: String
    let pairing_code_expires_at: String  // ISO8601 formatted
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

struct VibeTitle {
    let name: String
    let description: String        // Short text used on the card after Continue
    let pageDescription: String    // Rich text shown on the result page

    var displayTitle: String {
        return "\(name)"
    }

    /// Maps the vibe name to the corresponding image asset in Assets.xcassets
    var imageName: String {
        switch name {
        case "The Always-Attached":   return "Alwaysa_Attached"
        case "The In-Sync Duo":       return "InSync_Duo"
        case "The Deep-Dive Duo":     return "Deep_Dive_Duo"
        case "The Independent Hearts":return "Independent_hearts"
        case "The Reassurers":        return "Reassurance"
        case "The Routine-Steady":    return "Routine_steady"
        case "The Life-Logistics Team":return "Life_Logistics_Team"
        case "The Wave-Riders":       return "Wave_Riders"
        case "The Power-Builders":    return "Power_Builders"
        case "The Mending Souls":     return "Mending_Souls"
        case "The Fresh-Start Pair":  return "Fresh_Start_Pair"
        case "The High-Emotion Duo":  return "High_Emotion_Duo"
        default:                      return "Alwaysa_Attached"
        }
    }

    /// Convenience init for cases where pageDescription matches description
    init(name: String, description: String, pageDescription: String = "") {
        self.name = name
        self.description = description
        self.pageDescription = pageDescription.isEmpty ? description : pageDescription
    }
}


struct MemoryModel: Decodable {
    let id: UUID
    let relationship_id: UUID
    let user_id: UUID
    let title: String
    let description: String?
    let image_path: String
    let memory_date: String
    let is_synced: Bool
    let location: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "memory_id"
        case relationship_id
        case user_id
        case title
        case description
        case image_path
        case memory_date
        case is_synced
        case location
    }
    
}
struct DBLoveNote: Codable {
    let love_note_id: UUID
    let relationship_id: UUID
    let user_id: UUID
    let partner_user_id: UUID
    let message: String
    let created_at: Date
    let reaction: String?
    let reacted_at: Date?
    let scheduled_for: Date?
    let is_sent: Bool
}

struct LoveNoteInsert: Encodable {
    let relationship_id: UUID
    let user_id: UUID
    let partner_user_id: UUID
    let message: String
    let scheduled_for: Date?
    let is_sent: Bool
}

struct LoveNote {
    let id: UUID
    let relationshipId: UUID
    let senderUserId: UUID
    let receiverUserId: UUID
    let message: String
    let createdAt: Date
    var scheduledDate: Date?
    var reaction: String?
    var reactedAt: Date?
    var isSent: Bool
    let status: LoveNoteStatus
    let isSender: Bool
}
extension LoveNote {
    static func fromDB(_ row: DBLoveNote, currentUserId: UUID) -> LoveNote {
        // Treat the note as "effectively sent" if:
        // - is_sent flag is already true, OR
        // - scheduled_for is in the past (overdue but flag not yet flipped by any device)
        let isOverdue = row.scheduled_for.map { $0 <= Date() } ?? false
        let effectivelySent = row.is_sent || isOverdue

        let status: LoveNoteStatus = effectivelySent
            ? (row.user_id == currentUserId ? .sent : .received)
            : .scheduled

        let isSender = (row.user_id == currentUserId)

        return LoveNote(
            id: row.love_note_id,
            relationshipId: row.relationship_id,
            senderUserId: row.user_id,
            receiverUserId: row.partner_user_id,
            message: row.message,
            createdAt: row.created_at,
            scheduledDate: row.scheduled_for,
            reaction: row.reaction,
            reactedAt: row.reacted_at,
            isSent: effectivelySent,
            status: status,
            isSender: isSender
        )
    }
}
extension LoveNote {
    var statusText: String {
        status.displayText
    }

    var timeText: String {
        switch status {
        case .scheduled:
            return scheduledRelativeText
        default:
            return createdAt.timeAgoText
        }
    }

    var scheduledRelativeText: String {
        guard let date = scheduledDate else { return "" }
        let calendar = Calendar.current
        if calendar.isDateInToday(date) { return "Today" }
        if calendar.isDateInTomorrow(date) { return "Tomorrow" }
        if calendar.isDate(date, equalTo: Date(), toGranularity: .weekOfYear) { return "This Week" }
        return "Later"
    }

    var scheduledFullDateText: String {
        guard let date = scheduledDate else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM, h:mm a"
        return formatter.string(from: date)
    }
}
struct LoveNoteReactionUpdate: Encodable {
    let reaction: String
    let reacted_at: String
}

struct LoveNoteScheduleUpdate: Encodable {
    let scheduled_for: String
    let is_sent: Bool
}
struct NotificationSender: Decodable {
    let name: String?
}

struct NotificationInsert: Encodable {
    let relationship_id: String
    let sender_user_id: String
    let receiver_user_id: String
    let type: String
    let message: String
    let entity_type: String?
    let entity_id: String?
}

struct NotificationRow: Decodable {
    let notification_id: UUID
    let sender_user_id: UUID
    let receiver_user_id: UUID
    let type: String
    let message: String
    let is_read: Bool
    let created_at: Date
    let entity_id: String?
    let entity_type: String?
    let sender: NotificationSender?
}
enum NotificationType: String {
    case activityStarted = "activity_started"
    case loveNoteSent = "love_note_sent"
    case memoryAdded = "memory_added"
    case moodUpdated = "mood_updated"
    case nudgeSent = "nudge_sent"
    case loveTipCompleted = "love_tip_completed"
    case loveTipReacted = "love_tip_reacted"
    case feedbackCompleted = "feedback_completed"
    
    var titleText: String {
        switch self {
        case .activityStarted: return "ACTIVITY ALERT"
        case .loveNoteSent: return "LOVE NOTE"
        case .memoryAdded: return "MEMORY ALERT"
        case .moodUpdated: return "MOOD UPDATE"
        case .nudgeSent: return "SWEET NUDGE"
        case .loveTipCompleted: return "LOVE TIP COMPLETED"
        case .loveTipReacted: return "REACTION RECEIVED"
        case .feedbackCompleted: return "FEEDBACK COMPLETED"
        }
    }

    var iconName: String {
        switch self {
        case .activityStarted: return "checklist"
        case .loveNoteSent: return "heart.text.square"
        case .memoryAdded: return "photo.on.rectangle"
        case .moodUpdated: return "face.smiling"
        case .nudgeSent: return "heart.fill"
        case .loveTipCompleted: return "lightbulb.max.fill"
        case .loveTipReacted: return "heart.text.square.fill"
        case .feedbackCompleted: return "checkmark.message.fill"
        }
    }
}
struct AppNotification {
    let id: UUID
    let senderName: String
    let message: String
    let type: NotificationType
    let createdAt: Date
    var isRead: Bool

    let entityId: String?
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

struct DBCoupleActivity: Codable {
    let coupleActivityId: UUID
    let relationshipId: UUID
    let activityId: Int?
    let activityName: String
    let status: String
    let startedBy: UUID
    let startedAt: Date
    let scheduledDate: Date?
    let feedbackADone: Bool
    let feedbackBDone: Bool
    let completedAt: Date?
    let isCustom: Bool
    let description: String?

    enum CodingKeys: String, CodingKey {
        case coupleActivityId = "couple_activity_id"
        case relationshipId = "relationship_id"
        case activityId = "activity_id"
        case activityName = "activity_name"
        case status
        case startedBy = "user_id"
        case startedAt = "started_at"
        case scheduledDate = "scheduled_date"
        case feedbackADone = "feedback_a_done"
        case feedbackBDone = "feedback_b_done"
        case completedAt = "completed_at"
        case isCustom = "is_custom"
        case description
    }
}

struct DBActivityFeedback: Codable {
    let feedbackId: UUID
    let coupleActivityId: UUID
    let userAId: UUID?
    let userAMood: String?
    let userAMessage: String?
    let userATags: [String]?
    let userAScore: Int?
    let userBId: UUID?
    let userBMood: String?
    let userBMessage: String?
    let userBTags: [String]?
    let userBScore: Int?
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case feedbackId = "feedback_id"
        case coupleActivityId = "couple_activity_id"
        case userAId = "user_a_id"
        case userAMood = "user_a_mood"
        case userAMessage = "user_a_message"
        case userATags = "user_a_tags"
        case userAScore = "user_a_score"
        case userBId = "user_b_id"
        case userBMood = "user_b_mood"
        case userBMessage = "user_b_message"
        case userBTags = "user_b_tags"
        case userBScore = "user_b_score"
        case createdAt = "created_at"
    }
}

struct CoupleActivityInsert: Encodable {
    let relationshipId: UUID
    let activityId: Int?
    let activityName: String
    let status: String
    let startedBy: UUID
    let scheduledDate: Date?
    let isCustom: Bool
    let description: String?

    enum CodingKeys: String, CodingKey {
        case relationshipId = "relationship_id"
        case activityId = "activity_id"
        case activityName = "activity_name"
        case status
        case startedBy = "user_id"
        case scheduledDate = "scheduled_date"
        case isCustom = "is_custom"
        case description
    }
}

/// Single payload struct for both insert and update.
/// Uses `encodeIfPresent` so only the submitting user's fields
/// are included — the other user's data is never overwritten.
struct ActivityFeedbackPayload: Encodable {
    var coupleActivityId: UUID?
    var userAId: UUID?
    var userAMood: String?
    var userAMessage: String?
    var userATags: [String]?
    var userAScore: Int?
    var userBId: UUID?
    var userBMood: String?
    var userBMessage: String?
    var userBTags: [String]?
    var userBScore: Int?

    enum CodingKeys: String, CodingKey {
        case coupleActivityId = "couple_activity_id"
        case userAId = "user_a_id"
        case userAMood = "user_a_mood"
        case userAMessage = "user_a_message"
        case userATags = "user_a_tags"
        case userAScore = "user_a_score"
        case userBId = "user_b_id"
        case userBMood = "user_b_mood"
        case userBMessage = "user_b_message"
        case userBTags = "user_b_tags"
        case userBScore = "user_b_score"
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(coupleActivityId, forKey: .coupleActivityId)
        try container.encodeIfPresent(userAId, forKey: .userAId)
        try container.encodeIfPresent(userAMood, forKey: .userAMood)
        try container.encodeIfPresent(userAMessage, forKey: .userAMessage)
        try container.encodeIfPresent(userATags, forKey: .userATags)
        try container.encodeIfPresent(userAScore, forKey: .userAScore)
        try container.encodeIfPresent(userBId, forKey: .userBId)
        try container.encodeIfPresent(userBMood, forKey: .userBMood)
        try container.encodeIfPresent(userBMessage, forKey: .userBMessage)
        try container.encodeIfPresent(userBTags, forKey: .userBTags)
        try container.encodeIfPresent(userBScore, forKey: .userBScore)
    }
}

