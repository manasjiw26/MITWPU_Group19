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
    
    var specialDates: [SpecialDate] = []
    
    var currentUserId: UUID?
    var currentRelationshipId: UUID?
    var partnerUserId: UUID?

    private(set) var allActivities: [Activity] = []
    private var bondJSONActivities: [JSONActivity] = []
    private var exploreJSONActivities: [JSONActivity] = []
    private var HisMood: Mood?
    private var HerMood: Mood? = Mood(id: -1, title: "Calm", imageName: "Calm" )
    private(set) var notifications: [AppNotification] = []
    private(set) var savedFeedback: [FeedBackGiven] = []
    
    lazy var groupedSuggestedActivities: [SuggestionGroup: [Activity]] = makeGroupedSuggestedActivities()
    private var lastSuggestionGroup: SuggestionGroup?

  
    init() {
        loadSampleData()
        loadSampleRewards()
        loadSampleTips()
        moods = sampleMoods()
        loadSmallModalData()
        moodOptions = loadMoodOptions()
        loadSampleQuestions()
        loadSuggestedActivity()
        loadsampleBuildYourBond()
        loadPersonalInfoData()
        loadProfileData()
        buildAllActivities()
        loadDailyCheckInQuestions()
        loadOnboardingQnA()
    }

    private func makeGroupedSuggestedActivities() -> [SuggestionGroup: [Activity]] {
        return [
            .A: [
                Activity(name: "Steal My Day", description: "Live one tiny part of your partner’s day as if it’s yours.", image: "Fun&Playful", time: "20 min", status: .none, category: "Group A", scheduledDate: nil),
                Activity(name: "Us vs The World (Mini Edition)", description: "Turn a boring errand into a shared mission.", image: "DailyDoseOfUs", time: "30 min", status: .none, category: "Group A", scheduledDate: nil),
                Activity(name: "Memory Remix", description: "Revisit a shared memory, but change the vibe.", image: "DailyDoseOfUs", time: "30 min", status: .none, category: "Group A", scheduledDate: nil),
                Activity(name: "Question, But Make It Spicy", description: "Ask questions you normally skip when things are good.", image: "SpiceItUp", time: "20 min", status: .none, category: "Group A", scheduledDate: nil),
                Activity(name: "No-Plan Date", description: "Spend time together with zero structure.", image: "Fun&Playful", time: "45 min", status: .none, category: "Group A", scheduledDate: nil),
                Activity(name: "Tiny Appreciation Drop", description: "Say the small things before they disappear.", image: "ActsOfLove", time: "10 min", status: .none, category: "Group A", scheduledDate: nil),
                Activity(name: "The One-Song Rule", description: "Express your vibe with music, one song at a time.", image: "DailyDoseOfUs", time: "10 min", status: .none, category: "Group A", scheduledDate: nil),
                Activity(name: "Micro Date Jar", description: "Tiny dates, zero planning stress.", image: "Fun&Playful", time: "20 min", status: .none, category: "Group A", scheduledDate: nil)
            ],
            .B: [
                Activity(name: "Soft Check-In", description: "A low-pressure way to see how each other actually feels today.", image: "NoFilterChats", time: "10 min", status: .none, category: "Group B", scheduledDate: nil),
                Activity(name: "Quiet Walk", description: "Walk together without trying to fill the silence.", image: "Meaning&Growth", time: "20 min", status: .none, category: "Group B", scheduledDate: nil),
                Activity(name: "Same Room, Same Energy", description: "Be together without doing the same thing.", image: "DailyDoseOfUs", time: "20 min", status: .none, category: "Group B", scheduledDate: nil),
                Activity(name: "Gratitude, But Casual", description: "Appreciation without making it a big emotional moment.", image: "ActsOfLove", time: "10 min", status: .none, category: "Group B", scheduledDate: nil),
                Activity(name: "Mood Sync", description: "Align your emotional pace for the rest of the day.", image: "Meaning&Growth", time: "10 min", status: .none, category: "Group B", scheduledDate: nil),
                Activity(name: "End-of-Day Recap", description: "Close the day gently, without deep processing.", image: "DailyDoseOfUs", time: "15 min", status: .none, category: "Group B", scheduledDate: nil),
                Activity(name: "The Evening Anchor", description: "Create a predictable end-of-day habit.", image: "ActsOfLove", time: "10 min", status: .none, category: "Group B", scheduledDate: nil)
            ],
            .C: [
                Activity(name: "What If We...", description: "Explore possibilities you’ve never actually talked about.", image: "NoFilterChats", time: "20 min", status: .none, category: "Group C", scheduledDate: nil),
                Activity(name: "Future Snapshot", description: "Picture one tiny moment from a shared future.", image: "Meaning&Growth", time: "20 min", status: .none, category: "Group C", scheduledDate: nil),
                Activity(name: "Habit Trade", description: "Try one small habit from each other’s life.", image: "Meaning&Growth", time: "20 min", status: .none, category: "Group C", scheduledDate: nil),
                Activity(name: "How Do You Think?", description: "Understand how your partner’s mind works.", image: "NoFilterChats", time: "20 min", status: .none, category: "Group C", scheduledDate: nil),
                Activity(name: "Values, Not Goals", description: "Talk about what matters without pressure to plan.", image: "Meaning&Growth", time: "20 min", status: .none, category: "Group C", scheduledDate: nil),
                Activity(name: "Skill Share Mini", description: "Teach each other something tiny you’re good at.", image: "Fun&Playful", time: "20 min", status: .none, category: "Group C", scheduledDate: nil),
                Activity(name: "10-Minute Sweat", description: "Short, shared burst of physical effort.", image: "SpiceItUp", time: "10 min", status: .none, category: "Group C", scheduledDate: nil),
                Activity(name: "Try-Once Movement", description: "Test a new physical activity without commitment.", image: "Fun&Playful", time: "20 min", status: .none, category: "Group C", scheduledDate: nil)
            ],
            .D: [
                Activity(name: "The 5-Minute Game", description: "A daily mini game whenever things feel slightly off.", image: "BacktoUs", time: "5 min", status: .none, category: "Group D", scheduledDate: nil),
                Activity(name: "Us Playlist Game", description: "Build a shared playlist, one song at a time.", image: "BacktoUs", time: "10 min", status: .none, category: "Group D", scheduledDate: nil),
                Activity(name: "Scoreboard Life", description: "Turn everyday moments into a playful shared game.", image: "Fun&Playful", time: "15 min", status: .none, category: "Group D", scheduledDate: nil),
                Activity(name: "The Ongoing Challenge", description: "Pick one tiny challenge for 7 days.", image: "Meaning&Growth", time: "10 min", status: .none, category: "Group D", scheduledDate: nil),
                Activity(name: "Guess What I’d Pick", description: "A game that reminds you how well you know each other.", image: "NoFilterChats", time: "15 min", status: .none, category: "Group D", scheduledDate: nil),
                Activity(name: "The Shared Thing", description: "Decide one small thing that’s only yours as a couple.", image: "ActsOfLove", time: "10 min", status: .none, category: "Group D", scheduledDate: nil)
            ],
            .E: [
                Activity(name: "Pressure Release Note", description: "Let thoughts out without turning them into a discussion.", image: "NoFilterChats", time: "10 min", status: .none, category: "Group E", scheduledDate: nil),
                Activity(name: "Solo-But-Together Time", description: "Be near each other while doing your own thing.", image: "DailyDoseOfUs", time: "20 min", status: .none, category: "Group E", scheduledDate: nil),
                Activity(name: "Quiet Game Window", description: "Play a game together without conversation.", image: "Fun&Playful", time: "15 min", status: .none, category: "Group E", scheduledDate: nil),
                Activity(name: "Boundary Reset", description: "Set temporary limits so no one feels crowded.", image: "BacktoUs", time: "10 min", status: .none, category: "Group E", scheduledDate: nil),
                Activity(name: "Body Shake-Out", description: "Release built-up tension through movement.", image: "Meaning&Growth", time: "5 min", status: .none, category: "Group E", scheduledDate: nil),
                Activity(name: "Low-Stakes Challenge", description: "Compete lightly without emotional investment.", image: "Fun&Playful", time: "10 min", status: .none, category: "Group E", scheduledDate: nil)
            ],
            .F: [
                Activity(name: "Reassurance Round", description: "Ask directly for reassurance instead of hinting.", image: "NoFilterChats", time: "10 min", status: .none, category: "Group F", scheduledDate: nil),
                Activity(name: "Build the Fort", description: "Create a temporary shared space that feels safe.", image: "ActsOfLove", time: "15 min", status: .none, category: "Group F", scheduledDate: nil),
                Activity(name: "Comfort Contact", description: "Use physical closeness to calm the nervous system.", image: "ActsOfLove", time: "5 min", status: .none, category: "Group F", scheduledDate: nil),
                Activity(name: "The Safety Game", description: "Name safety indirectly through choices, not feelings.", image: "NoFilterChats", time: "10 min", status: .none, category: "Group F", scheduledDate: nil),
                Activity(name: "Body Double Time", description: "Do parallel movement to feel less alone.", image: "DailyDoseOfUs", time: "20 min", status: .none, category: "Group F", scheduledDate: nil),
                Activity(name: "Return Point", description: "Create a ritual for coming back together after distance.", image: "BacktoUs", time: "5 min", status: .none, category: "Group F", scheduledDate: nil),
                Activity(name: "Tag Team Game", description: "Work together instead of against each other.", image: "Fun&Playful", time: "20 min", status: .none, category: "Group F", scheduledDate: nil)
            ],
            .G: [
                Activity(name: "DIY Photo Frame Reset", description: "Channel tension into making something physical.", image: "Conflict", time: "20 min", status: .none, category: "Group G", scheduledDate: nil),
                Activity(name: "Silent Scrap Page", description: "Process the day without explaining it.", image: "Conflict", time: "15 min", status: .none, category: "Group G", scheduledDate: nil),
                Activity(name: "Card Stack Challenge", description: "Focus tension into a shared physical goal.", image: "Fun&Playful", time: "10 min", status: .none, category: "Group G", scheduledDate: nil),
                Activity(name: "Clay Mood Objects", description: "Shape how you feel without naming it directly.", image: "Meaning&Growth", time: "15 min", status: .none, category: "Group G", scheduledDate: nil),
                Activity(name: "Puzzle Without Talking", description: "Let your hands cooperate even if words can’t.", image: "BacktoUs", time: "20 min", status: .none, category: "Group G", scheduledDate: nil),
                Activity(name: "Recreate a Memory Table", description: "Revisit a good memory using objects around you.", image: "DailyDoseOfUs", time: "20 min", status: .none, category: "Group G", scheduledDate: nil),
                Activity(name: "One-Minute Vent", description: "Say what’s bothering you without debate.", image: "NoFilterChats", time: "5 min", status: .none, category: "Group G", scheduledDate: nil),
                Activity(name: "What I Meant vs What You Heard", description: "Clear misunderstanding in a controlled way.", image: "NoFilterChats", time: "10 min", status: .none, category: "Group G", scheduledDate: nil),
                Activity(name: "The Line Sentence", description: "Say what crossed a boundary once and clearly.", image: "Conflict", time: "5 min", status: .none, category: "Group G", scheduledDate: nil)
            ],
            .H: [
                Activity(name: "Parallel Scrap Page", description: "Be in the same space while working separately on the same thing.", image: "BacktoUs", time: "20 min", status: .none, category: "Group H", scheduledDate: nil),
                Activity(name: "Quiet Card Build", description: "Focus together on a neutral physical task.", image: "Fun&Playful", time: "15 min", status: .none, category: "Group H", scheduledDate: nil),
                Activity(name: "Side Quest", description: "Do a tiny task together with zero emotional meaning.", image: "DailyDoseOfUs", time: "10 min", status: .none, category: "Group H", scheduledDate: nil),
                Activity(name: "Same Song, Different Space", description: "Be emotionally aligned without physical closeness.", image: "BacktoUs", time: "10 min", status: .none, category: "Group H", scheduledDate: nil),
                Activity(name: "Silent Trade", description: "Exchange objects instead of words.", image: "ActsOfLove", time: "10 min", status: .none, category: "Group H", scheduledDate: nil),
                Activity(name: "Leave It There", description: "Acknowledge something without responding to it.", image: "NoFilterChats", time: "5 min", status: .none, category: "Group H", scheduledDate: nil)
            ],
            .I: [
                Activity(name: "No-Contact Coexistence", description: "Share a space without interacting at all.", image: "BacktoUs", time: "20 min", status: .none, category: "Group I", scheduledDate: nil),
                Activity(name: "Side-by-Side Task", description: "Be near each other while focusing on something else.", image: "DailyDoseOfUs", time: "15 min", status: .none, category: "Group I", scheduledDate: nil),
                Activity(name: "Object Boundary", description: "Use objects to signal emotional limits.", image: "NoFilterChats", time: "10 min", status: .none, category: "Group I", scheduledDate: nil),
                Activity(name: "Third-Thing Focus", description: "Redirect attention away from each other.", image: "Meaning&Growth", time: "15 min", status: .none, category: "Group I", scheduledDate: nil),
                Activity(name: "Background Presence", description: "Let sound replace interaction.", image: "BacktoUs", time: "20 min", status: .none, category: "Group I", scheduledDate: nil)
            ],
            .J: [
                Activity(name: "Public Mission, Private Team", description: "Complete a small mission in public as a silent team.", image: "Fun&Playful", time: "30 min", status: .none, category: "Group J", scheduledDate: nil),
                Activity(name: "Spend 200 Like It’s a Game", description: "Use money as a constraint, not a reward.", image: "Fun&Playful", time: "30 min", status: .none, category: "Group J", scheduledDate: nil),
                Activity(name: "Different Lives Date", description: "Pretend to be strangers with invented backstories.", image: "SpiceItUp", time: "20 min", status: .none, category: "Group J", scheduledDate: nil),
                Activity(name: "Witness Something Together", description: "Attend something as observers, not participants.", image: "DailyDoseOfUs", time: "30 min", status: .none, category: "Group J", scheduledDate: nil),
                Activity(name: "Rank Things That Don’t Matter", description: "Argue safely about nonsense.", image: "NoFilterChats", time: "15 min", status: .none, category: "Group J", scheduledDate: nil),
                Activity(name: "Judge Fictional Characters", description: "Project opinions safely.", image: "NoFilterChats", time: "15 min", status: .none, category: "Group J", scheduledDate: nil)
            ]
        ]
    }


    private func normalize(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    func resolveSuggestionGroup(selection: DailyCheckInSelection) -> SuggestionGroup {
        let mood = normalize(selection.mood)
        let closeness = normalize(selection.closeness) // disconnected/chill/attached/kinda close
        let vibe = normalize(selection.vibe)           // dry/meh/synced/vibing
        let need = normalize(selection.need)           // reassurance/quality time/space/deep convo

        let isVeryClose = (closeness == "attached")
        let isSomewhatClose = (closeness == "kinda close" || closeness == "chill")
        let isVeryDistant = (closeness == "disconnected")

        let isSmooth = (vibe == "synced" || vibe == "vibing")
        let isNeutral = (vibe == "meh")
        let isLittleOff = (vibe == "dry")
        let isTense = false // your UI has no "tense" option

        let isComfort = (need == "reassurance")
        let isConnection = (need == "quality time" || need == "deep convo")
        let isFun = false   // your UI has no direct "fun" option
        let isSpace = (need == "space")

        if ["angry", "regretful", "disappointed"].contains(mood),
           (isVeryClose || isSomewhatClose),
           isTense {
            return .G
        }

        if isSpace,
           (isVeryClose || isSomewhatClose),
           (isNeutral || isSmooth),
           ["drained", "peaceful", "attached"].contains(mood) {
            return .E
        }

        if isVeryDistant {
            if isFun, isNeutral, ["playful", "curious", "calm"].contains(mood) {
                return .J
            }
            return .I
        }

        if isConnection,
           (isNeutral || isLittleOff),
           ["sad", "curious", "regretful"].contains(mood),
           closeness == "disconnected" {
            return .H
        }

        if mood == "attached",
           isSomewhatClose,
           (isNeutral || isLittleOff),
           (isComfort || isConnection) {
            return .F
        }

        if isVeryClose,
           isLittleOff,
           (isConnection || isComfort),
           ["calm", "curious", "regretful", "attached"].contains(mood) {
            return .D
        }

        if ["joyful", "playful", "satisfied", "adventurous"].contains(mood),
           (isVeryClose || isSomewhatClose),
           isSmooth,
           (isFun || isConnection) {
            return .A
        }

        if ["calm", "peaceful", "productive"].contains(mood),
           (isSmooth || isNeutral),
           isConnection {
            return .B
        }

        if ["curious", "determined", "productive", "drained"].contains(mood),
           isNeutral,
           (isConnection || isFun) {
            return .C
        }

        if isSpace { return .E }
        if isTense { return .G }
        return .B
    }

    @discardableResult
    func getSuggestedActivitiesForDailyCheckIn(selection: DailyCheckInSelection, limit: Int = 3) -> [Activity] {
        let group = resolveSuggestionGroup(selection: selection)
        lastSuggestionGroup = group
        let pool = groupedSuggestedActivities[group] ?? allSuggestedPool
        let result = Array(pool.prefix(limit))
        self.suggestedActivities = result
        return result
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
            print(" Saved feedback:", feedback)
        }

    private func mood(by id: Int) -> Mood? {
        moodOptions.first { $0.id == id }
    }
    
    //custom activity
    func addCustomActivity(name: String, description: String, date: String) {
        let newActivity = Activity(
            name: name,
            description: description,
            image: "Activityimage",
            time: date,
            status: .none,
            category: "Custom"
        )
        customActivities.append(newActivity)
    }
    
    func loadSampleData() {
        // Load from activities.json ONLY
        guard let url = Bundle.main.url(forResource: "activities", withExtension: "json") else {
            print("❌ Could not find activities.json")
            return
        }

        let parsed: ActivitiesJSON
        do {
            let data = try Data(contentsOf: url)
            parsed = try JSONDecoder().decode(ActivitiesJSON.self, from: data)
        } catch {
            print("❌ Could not load activities.json")
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
        print("✅ Loaded \(self.activities.count) activities from activities.json")
    }
    func loadDailyCheckInQuestions() {
        let sampleQuestions: [Question] = [
            Question(title: "What level of connection are you on today?", options: ["Dry","Meh","Synced","Vibing"])
            ,
            Question(title: "What’s missing in your relationship rn?", options: ["Reassurance","Quality time","Space","Deep Convo"]),
            Question(title: "How connected do you feel with your partner today?", options: ["Disconnected","Chill","Attached","Kinda close"])
        ]
        self.dailyCheckInQuestions = sampleQuestions
    }


 
    func getRefreshSuggestedActivities() -> [Activity] {
        let pool = [
            Activity(name: "Cozy Cocoon", description: "Escape the noise...", image: "Cozy Cocoon", time: "15 min", status: .none, category: "suggestedActivity", scheduledDate: nil),
            Activity(name: "The Gratitude Glimmer", description: "Trade small joys.", image: "The Gratitude Glimmer", time: "10 min", status: .none, category: "suggestedActivity", scheduledDate: nil),
            Activity(name: "Story Sprout", description: "Watch a silly tale grow.", image: "Story Sprout", time: "10 min", status: .none, category: "suggestedActivity", scheduledDate: nil),
            Activity(name: "Candlelight Cocoa", description: "Sip and talk in soft light.", image: "Cocoa", time: "20 min", status: .none, category: "suggestedActivity", scheduledDate: nil),
            Activity(name: "Stargazing", description: "Look up and dream together.", image: "Stars", time: "15 min", status: .none, category: "suggestedActivity", scheduledDate: nil)
        ]
        return Array(pool.shuffled().prefix(3))
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
        let mapped = loadSteps(for: activity.name)
        if !mapped.isEmpty { return mapped }

        return [
            StepsToFollow(number: 1, title: "Set intention", descriptionLabel: "Start with: \"What do we need right now?\""),
            StepsToFollow(number: 2, title: "Do the activity", descriptionLabel: activity.description),
            StepsToFollow(number: 3, title: "Reflect", descriptionLabel: "Share one line: \"This felt ___ for me.\"")
        ]
    }
    var allSuggestedPool: [Activity] = [
        Activity(name: "Cozy Cocoon", description: "Escape the noise and sink into your cozy little cocoon.", image: "Cozy Cocoon", time: "15 min", status: .none, category: "suggestedActivity", scheduledDate: nil),
        Activity(name: "The Gratitude Glimmer", description: "Trade small thank yous for today's quiet joys.", image: "The Gratitude Glimmer", time: "10 min", status: .none, category: "suggestedActivity", scheduledDate: nil),
        Activity(name: "Story Sprout", description: "Watch a silly tale grow, one word at a time.", image: "Story Sprout", time: "10 min", status: .none, category: "suggestedActivity", scheduledDate: nil),
        Activity(name: "Candlelight Cocoa", description: "Sip and talk in soft light.", image: "Cocoa", time: "20 min", status: .none, category: "suggestedActivity", scheduledDate: nil),
        Activity(name: "Stargazing", description: "Look up and dream together.", image: "Stars", time: "15 min", status: .none, category: "suggestedActivity", scheduledDate: nil),
        Activity(name: "Dream Journal", description: "Write down your shared goals.", image: "Journal", time: "10 min", status: .none, category: "suggestedActivity", scheduledDate: nil),
        Activity(name: "Music Mix", description: "Create a playlist for two.", image: "Music", time: "20 min", status: .none, category: "suggestedActivity", scheduledDate: nil)
    ]
    
    func loadSuggestedActivity() {
        self.suggestedActivities = Array(allSuggestedPool.prefix(3))
    }

    func getMoreActivities(excluding current: [Activity]) -> [Activity] {
        guard let group = lastSuggestionGroup else { return [] }
        let sourcePool = groupedSuggestedActivities[group] ?? []
        let remaining = sourcePool.filter { new in
            !current.contains(where: { $0.name == new.name })
        }
        return Array(remaining.prefix(3))
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
                        ProfileItem(title: "Sign Out", iconName: "questionmark.circle", showsChevron: false)
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
            print("❌ Failed to load profile from Supabase: \(error)")
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
                print("✅ Profile (name, DOB) saved to Supabase")
            } catch {
                print("⚠️ Failed to save profile to Supabase: \(error)")
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
        let p = partnerPronoun
        let sampleTips: [Tip] = [
            Tip(title: "Make hot chocolate for \(p)"),
            Tip(title: "Write \(p) a sweet note"),
            Tip(title: "Give \(p) a foot massage"),
            Tip(title: "Prepare dinner for \(p)"),
            Tip(title: "Offer to do \(p == "them" ? "their" : p == "her" ? "her" : "his") chores"),
            Tip(title: "Plan a movie date night"),
            Tip(title: "Cook \(p == "them" ? "their" : p == "her" ? "her" : "his") favorite meal"),
            Tip(title: "Help \(p) with \(p == "them" ? "their" : p == "her" ? "her" : "his") homework"),
            Tip(title: "Organize \(p == "them" ? "their" : p == "her" ? "her" : "his") closet")
        ]
        
        self.tips = sampleTips
    }
    
    func getAllTips() -> [Tip] {
        let p = partnerPronoun
        return [
            Tip(title: "Make hot chocolate for \(p)"),
            Tip(title: "Write \(p) a sweet note"),
            Tip(title: "Give \(p) a foot massage"),
            Tip(title: "Prepare dinner for \(p)"),
            Tip(title: "Offer to do \(p == "them" ? "their" : p == "her" ? "her" : "his") chores"),
            Tip(title: "Plan a movie date night"),
            Tip(title: "Cook \(p == "them" ? "their" : p == "her" ? "her" : "his") favorite meal"),
            Tip(title: "Help \(p) with \(p == "them" ? "their" : p == "her" ? "her" : "his") homework"),
            Tip(title: "Organize \(p == "them" ? "their" : p == "her" ? "her" : "his") closet")
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
            print("✅ Loaded \(bondJSONActivities.count) bond activities from bondActivities.json")
        } else {
            print("⚠️ Could not load bondActivities.json, using fallback data")
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
            print(" MARKED COMPLETED:", activities[index].name)
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
            print(" MARKED COMPLETED:", activities[index].name)
        }
    }

    func startActivity(_ activity: Activity) {

        if let index = activities.firstIndex(where: {
            $0.name == activity.name &&
            $0.category == activity.category
        }) {
            activities[index].status = .ongoing
        } else {
            var newActivity = activity
            newActivity.status = .ongoing
            activities.append(newActivity)
            print("Added new ongoing activity:", newActivity.name)
        }

        // Also insert into Supabase so partner's device sees it
        guard let relationshipId = currentRelationshipId,
              let userId = currentUserId else {
            print("⚠️ startActivity: missing relationshipId or userId for Supabase sync")
            return
        }

        Task {
            do {
                let coupleActivity = try await SupabaseManager.shared.startActivityForCouple(
                    relationshipId: relationshipId,
                    userId: userId,
                    activity: activity
                )
                print("✅ Supabase: activity started → \(coupleActivity.coupleActivityId)")

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
                    print("✅ Activity notification sent to partner")
                } catch {
                    print("⚠️ Activity notification failed: \(error)")
                }
            } catch {
                print("❌ Supabase startActivity failed: \(error)")
            }
        }
    }

    func getBuildYourBondPages(name : String) -> BuildYourBondpage? {
        return bondpage.first { $0.Name == name }
    }

    func setHisMood(_ mood: Mood) {
        HisMood = mood
        print("His mood ", mood.title)
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
            print("✅ DataStore: currentUserId = \(authUserId)")

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
                print("✅ DataStore: relationshipId = \(relationship.relationship_id)")
                print("✅ DataStore: partnerUserId = \(self.partnerUserId?.uuidString ?? "nil")")
            } else {
                print("⚠️ DataStore: no active relationship found")
            }
        } catch {
            print("❌ DataStore.loadUserContext failed: \(error)")
        }
    }

    // MARK: - Supabase Sync

    /// Fetch all couple_activities from Supabase and update local activity statuses
    func syncActivitiesFromSupabase() {
        guard let relationshipId = currentRelationshipId else {
            print("⚠️ syncActivities: no currentRelationshipId")
            return
        }

        Task {
            do {
                let remote = try await SupabaseManager.shared.fetchAllCoupleActivities(
                    relationshipId: relationshipId
                )
                self.coupleActivities = remote

                for coupleActivity in remote {
                    // Try to find a matching local activity by name
                    if let index = self.activities.firstIndex(where: {
                        $0.name == coupleActivity.activityName
                    }) {
                        // Update local status to match Supabase
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
                        // Activity not in local list yet — add it
                        let newStatus: ActivityStatus = {
                            switch coupleActivity.status {
                            case "ongoing": return .ongoing
                            case "completed": return .completed
                            case "scheduled": return .scheduled
                            default: return .none
                            }
                        }()

                        let newActivity = Activity(
                            id: coupleActivity.activityId,
                            coupleActivityId: coupleActivity.coupleActivityId,
                            name: coupleActivity.activityName,
                            description: "",
                            image: "Activityimage",
                            time: "",
                            status: newStatus,
                            category: "",
                            scheduledDate: coupleActivity.scheduledDate
                        )
                        self.activities.append(newActivity)
                    }
                }

                print("✅ Synced \(remote.count) couple activities from Supabase")

                // Post notification so UI can reload
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .activitiesSynced, object: nil)
                }
            } catch {
                print("❌ syncActivitiesFromSupabase failed: \(error)")
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
