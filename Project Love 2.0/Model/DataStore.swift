//
//  DataStore.swift
//  Project Love 2.0
//
//  Created by SDC-USER on 26/11/25.
//
import Foundation
import Supabase
import UIKit

class DataStore {
    
    static let shared = DataStore()
    
    var activities: [Activity] = []
    var rewards: [Reward] = []
    var customActivities: [Activity] = []
    var activityCategory: [ActivityCategory] = []
    var coupleActivities: [DBCoupleActivity] = []
    
    var suggestedActivities: [Activity] = []
    var buildYourBond : [BuildYourBond] = []
    var bondpage: [BuildYourBondpage] = []
    var tips: [Tip] = []
    
    var moods: [MoodCheckIn] = []
    var moodOptions: [Mood] = []
    
    var smallmodal: [SmallModalData] = []
    var steps: [StepsToFollow] = []
    
    var questions: [Question] = []
    
    var savedMemories: [Memory] = []
    var personalInfoSections: [PersonalInfoSection] = []
    var userProfile: UserProfile?
    var profileSections: [ProfileSection] = []
    
    var currentQnA: QnAData = QnAData( title: "", questions: [QnAQuestion(questionText: "", options: [] )])
    var dailyCheckInQuestions: [Question] = []
    private var lastDailyCheckInSelection: DailyCheckInSelection?

    var specialDates: [SpecialDate] = []
    
    var currentUserId: UUID?
    var currentRelationshipId: UUID?
    var partnerUserId: UUID?

    private(set) var allActivities: [Activity] = []
    private var bondJSONActivities: [JSONActivity] = []
    private var exploreJSONActivities: [JSONActivity] = []
    private(set) var suggestedJSONActivities: [JSONActivity] = []
    private var HisMood: Mood?
    
    private var HerMood: Mood? = Mood(id: -1, title: "Calm", imageName: "Calm" )
    private(set) var notifications: [AppNotification] = []
    private(set) var savedFeedback: [FeedBackGiven] = []
    
    lazy var groupedSuggestedActivities: [SuggestionGroup: [Activity]] = makeGroupedSuggestedActivities()
    private var lastSuggestionGroup: SuggestionGroup?
    private var partnerAssessmentPreferences: [Int: Set<Int>]?

  
    init() {
        loadSampleData()
        loadSampleRewards()
        loadSampleTips()
        moods = sampleMoods()
        loadSmallModalData()
        moodOptions = loadMoodOptions()
        loadSampleQuestions()
        loadsampleBuildYourBond()
        loadPersonalInfoData()
        loadProfileData()
        let _ = groupedSuggestedActivities // force load
        buildAllActivities()
        loadDailyCheckInQuestions()
        loadOnboardingQnA()
    }

    /// Clears all user session data — call after sign out or account deletion.
    func clearSession() {
        currentUserId       = nil
        currentRelationshipId = nil
        partnerUserId       = nil
        userProfile         = nil
        specialDates        = []
        customActivities    = []
        activities          = []
        coupleActivities    = []
        notifications       = []
        profileSections     = []
    }

    private func makeGroupedSuggestedActivities() -> [SuggestionGroup: [Activity]] {
        guard let url = Bundle.main.url(forResource: "suggestedActivity", withExtension: "json") else {
            return [:]
        }
        
        do {
            let data = try Data(contentsOf: url)
            let parsed = try JSONDecoder().decode(ActivitiesJSON.self, from: data)
            self.suggestedJSONActivities = parsed.activities
            
            var grouped: [SuggestionGroup: [Activity]] = [:]
            
            for json in parsed.activities {
                // Ensure the category string correctly maps to the SuggestionGroup Enum
                let categoryStr = json.category.replacingOccurrences(of: "Group ", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                
                guard let group = SuggestionGroup(rawValue: categoryStr) else {
                    continue
                }
                
                let activity = Activity(
                    id: json.id,
                    name: json.name,
                    description: json.description,
                    detailedDescription: json.detailedDescription,
                    image: json.image,
                    time: json.time,
                    status: .none,
                    category: json.category,
                    scheduledDate: nil,
                        steps: json.steps
                )
                
                if grouped[group] != nil {
                    grouped[group]?.append(activity)
                } else {
                    grouped[group] = [activity]
                }
            }
                return grouped
            } catch {
                return [:]
            }

        }
    func resolveSuggestionGroup(selection: DailyCheckInSelection) -> SuggestionGroup {
            let mood = normalize(selection.mood)
            let closeness = normalize(selection.closeness) // disconnected/chill/attached/kinda close/very distant/very close/somewhat close/a bit distant
            let vibe = normalize(selection.vibe)           // dry/meh/synced/vibing/smooth/neutral/a little off/tense
            let need = normalize(selection.need)           // reassurance/quality time/space/deep convo/comfort/connection/fun

            let isVeryClose = (closeness == "attached" || closeness == "very close")
            let isSomewhatClose = (closeness == "kinda close" || closeness == "chill" || closeness == "somewhat close")
            let isBitDistant = (closeness == "a bit distant")
            let isVeryDistant = (closeness == "disconnected" || closeness == "very distant")

            let isSmooth = (vibe == "synced" || vibe == "vibing" || vibe == "smooth")
            let isNeutral = (vibe == "meh" || vibe == "neutral")
            let isLittleOff = (vibe == "dry" || vibe == "a little off")
            let isTense = (vibe == "tense")

            let isComfort = (need == "reassurance" || need == "comfort")
            let isConnection = (need == "quality time" || need == "deep convo" || need == "connection")
            let isFun = (need == "fun")
            let isSpace = (need == "space")

            // EDGE CASES
            // Case 1: Positive but very distant + comfort => Group I
            if ["joyful", "playful", "satisfied", "adventurous", "calm", "peaceful", "productive", "curious", "determined"].contains(mood),
               isVeryDistant,
               isComfort {
                return .I
            }
            
            // Case 2: Angry but need connection => Group G
            if mood == "angry",
               (isSomewhatClose || isVeryClose),
               isTense,
               isConnection {
                return .G
            }
            
            // Case 3: Drained but wants fun => Group A (Positive & Aligned via Need override)
            if mood == "drained",
               (isVeryClose || isSomewhatClose),
               isFun {
                return .A // The rules say "Covered under Positive but Low Energy -> reclassified via Need override"
            }
            
            // Case 4: Attached + very close + smooth + space => Group E
            if mood == "attached",
               isVeryClose,
               isSmooth,
               isSpace {
                return .E
            }
            
            // Case 5: Calm + very distant + fun => Group J
            if mood == "calm",
               isVeryDistant,
               isNeutral,
               isFun {
                return .J
            }
            

            // STANDARD RULES
            // GROUP G: Tense but Still Engaged
            if ["angry", "regretful", "disappointed"].contains(mood),
               (isVeryClose || isSomewhatClose),
               isTense,
               (isComfort || isSpace) {
                return .G
            }

            // GROUP E: Close but Overstimulated
            if ["drained", "peaceful"].contains(mood),
               (isVeryClose || isSomewhatClose),
               (isNeutral || isSmooth),
               isSpace {
                return .E
            }

            // GROUP I: Distant & Self-Preserving
            if ["drained", "angry", "disappointed"].contains(mood),
               isVeryDistant,
               (isLittleOff || isTense),
               isSpace {
                return .I
            }
            
            // GROUP J: Distant but Playful Reach
            if ["playful", "curious"].contains(mood),
               isBitDistant,
               isNeutral,
               isFun {
                return .J
            }

            // GROUP H: Distant but Wanting Repair
            if ["sad", "curious", "regretful"].contains(mood),
               isBitDistant,
               (isNeutral || isLittleOff),
               isConnection {
                return .H
            }

            // GROUP F: Attached but Insecure
            if mood == "attached",
               (isSomewhatClose || isBitDistant),
               (isNeutral || isLittleOff),
               (isComfort || isConnection) {
                return .F
            }

            // GROUP D: Close but Emotionally Off
            if ["calm", "curious", "regretful", "attached"].contains(mood),
               isVeryClose,
               isLittleOff,
               (isConnection || isComfort) {
                return .D
            }

            // GROUP A: Positive & Aligned
            if ["joyful", "playful", "satisfied", "adventurous"].contains(mood),
               (isVeryClose || isSomewhatClose),
               isSmooth,
               (isFun || isConnection) {
                return .A
            }

            // GROUP B: Calm & Stable
            if ["calm", "peaceful", "productive"].contains(mood),
               (isSmooth || isNeutral),
               isConnection {
                return .B
            }

            // GROUP C: Curious / Growth-Oriented
            if ["curious", "determined", "productive"].contains(mood),
               isNeutral,
               (isConnection || isFun) {
                return .C
            }

            // Catch-alls
            if isSpace { return .E }
            if isTense { return .G }
            if isVeryDistant { return .I }
            if isBitDistant { return .H }
            return .B
        }
    
        @discardableResult
        func getSuggestedActivitiesForDailyCheckIn(selection: DailyCheckInSelection, limit: Int = 3) -> [Activity] {
            lastDailyCheckInSelection = selection
            let group = resolveSuggestionGroup(selection: selection)
            lastSuggestionGroup = group
            let pool = groupedSuggestedActivities[group] ?? Array(groupedSuggestedActivities.values.flatMap { $0 })
            let shuffledPool = pool.shuffled()
            let result = Array(shuffledPool.prefix(limit))
            self.suggestedActivities = result
            return result
        }
    private func preferredNeed(from tags: [String]) -> String? {
        // Priority: Connecting > Relaxing > Fun
        if tags.contains("Connecting") { return "connection" }
        if tags.contains("Relaxing") { return "space" }
        if tags.contains("Fun") { return "fun" }
        return nil
    }
    private func negativeNeedOverride(from tags: [String]) -> String? {
        if tags.contains("Not my thing") || tags.contains("Boring") { return "space" }
        return nil
    }
    private func pairMood(from feedback: DBActivityFeedback?, fallback: String) -> String {
        let moods = [feedback?.userAMood, feedback?.userBMood].compactMap { $0 }
        if moods.isEmpty { return fallback }

        let negative = ["angry", "regretful", "disappointed", "sad", "drained"]
        if let m = moods.first(where: { negative.contains($0.lowercased()) }) {
            return m
        }
        return moods[0]
    }
    func refreshSuggestionsAfterFeedback(coupleActivityId: UUID, limit: Int = 3) async -> [Activity] {
        let feedback = try? await SupabaseManager.shared.fetchFeedbackForActivity(coupleActivityId: coupleActivityId)

        let base = lastDailyCheckInSelection ?? DailyCheckInSelection(
            mood: "Calm",
            closeness: "Chill",
            vibe: "Neutral",
            need: "Connection"
        )

        let updatedMood = pairMood(from: feedback, fallback: base.mood)

        let tags = (feedback?.userATags ?? []) + (feedback?.userBTags ?? [])
        let needOverride = preferredNeed(from: tags) ?? negativeNeedOverride(from: tags)

        let newSelection = DailyCheckInSelection(
            mood: updatedMood,
            closeness: base.closeness,
            vibe: base.vibe,
            need: needOverride ?? base.need
        )

        let group = resolveSuggestionGroup(selection: newSelection)
        lastSuggestionGroup = group

        let pool = groupedSuggestedActivities[group] ?? Array(groupedSuggestedActivities.values.flatMap { $0 })

        // Exclude the last activity if you want
        let filtered = pool.filter { $0.coupleActivityId != coupleActivityId }
        let result = Array(filtered.shuffled().prefix(limit))

        self.suggestedActivities = result
        return result
    }

    private func normalize(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    
    func getDailyCheckInQuestion(at index: Int) -> Question? {
            guard index >= 0 && index < dailyCheckInQuestions.count else { return nil }
            return dailyCheckInQuestions[index]
        }
    // Notification
    func addNotification(_ notification: AppNotification) {
        notifications.insert(notification, at: 0)
    }

    func getNotifications() -> [AppNotification] {
        notifications
    }
    func markNotificationAsRead(id: UUID) {
        if let index = notifications.firstIndex(where: { $0.id == id }) {
            notifications[index].isRead = true
        }
    }
    func loadOnboardingQnA() {
        currentQnA = QnAData(
            title: "Tell us about you",
            questions: [

                // Gender
                QnAQuestion(
                    questionText: "What’s your gender?",
                    options: [
        QnAOption(text: "Male", isSelected: false),
        QnAOption(text: "Female", isSelected: false)
                    ]
                ),

                // Love Language
                QnAQuestion(
        questionText: "What’s your love language?",
        options: [
        QnAOption(text: "Acts of service", isSelected: false),
        QnAOption(text: "Small gestures", isSelected: false),
        QnAOption(text: "Quality time", isSelected: false),
        QnAOption(text: "Physical touch", isSelected: false),
        QnAOption(text: "Words of affirmation", isSelected: false)
        ]
                ),

                // Relationship Type
                QnAQuestion(
                    questionText: "What’s your relationship type?",
                    options: [
        QnAOption(text: "Dating", isSelected: false),
        QnAOption(text: "Situationship", isSelected: false),
        QnAOption(text: "Live-In relationship", isSelected: false),
        QnAOption(text: "Long-Distance relationship", isSelected: false),
        QnAOption(text: "Married", isSelected: false)
                    ]
                ),

                // Feeling cared
                QnAQuestion(
        questionText: "What makes you feel cared?",
        options: [
        QnAOption(text: "Encouragement", isSelected: false),
        QnAOption(text: "Surprises", isSelected: false),
        QnAOption(text: "Quality time", isSelected: false),
        QnAOption(text: "Acts of service", isSelected: false),
        QnAOption(text: "Validation", isSelected: false),
        QnAOption(text: "Small gifts", isSelected: false),
        QnAOption(text: "Compliments", isSelected: false)
        ]
                )
            ]
        )
    }
    
    // update mood
    func saveFeedback(_ feedback: FeedBackGiven) {
            savedFeedback.append(feedback)
        }

    private func mood(by id: Int) -> Mood? {
        moodOptions.first { $0.id == id }
    }
    
    //custom activity — inserts into couple_activities with is_custom = true
    func addCustomActivity(name: String, description: String, date: String, scheduledDate: Date = Date()) {
        guard let relationshipId = currentRelationshipId,
              let userId = currentUserId else {
            // Fallback: local only
            let newActivity = Activity(
                name: name,
                description: description,
                image: "Activityimage",
                time: date,
                status: .none,
                category: "Custom"
            )
            customActivities.append(newActivity)
            return
        }

        let insert = CoupleActivityInsert(
            relationshipId: relationshipId,
            activityId: nil,
            activityName: name,
            status: "ongoing",
            startedBy: userId,
            scheduledDate: scheduledDate,
            isCustom: true,
            description: description
        )

        Task {
            do {
                let dbRow: DBCoupleActivity = try await SupabaseManager.shared.client
                    .from("couple_activities")
                    .insert(insert)
                    .select()
                    .single()
                    .execute()
                    .value

                let newActivity = Activity(
                    coupleActivityId: dbRow.coupleActivityId,
                    name: dbRow.activityName,
                    description: dbRow.description ?? description,
                    image: "Activityimage",
                    time: date,
                    status: .ongoing,
                    category: "Custom"
                )
                DispatchQueue.main.async {
                    self.customActivities.append(newActivity)
                    NotificationCenter.default.post(name: .activitiesSynced, object: nil)
                }
            } catch {
                print("Failed to save custom activity: \(error)")
                // Fallback to local
                let newActivity = Activity(
                    name: name,
                    description: description,
                    image: "Activityimage",
                    time: date,
                    status: .none,
                    category: "Custom"
                )
                DispatchQueue.main.async {
                    self.customActivities.append(newActivity)
                }
            }
        }
    }
    
    func loadSampleData() {
        // Load from activities.json ONLY
        guard let url = Bundle.main.url(forResource: "activities", withExtension: "json") else {
            return
        }

        let parsed: ActivitiesJSON
        do {
            let data = try Data(contentsOf: url)
            parsed = try JSONDecoder().decode(ActivitiesJSON.self, from: data)
        } catch {
            return
        }

        // Store raw JSON activities (with steps) for loadSteps() lookups
        self.exploreJSONActivities = parsed.activities

        self.activities = parsed.activities.map { json in
            Activity(
                id: json.id,
                coupleActivityId: nil,
                name: json.name,
                description: json.description,
                detailedDescription: json.detailedDescription,
                image: json.image,
                time: json.time,
                status: .none,
                category: json.category,
                scheduledDate: nil
            )
        }
    }
    func loadDailyCheckInQuestions() {
        let sampleQuestions: [Question] = [
            Question(title: "How connected do you feel right now?", options: ["Dry","Meh","Synced","Vibing"])
            ,
            Question(title: "What’s missing in your relationship rn?", options: ["Reassurance","Quality time","Space","Deep Convo"]),
            Question(title: "How strong is your connection with your partner currently?", options: ["Disconnected","Chill","Attached","Kinda close"])
        ]
        self.dailyCheckInQuestions = sampleQuestions
    }


 
    func getRefreshSuggestedActivities() -> [Activity] {
        guard lastSuggestionGroup != nil else { return [] }
        let newBatch = getMoreActivities(excluding: self.suggestedActivities)
        guard !newBatch.isEmpty else { return self.suggestedActivities }
        // Append to existing activities, cap at 6
        let combined = self.suggestedActivities + newBatch
        self.suggestedActivities = Array(combined.prefix(6))
        return self.suggestedActivities
    }
    
    func getSmallModalData(for activity: Activity) -> SmallModalData {
        // If activity has a detailedDescription (from JSON), use it for the modal
        if let detailed = activity.detailedDescription, !detailed.isEmpty {
            return SmallModalData(
                title: activity.name,
                mainImageName: activity.image,
                descriptionLabel: detailed,
                clockImageName: "clock",
                timerLabel: activity.time
            )
        }

        // Otherwise check hardcoded smallmodal data
        if let existing = smallmodal.first(where: { $0.title == activity.name }) {
            return existing
        }

        // Fallback: use activity.description
        return SmallModalData(
            title: activity.name,
            mainImageName: activity.image,
            descriptionLabel: activity.description,
            clockImageName: "clock",
            timerLabel: activity.time
        )
    }
    func getSteps(for activity: Activity) -> [StepsToFollow] {
            if let jsonSteps = activity.steps, !jsonSteps.isEmpty {
                return jsonSteps.enumerated().map { index, stepStr in
                    var titleStr = "Step \(index + 1)"
                    var descStr = stepStr
                    
                    let cleanStepStr = stepStr.replacingOccurrences(of: "^\\d+\\.\\s*", with: "", options: .regularExpression)
                    let parts = cleanStepStr.split(separator: ".", maxSplits: 1)
                    
                    if parts.count == 2 {
                        titleStr = String(parts[0]).trimmingCharacters(in: .whitespaces)
                        descStr = String(parts[1]).trimmingCharacters(in: .whitespaces)
                        if !descStr.hasSuffix(".") && !descStr.isEmpty {
                            descStr += "."
                        }
                    } else {
                        descStr = cleanStepStr
                    }
                    
                    return StepsToFollow(number: index + 1, title: titleStr, descriptionLabel: descStr)
                }
            }

            let mapped = loadSteps(for: activity.name)
            if !mapped.isEmpty { return mapped }

            return [
                StepsToFollow(number: 1, title: "Set intention", descriptionLabel: "Start with: \"What do we need right now?\""),
                StepsToFollow(number: 2, title: "Do the activity", descriptionLabel: activity.description),
                StepsToFollow(number: 3, title: "Reflect", descriptionLabel: "Share one line: \"This felt ___ for me.\"")
    ]
    }

    
    func getMoreActivities(excluding current: [Activity]) -> [Activity] {
            guard let group = lastSuggestionGroup else { return [] }
            let sourcePool = groupedSuggestedActivities[group] ?? Array(groupedSuggestedActivities.values.flatMap { $0 })
            
            let currentNames = Set(current.map { $0.name.lowercased() })
            let remaining = sourcePool.filter { new in
                !currentNames.contains(new.name.lowercased())
            }
            
            if remaining.count >= 3 {
                return Array(remaining.shuffled().prefix(3))
            } else if !remaining.isEmpty {
                return remaining.shuffled()
            } else {
                // All exhausted — pick 3 from the full pool that aren't already shown
                return Array(sourcePool.shuffled().prefix(3))
            }
        }

    func getActivities(forCategoryName name: String) -> [Activity] {
            return activities.filter { $0.category == name }
        }
    func loadActivityCategory() {
        let sampleCategory: [ActivityCategory] = [
            ActivityCategory(name: "Fun & Playful", description: "Turn your ‘meh’ days into mini adventures.", image: "Fun&Playful"),
            ActivityCategory(name: "Spice It Up!", description: "Turn up the spark and keep the chemistry alive.", image: "SpiceItUp"),
            ActivityCategory(name: "No Filter Chats", description: "Builds trust, real talk, and emotional ick-proofing.", image: "NoFilterChats"),
            ActivityCategory(name: "Acts of Love", description: "Keeps the romance alive through sweet gestures.", image: "ActsOfLove"),
            ActivityCategory(name: "Daily Dose of Us", description: "Keeps the “everyday” feeling special.", image: "DailyDoseOfUs"),
            ActivityCategory(name: "Meaning & Growth", description: "Nurtures emotional maturity and personal growth.", image: "Meaning&Growth")
        ]
        self.activityCategory = sampleCategory
    }
    
    
    //profile
    func loadPersonalInfoData() {
        personalInfoSections = [
            PersonalInfoSection(
                title: "Basic Information",
                items: [
                    PersonalInfoItem(title: "Full Name", value: "Name", showsChevron: false),
                    PersonalInfoItem(title: "Email", value: "name@email.com", showsChevron: false),
                    PersonalInfoItem(title: "Date of Birth", value: "12 Jan 2003", showsChevron: false)
                ]
            ),
            PersonalInfoSection(
                title: "Onboarding Details",
                items: [
                    PersonalInfoItem(title: "Edit Preferences", value: "", showsChevron: true)
                ]
            )
        ]
    }
    
    func loadProfileData() {
        if userProfile == nil {
            userProfile = UserProfile(
                name: "Name",
                email: "name@email.com",
                profileImageName: "Profile",
                savedPreferences: [:]
            )
        }

        if profileSections.isEmpty {
            profileSections = [
                ProfileSection(
                    title: "Account",
                    items: [
                        ProfileItem(title: "Personal Info", iconName: "slider.horizontal.3", showsChevron: true)
                    ]
                ),
                ProfileSection(
                    title: "Relationship Profile",
                    items: [
                        ProfileItem(title: "Special Dates", iconName: "slider.horizontal.3", showsChevron: true),
                        ProfileItem(title: "Partner Pairing", iconName: "slider.horizontal.3", showsChevron: true)
                    ]
                ),
                ProfileSection(
                    title: "Support",
                    items: [
                        ProfileItem(title: "Help & Support", iconName: "questionmark.circle", showsChevron: true),
                        ProfileItem(title: "About App", iconName: "info.circle", showsChevron: true),
                        ProfileItem(title: "Feedback", iconName: "bubble.left", showsChevron: true)
                    ]
                ),
                ProfileSection(
                    title: "",
                    items: [
                        ProfileItem(title: "Sign Out", iconName: "rectangle.portrait.and.arrow.right", showsChevron: false),
                        ProfileItem(title: "Delete Account", iconName: "trash", showsChevron: false)
                    ]
                )
            ]
        }
    }

    private struct UserProfileRow: Decodable {
        let name: String?
        let birth_date: String?
        let gender: String?
        let assessment_answers: [String: [Int]]?
    }

    private struct ProfileUpdatePayload: Encodable {
        let name: String
        let birth_date: String
    }

     var partnerPronoun: String {
        let gender = UserDefaults.standard.string(forKey: "userGender")?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased() ?? ""
        switch gender {
        case "male":   return "her"
        case "female": return "him"
        default:       return "them"
        }
    }
    var partnerPossessivePronoun: String {
        switch partnerPronoun {
        case "her": return "her"
        case "him": return "his"
            default: return "their"
        }
    }
    var partnerDisplayText: String {
        switch partnerPronoun {
        case "her": return "Her"
        case "him": return "Him"
        default: return "Partner"
        }
    }

    func refreshUserProfileFromSupabase() async {
        guard let authUser = SupabaseManager.shared.client.auth.currentUser else { return }
        currentUserId = authUser.id

        do {
            let rows: [UserProfileRow] = try await SupabaseManager.shared.client
                .from("users")
                .select("name, birth_date, gender, assessment_answers")
                .eq("user_id", value: authUser.id.uuidString)
                .limit(1)
                .execute()
                .value

            guard let row = rows.first else { return }

            let name = (row.name?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false)
                ? row.name!
                : "Name"
            let email = authUser.email ?? "name@email.com"
            let prefs = mapAssessmentAnswers(row.assessment_answers)

            if userProfile == nil {
                userProfile = UserProfile(name: name, email: email, profileImageName: "Profile", savedPreferences: prefs)
            } else {
                userProfile?.name = name
                userProfile?.email = email
                userProfile?.savedPreferences = prefs
            }

            setPersonalInfoValue(title: "Full Name", value: name)
            setPersonalInfoValue(title: "Email", value: email)

            let dobText = profileDOBText(from: row.birth_date)
            if !dobText.isEmpty {
                setPersonalInfoValue(title: "Date of Birth", value: dobText)
            }

            if let gender = row.gender?.trimmingCharacters(in: .whitespacesAndNewlines), !gender.isEmpty {
                UserDefaults.standard.set(gender, forKey: "userGender")
            }
            reloadGenderDependentContent()
        } catch {
        }
    }

    func applyLocalBasicInfo(name: String, email: String?, birthDate: Date) {
        let emailValue = (email?.isEmpty == false) ? email! : "name@email.com"
        let dob = profileDOBFormatter.string(from: birthDate)

        if userProfile == nil {
            userProfile = UserProfile(name: name, email: emailValue, profileImageName: "Profile", savedPreferences: [:])
        } else {
            userProfile?.name = name
            userProfile?.email = emailValue
        }

        setPersonalInfoValue(title: "Full Name", value: name)
        setPersonalInfoValue(title: "Email", value: emailValue)
        setPersonalInfoValue(title: "Date of Birth", value: dob)
    }

    private var profileDOBFormatter: DateFormatter {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "dd/MM/yyyy"
        return f
    }

    private func profileDOBText(from raw: String?) -> String {
        guard let raw, !raw.isEmpty else { return "" }
        let parser = DateFormatter()
        parser.locale = Locale(identifier: "en_US_POSIX")

        for format in ["yyyy-MM-dd", "yyyy-MM-dd'T'HH:mm:ss.SSSSSSXXXXX", "yyyy-MM-dd'T'HH:mm:ssXXXXX"] {
            parser.dateFormat = format
            if let date = parser.date(from: raw) {
                return profileDOBFormatter.string(from: date)
            }
        }
        return raw
    }

    private func mapAssessmentAnswers(_ answers: [String: [Int]]?) -> [Int: Set<Int>] {
        guard let answers else { return [:] }
        var mapped: [Int: Set<Int>] = [:]
        for (k, v) in answers {
            if let idx = Int(k) { mapped[idx] = Set(v) }
        }
        return mapped
    }

    private func setPersonalInfoValue(title: String, value: String) {
        for sectionIndex in personalInfoSections.indices {
            if let itemIndex = personalInfoSections[sectionIndex].items.firstIndex(where: { $0.title == title }) {
                personalInfoSections[sectionIndex].items[itemIndex].value = value
            }
        }
    }

    /// Persist name, email, and DOB edits to the Supabase `users` table.
    func updateProfileInSupabase(name: String, email: String, dob: Date) {
        guard let userId = SupabaseManager.shared.currentUserId else { return }

        let dobString = profileDOBFormatter.string(from: dob)

        // Convert dd/MM/yyyy → yyyy-MM-dd for Supabase
        let isoFormatter = DateFormatter()
        isoFormatter.locale = Locale(identifier: "en_US_POSIX")
        isoFormatter.dateFormat = "yyyy-MM-dd"
        let isoDOB = isoFormatter.string(from: dob)

        Task {
            do {
                let payload = ProfileUpdatePayload(name: name, birth_date: isoDOB)
                try await SupabaseManager.shared.client
                    .from("users")
                    .update(payload)
                    .eq("user_id", value: userId.uuidString)
                    .execute()
            } catch {
            }
        }
    }

    /// Rebuilds gender-dependent content (tips) after a gender preference change.
    func reloadGenderDependentContent() {
        loadSampleTips()
    }

    
    
    func loadSampleQuestions () {
        let sampleQuestions: [Question] = [
            Question(
                       title: "How close do you feel to your partner today so far?",
                       options: ["Very close", "Somewhat close", "A bit distant", "Very distant"]
                   ),

                   Question(
                       title: "How has your vibe been with each other today so far?",
                       options: ["Smooth", "Neutral", "A little off", "Tense"]
                   ),

                   Question(
                       title: "What do you feel you need from your partner right now?",
                       options: ["Comfort", "Connection", "Fun", "Space"]
                   ),

                   Question(
                       title: "How open are you to doing something together right now?",
                       options: ["Very open", "Somewhat open", "Not right now, but later", "Not in the mood"]
                   )
               ]
        self.questions = sampleQuestions
    }
    
    //rewards
    func loadSampleRewards() {
        let sampleRewards: [Reward] = [
            Reward(image: "Send_Hug", name: "Hug", emoji: "🤗", progressStep: 0),
            Reward(image: "Send_Flower", name: "Flower", emoji: "🌻", progressStep: 0),
            Reward(image: "Send_Kiss", name: "Kiss", emoji: "😘", progressStep: 0),
            Reward(image: "Send_Heart", name: "Heart", emoji: "🫶🏻", progressStep: 0),
            Reward(image: "Send_Note", name: "Note", emoji: "💌", progressStep: 0),
            Reward(image: "Send_Wave", name: "Wave", emoji: "👋", progressStep: 0),
            Reward(image: "Send_Hug", name: "High five", emoji: "🙌", progressStep: 0)
        ]
        
        self.rewards = sampleRewards
    }
    
    //love tips
    func loadSampleTips() {
        self.tips = jsonBackedLoveTips()
    }
    
    func getAllTips() -> [Tip] {
        tips.isEmpty ? jsonBackedLoveTips() : tips
    }
    func loadPersonalizedLoveTips() async -> [Tip] {
        let partnerPreferences = await fetchPartnerAssessmentPreferences()
        let personalized = personalizedLoveTips(from: partnerPreferences)
        let resolvedTips = personalized.isEmpty ? jsonBackedLoveTips() : personalized
        self.tips = resolvedTips
        return resolvedTips
    }

    private struct PartnerAssessmentRow: Decodable {
        let assessment_answers: [String: [Int]]?
    }

    private func fetchPartnerAssessmentPreferences() async -> [Int: Set<Int>] {
        if let partnerAssessmentPreferences {
            return partnerAssessmentPreferences
        }

        if partnerUserId == nil {
            await loadUserContext()
        }

        guard let partnerUserId else { return [:] }

        do {
            let rows: [PartnerAssessmentRow] = try await SupabaseManager.shared.client
                .from("users")
                .select("assessment_answers")
                .eq("user_id", value: partnerUserId.uuidString)
                .limit(1)
                .execute()
                .value

            let mapped = mapAssessmentAnswers(rows.first?.assessment_answers)
            partnerAssessmentPreferences = mapped
            return mapped
        } catch {
            return [:]
        }
    }

    private func personalizedLoveTips(from preferences: [Int: Set<Int>]) -> [Tip] {
        let payload = loadLoveTipsPayload()
        guard !payload.tips.isEmpty else { return [] }

        let loveLanguage = selectedOptionTexts(for: 1, from: preferences)
        let relationshipType = selectedOptionTexts(for: 2, from: preferences)
        let carePreferences = selectedOptionTexts(for: 3, from: preferences)

        let scored = payload.tips.compactMap { rule -> (LoveTipRule, Int)? in
            let relationshipMatches = rule.relationshipTypes.isEmpty || !relationshipType.isDisjoint(with: Set(rule.relationshipTypes))
            guard relationshipMatches else { return nil }

            var score = 0
            score += matchScore(selected: loveLanguage, candidates: rule.loveLanguages, weight: 3)
            score += matchScore(selected: carePreferences, candidates: rule.carePreferences, weight: 2)
            score += matchScore(selected: relationshipType, candidates: rule.relationshipTypes, weight: 1)

            if score == 0 {
                return nil
            }

            return (rule, score)
        }

        let sortedRules = scored
            .sorted { lhs, rhs in
                if lhs.1 != rhs.1 { return lhs.1 > rhs.1 }
                return lhs.0.id < rhs.0.id
            }
            .map(\.0)

        var seenTitles = Set<String>()
        return sortedRules.compactMap { rule in
            let resolvedTitle = renderLoveTip(rule.title)
            guard seenTitles.insert(resolvedTitle).inserted else { return nil }
            return Tip(title: resolvedTitle)
        }
    }

    private func loadLoveTipsPayload() -> LoveTipsPayload {
        guard let url = Bundle.main.url(forResource: "loveTips", withExtension: "json") else {
            return LoveTipsPayload(tips: [])
        }

        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(LoveTipsPayload.self, from: data)
        } catch {
            return LoveTipsPayload(tips: [])
        }
    }

    private func jsonBackedLoveTips() -> [Tip] {
        let payload = loadLoveTipsPayload()
        let rendered = payload.tips.map { Tip(title: renderLoveTip($0.title)) }
        return rendered.isEmpty ? fallbackLoveTips() : rendered
    }

    private func selectedOptionTexts(for questionIndex: Int, from preferences: [Int: Set<Int>]) -> Set<String> {
        guard currentQnA.questions.indices.contains(questionIndex) else { return [] }
        let options = currentQnA.questions[questionIndex].options
        let selectedIndexes = preferences[questionIndex] ?? []

        return Set(selectedIndexes.compactMap { index in
            guard options.indices.contains(index) else { return nil }
            return options[index].text
        })
    }

    private func matchScore(selected: Set<String>, candidates: [String], weight: Int) -> Int {
        guard !selected.isEmpty, !candidates.isEmpty else { return 0 }
        return selected.intersection(Set(candidates)).count * weight
    }

    private func renderLoveTip(_ title: String) -> String {
        title
            .replacingOccurrences(of: "{partner}", with: partnerPronoun)
            .replacingOccurrences(of: "{partnerPossessive}", with: partnerPossessivePronoun)
            .replacingOccurrences(of: "{Partner}", with: partnerDisplayText.lowercased())
    }

    private func fallbackLoveTips() -> [Tip] {
        [
            Tip(title: renderLoveTip("Bring {partner} a comfort drink without asking.")),
            Tip(title: renderLoveTip("Send {partner} one sincere compliment they can re-read later.")),
            Tip(title: renderLoveTip("Take one task off {partnerPossessive} plate tonight.")),
            Tip(title: renderLoveTip("Stay beside {partner} for 10 quiet minutes without distracting them.")),
            Tip(title: renderLoveTip("Write {partner} a short note saying exactly what you appreciate about them.")),
            Tip(title: renderLoveTip("Plan one small gesture this week that feels personal to {partner}."))
        ]
    }
    //build your bond
    func loadBuildYourbond() -> [BuildYourBond] {
        // Derive BUB category cards from bondActivities.json
        let categoryImageMap: [String: String] = [
            "Navigate Conflict Together": "Conflict",
            "Rekindle Honeymoon Phase": "Rekindle",
            "Establishing Good Communication": "Communication"
        ]

        // Extract unique categories preserving order of first appearance
        var seen = Set<String>()
        var categories: [String] = []
        for activity in bondJSONActivities {
            if !seen.contains(activity.category) {
                seen.insert(activity.category)
                categories.append(activity.category)
            }
        }

        return categories.map { category in
            BuildYourBond(
                name: category,
                imageName: categoryImageMap[category] ?? "Conflict"
            )
        }
    }
    
    func sampleMoods() -> [MoodCheckIn] {
        let mood: [MoodCheckIn] = [
            MoodCheckIn(label: "Me", imageName: "Calm", moodLabel: "Calm"),
            MoodCheckIn(label: "Her", imageName: "Drained", moodLabel: "Drained")
        ]
        return mood
    }

    //steps to follow
    func loadSteps(for activityTitle: String) -> [StepsToFollow] {
        // Check bondActivities JSON first for BUB activities
        if let jsonActivity = bondJSONActivities.first(where: { $0.name == activityTitle }),
           !jsonActivity.steps.isEmpty {
            return parseJSONSteps(jsonActivity.steps)
        }

        // Check explore activities JSON (activities.json) for explore/her/him activities
        if let jsonActivity = exploreJSONActivities.first(where: { $0.name == activityTitle }),
           !jsonActivity.steps.isEmpty {
            return parseJSONSteps(jsonActivity.steps)
        }
        
        // Check suggested activities JSON (suggestedActivity.json)
        if let jsonActivity = suggestedJSONActivities.first(where: { $0.name == activityTitle }),
           !jsonActivity.steps.isEmpty {
            return parseJSONSteps(jsonActivity.steps)
        }

        return []
    }

    /// Parses step strings in "1. Title. Description" format into StepsToFollow objects
    private func parseJSONSteps(_ steps: [String]) -> [StepsToFollow] {
        return steps.enumerated().map { index, stepString in
            let parts = stepString.components(separatedBy: ". ")
            let title: String
            let description: String
            if parts.count >= 3 {
                title = parts[1]
                description = parts.dropFirst(2).joined(separator: ". ")
            } else if parts.count == 2 {
                title = parts[1]
                description = ""
            } else {
                title = stepString
                description = ""
            }
            return StepsToFollow(number: index + 1, title: title, descriptionLabel: description)
        }
    }
    
    func getActivities(for category: ActivityCategory) -> [Activity] {
        return activities.filter { $0.category == category.name }
    }
    
    func loadsampleBuildYourBond() {
        // Try loading bond activities from bondActivities.json
        if let url = Bundle.main.url(forResource: "bondActivities", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let parsed = try? JSONDecoder().decode(ActivitiesJSON.self, from: data) {
            self.bondJSONActivities = parsed.activities
        } else {
        }

        // Helper to get activities for a specific category from JSON
        func activitiesFor(_ category: String) -> [Activity] {
            let jsonFiltered = bondJSONActivities.filter { $0.category == category }
            if !jsonFiltered.isEmpty {
                return jsonFiltered.map { json in
                    Activity(
                        id: json.id,
                        coupleActivityId: nil,
                        name: json.name,
                        description: json.description,
                        detailedDescription: json.detailedDescription,
                        image: json.image,
                        time: json.time,
                        status: .none,
                        category: category,
                        scheduledDate: nil
                    )
                }
            }
            return [] // will use fallback below
        }

        let conflictActivities = activitiesFor("Navigate Conflict Together")
        let communicationActivities = activitiesFor("Establishing Good Communication")
        let rekindleActivities = activitiesFor("Rekindle Honeymoon Phase")

        let bond: [BuildYourBondpage] = [
            BuildYourBondpage(
                Name: "Navigate Conflict Together",
                SubHeading: "Take each step together to rebuild your connection.",
                stepLabel: "You are currently on Step 1: Identifying the Conflict.",
                step: ["Identify", "Empathize", "Solution", "Sustain"],
                activity: conflictActivities,
                badge: "Harmony Seeker",
                badgesubHeading: "Master the art of peaceful resolution.",
                badgeImageName: "HarmonySeekerBadge",
                HIWStep: ["Identify the Conflict", "Empathizing with Perspectives", "Crafting Joint Solutions", "Sustaining Harmony"]
            ),
            BuildYourBondpage(
                Name: "Establishing Good Communication",
                SubHeading: "Clear the static and really hear each other.",
                stepLabel: "You are currently on Step 1: The Battery Check.",
                step: ["Check-in", "Express", "Reflect", "Trust"],
                activity: communicationActivities,
                badge: "Communication Champ",
                badgesubHeading: "You've built a strong foundation of open dialogue.",
                badgeImageName: "communicationChampBadge",
                HIWStep: ["Checking emotional bandwidth", "Expressing needs clearly", "Active listening", "Creating emotional safety"]
            ),
            BuildYourBondpage(
                Name: "Rekindle Honeymoon Phase",
                SubHeading: "Bring back the spark and beat roommate mode.",
                stepLabel: "You are currently on Step 1: Love Map Update.",
                step: ["Explore", "Spark", "Notice", "Bond"],
                activity: rekindleActivities,
                badge: "Spark Keeper",
                badgesubHeading: "You've reignited closeness and emotional warmth.",
                badgeImageName: "sparkKeeperBadge",
                HIWStep: ["Updating love maps", "Introducing novelty", "Catching connection bids", "Daily bonding rituals"]
            )
        ]
        self.bondpage = bond
    }
    
    
    // Badge Popup Data
    func getBadgePopupData(for bondName: String) -> BadgePopupData? {
        switch bondName {

        case "Navigate Conflict Together":
            return BadgePopupData(
                title: "Harmony Seeker",
                subtitle: "You’ve mastered the art of peaceful resolution.",
                imageName: "HarmonySeekerBadge"
            )

        case "Establishing Good Communication":
            return BadgePopupData(
                title: "Communication Champ",
                subtitle: "You’ve built a strong foundation of open dialogue.",
                imageName: "communicationChampBadge"
            )

        case "Rekindle Honeymoon Phase":
            return BadgePopupData(
                title: "Spark Keeper",
                subtitle: "You’ve reignited closeness and emotional warmth.",
                imageName: "sparkKeeperBadge"
            )

        default:
            return nil
        }
    }

    func markActivityCompleted(activity: Activity) {
        if let index = activities.firstIndex(where: {
            $0.name == activity.name &&
            $0.category == activity.category
        }) {
            activities[index].status = .completed
        }
    }
    
    func markActivityOngoing(activity: Activity) {
        if let index = activities.firstIndex(where: {
            $0.name == activity.name &&
            $0.category == activity.category
        }) {
            activities[index].status = .ongoing
        }
    }
    func markActivityNone(activity: Activity) {
        if let index = activities.firstIndex(where: {
            $0.name == activity.name &&
            $0.category == activity.category
        }) {
            activities[index].status = .none
        }
    }

    func startActivity(_ activity: Activity, completion: ((UUID?) -> Void)? = nil) {

        if let index = activities.firstIndex(where: {
            $0.name == activity.name &&
            $0.category == activity.category
        }) {
            activities[index].status = .ongoing
        } else {
            var newActivity = activity
            newActivity.status = .ongoing
            activities.append(newActivity)
        }

        // Also insert into Supabase so partner's device sees it
        guard let relationshipId = currentRelationshipId,
              let userId = currentUserId else {
            completion?(nil)
            return
        }

        Task {
            do {
                let coupleActivity = try await SupabaseManager.shared.startActivityForCouple(
                    relationshipId: relationshipId,
                    userId: userId,
                    activity: activity
                )

                // Store the coupleActivityId back on the local activity
                if let index = self.activities.firstIndex(where: {
                    $0.name == activity.name && $0.category == activity.category
                }) {
                    self.activities[index].coupleActivityId = coupleActivity.coupleActivityId
                }

                // Send notification to partner (same pattern as Love Notes & Memories)
                do {
                    try await NotificationService.shared.sendPartnerNotification(
                        relationshipId: relationshipId,
                        type: "activity_started",
                        message: "Your partner started an activity: \(activity.name) 💫",
                        entityType: "activity",
                        entityId: coupleActivity.coupleActivityId.uuidString
                    )
                } catch {
                }

                DispatchQueue.main.async {
                    completion?(coupleActivity.coupleActivityId)
                }
            } catch {
                DispatchQueue.main.async {
                    completion?(nil)
                }
            }
        }
    }

    func getBuildYourBondPages(name : String) -> BuildYourBondpage? {
        return bondpage.first { $0.Name == name }
    }

    func setHisMood(_ mood: Mood) {
        HisMood = mood
    }

    func setHerMood(moodId: Int) {
        HerMood = mood(by: moodId)
    }
    func getHisMood() -> Mood? {
        HisMood
    }
    func getHerMood() -> Mood? {
        return HerMood
    }
    
    func getActivities() -> [Activity] {
        return activities
    }

    func getDailyRandomActivities(count: Int = 6) -> [Activity] {
        let categoryName = "Activities for \(partnerDisplayText)"
        let pool = activities.filter { $0.category == categoryName }
        guard !pool.isEmpty else { return [] }
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: Date())
            let daySeed = (components.year ?? 0) * 10000
        + (components.month ?? 0) * 100
        + (components.day ?? 0)

        var rng = SeededRandomNumberGenerator(seed: UInt64(daySeed))
        let shuffled = pool.shuffled(using: &rng)
        return Array(shuffled.prefix(count))
    }
    func getOngoingActivities() -> [Activity] {
        return activities.filter { $0.status == .ongoing }
    }
    func getCompletedActivities() -> [Activity] {
        return activities.filter { $0.status == .completed }
    }

    // MARK: - Supabase Context

    /// Fetch and store the current user's ID, relationship ID, and partner's ID from Supabase.
    /// Must be called once after login (e.g. from VibeViewController.viewDidLoad).
    func loadUserContext() async {
        do {
            let session = try await SupabaseManager.shared.client.auth.session
            let authUserId = session.user.id
            self.currentUserId = authUserId

            // Find the active relationship
            let rows: [DBRelationship] = try await SupabaseManager.shared.client
                .from("relationships")
                .select()
                .or("user1_id.eq.\(authUserId.uuidString),user2_id.eq.\(authUserId.uuidString)")
                .eq("status", value: "active")
                .limit(1)
                .execute()
                .value

            if let relationship = rows.first {
                self.currentRelationshipId = relationship.relationship_id
                self.partnerUserId = (relationship.user1_id == authUserId)
                    ? relationship.user2_id
                    : relationship.user1_id
                self.partnerAssessmentPreferences = nil
            } else {
            }
        } catch {
        }
    }

    // MARK: - Supabase Sync

    /// Fetch all couple_activities from Supabase and update local activity statuses
    func syncActivitiesFromSupabase() {
        guard let relationshipId = currentRelationshipId else { return }

        Task {
            do {
                let remote = try await SupabaseManager.shared.fetchAllCoupleActivities(
                    relationshipId: relationshipId
                )
                self.coupleActivities = remote

                // Separate custom vs preset rows
                let customRows  = remote.filter { $0.isCustom }
                let presetRows  = remote.filter { !$0.isCustom }

                // Rebuild customActivities from Supabase — convert scheduledDate → display string
                let dateFormatter: DateFormatter = {
                    let f = DateFormatter()
                    f.locale = Locale(identifier: "en_US_POSIX")
                    f.dateStyle = .medium
                    return f
                }()

                let synced = customRows.map { row -> Activity in
                    let displayDate: String = {
                        if let scheduled = row.scheduledDate {
                            return dateFormatter.string(from: scheduled)
                        }
                        return ""
                    }()
                    return Activity(
                        coupleActivityId: row.coupleActivityId,
                        name: row.activityName,
                        description: row.description ?? "",
                        image: "Activityimage",
                        time: displayDate,
                        status: .ongoing,
                        category: "Custom"
                    )
                }
                self.customActivities = synced

                // Sync preset activities as before
                for coupleActivity in presetRows {
                    if let index = self.activities.firstIndex(where: {
                        $0.name == coupleActivity.activityName
                    }) {
                        switch coupleActivity.status {
                        case "ongoing":
                            self.activities[index].status = .ongoing
                        case "completed":
                            self.activities[index].status = .completed
                        case "scheduled":
                            self.activities[index].status = .scheduled
                            self.activities[index].scheduledDate = coupleActivity.scheduledDate
                        default:
                            break
                        }
                        self.activities[index].coupleActivityId = coupleActivity.coupleActivityId
                    } else {
                        let newStatus: ActivityStatus = {
                            switch coupleActivity.status {
                            case "ongoing": return .ongoing
                            case "completed": return .completed
                            case "scheduled": return .scheduled
                            default: return .none
                            }
                        }()

                        let match = self.exploreJSONActivities.first(where: { $0.name == coupleActivity.activityName }) ??
                            self.bondJSONActivities.first(where: { $0.name == coupleActivity.activityName }) ??
                            self.suggestedJSONActivities.first(where: { $0.name == coupleActivity.activityName })

                        let newActivity = Activity(
                            id: coupleActivity.activityId,
                            coupleActivityId: coupleActivity.coupleActivityId,
                            name: coupleActivity.activityName,
                            description: match?.description ?? "",
                            detailedDescription: match?.detailedDescription,
                            image: match?.image ?? "Activityimage",
                            time: match?.time ?? "",
                            status: newStatus,
                            category: match?.category ?? "",
                            scheduledDate: coupleActivity.scheduledDate,
                            steps: match?.steps
                        )
                        self.activities.append(newActivity)
                    }
                }

                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .activitiesSynced, object: nil)
                }
            } catch {
                print("Failed to sync activities: \(error)")
            }
        }
    }
    func getTips() -> [Tip] {
        return tips
    }
    func getMood() -> [MoodCheckIn] {
        return moods
    }
    func getSuggestedActivities() -> [Activity] {
        return suggestedActivities
    }
    func updateScheduledDate(for activity: Activity, date: Date) {

        if let index = allActivities.firstIndex(where: {
            $0.name == activity.name && $0.category == activity.category
        }) {
            allActivities[index].scheduledDate = date
            allActivities[index].status = .scheduled
        }
    }

    func getScheduledActivities() -> [Activity] {
        return activities.filter {
            $0.status == .scheduled && $0.scheduledDate != nil
        }
    }
    func buildAllActivities() {
        allActivities = []

        // Explore
        allActivities.append(contentsOf: activities)

        // Suggested (Vibe)
        allActivities.append(contentsOf: suggestedActivities)

        // Build Your Bond
        bondpage.forEach { page in
            allActivities.append(contentsOf: page.activity)
        }
    }
    
    //small modal data — now fully driven by JSON via getSmallModalData()
    func loadSmallModalData() {
        self.smallmodal = []
    }

    
    func feedBackData() -> [FeedBackGiven] {
        [
            FeedBackGiven(
                title: "Chill and Glow Sesh",
                subTitle:"Tell us how this activity made you feel",
                imageName: "camera",
                userMessage: nil,
                selectedMood: nil
            ),
            
            FeedBackGiven(
                title: "Petal Hunt",
                subTitle: "Tell us how this activity made you feel",
                imageName: "camera",
                userMessage: nil,
                selectedMood: nil
                )]
    }

    //mood options
    func loadMoodOptions() -> [Mood] {
        return [
            Mood(id: 1, title: "Joyful", imageName: "Joyful"),
            Mood(id: 2, title: "Playful", imageName: "Playful"),
            Mood(id: 3, title: "Peaceful", imageName: "Peaceful"),

            Mood(id: 4, title: "Satisfied", imageName: "Satisfied"),
            Mood(id: 5, title: "Calm", imageName: "Calm"),
            Mood(id: 6, title: "Productive", imageName: "Productive"),

            Mood(id: 7, title: "Determined", imageName: "Determined"),
            Mood(id: 8, title: "Adventurous", imageName: "Adventurous"),
            Mood(id: 9, title: "Curious", imageName: "Curious"),

            Mood(id: 10, title: "Attached", imageName: "Attached"),
            Mood(id: 11, title: "Regretful", imageName: "Regretful"),
            Mood(id: 12, title: "Sad", imageName: "Sad"),

            Mood(id: 13, title: "Disappointed", imageName: "Disappointed"),
            Mood(id: 14, title: "Drained", imageName: "Drained"),
            Mood(id: 15, title: "Angry", imageName: "Angry")
        ]
    }
    
    
    // unlock of activities in build your bond
    func unlockNextBondActivity( bondName: String, completedIndex: Int) {
       
        guard let pageIndex = bondpage.firstIndex(where: { $0.Name == bondName }) else {
              return
          }

          // Mark current as completed
          bondpage[pageIndex].activity[completedIndex].status = .completed

          // Unlock next if exists
          let nextIndex = completedIndex + 1
          if nextIndex < bondpage[pageIndex].activity.count {
              bondpage[pageIndex].activity[nextIndex].status = .none
          }
    }
}

// Create one shared instance
let dataStore = DataStore()

extension UIView {
    func applyLiquidGlassEffect(animated: Bool = true) {
        let existingGlassView = self.subviews.first { $0 is UIVisualEffectView }
        if existingGlassView != nil {
            return
        }

        let glassEffectView = UIVisualEffectView()
        glassEffectView.isUserInteractionEnabled = false
        glassEffectView.translatesAutoresizingMaskIntoConstraints = false
        self.insertSubview(glassEffectView, at: 0)

        NSLayoutConstraint.activate([
            glassEffectView.topAnchor.constraint(equalTo: self.topAnchor),
            glassEffectView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            glassEffectView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            glassEffectView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])

        if #available(iOS 17.0, *) {
            let glassEffect = UIGlassEffect()
            if animated {
                UIView.animate(withDuration: 0.3) {
                    glassEffectView.effect = glassEffect
                }
            } else {
                glassEffectView.effect = glassEffect
            }
        } else {
            let blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
            glassEffectView.effect = blurEffect
        }

        glassEffectView.layer.cornerRadius = self.layer.cornerRadius
        glassEffectView.clipsToBounds = true
    }
}

// MARK: - Seeded RNG for deterministic daily shuffles
struct SeededRandomNumberGenerator: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        // Linear congruential generator (same constants as glibc)
        state = state &* 6364136223846793005 &+ 1442695040888963407
        return state
    }
}
