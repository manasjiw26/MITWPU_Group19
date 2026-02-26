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

    private(set) var allActivities: [Activity] = []
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
        loadSampleNotifications()
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

    func loadSampleNotifications() {
        notifications = [
            AppNotification(
                id: UUID(),
                senderName: "Sam",
                message: "Just added a new memory for you 💌",
                type: .memory,
                createdAt: Date().addingTimeInterval(-120),
                isRead: false
            ),
            AppNotification(
                id: UUID(),
                senderName: "Sam",
                message: "Next up: Cozy Cocoon! Tap to know more 🕯️",
                type: .activity,
                createdAt: Date().addingTimeInterval(-900),
                isRead: false
            ),
            AppNotification(
                id: UUID(),
                senderName: "Sam",
                message: "Sent you a love note ❤️",
                type: .loveNote,
                createdAt: Date().addingTimeInterval(-3600),
                isRead: false
            )
        ]
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
        let sampleActivities: [Activity] = [

            Activity(
                name: "Chill & Glow Sesh",
                description: "Facemasks, candles, chill beats — just cozy vibes and glow time",
                image: "Chill and Glow sesh",
                time: "5 mins",
                status: .none,
                category: "Fun & Playful",
                scheduledDate: nil
            ),

            Activity(
                name: "Petal Hunt",
                description: "Pick pretty blooms and build your own bouquet together.",
                image: "Activityimage",
                time: "5 mins",
                status: .none,
                category: "Fun & Playful",
                scheduledDate: nil
            ),

            Activity(
                name: "Wholesome Craft Challenge",
                description: "Make a doodle / note / digital collage for her",
                image: "Activityimage",
                time: "5 mins",
                status: .none,
                category: "Fun & Playful",
                scheduledDate: nil
            ),

            Activity(
                name: "Memory Lane Marathon",
                description: "Make a mini reel using your photos and favorite audio",
                image: "Activityimage",
                time: "5 mins",
                status: .none,
                category: "Daily Dose of Us",
                scheduledDate: nil
            ),

            Activity(
                name: "Stuff-A-Memory Day",
                description: "Buy a tiny plush, both name it and take care of it together",
                image: "Activityimage",
                time: "5 mins",
                status: .none,
                category: "Acts of Love",
                scheduledDate: nil
            ),

            Activity(
                name: "Wholesome Craft Challenge",
                description: "Make a doodle / note / digital collage for her",
                image: "Activityimage",
                time: "5 mins",
                status: .none,
                category: "Meaning & Growth",
                scheduledDate: nil
            ),

            Activity(
                name: "Memory Lane Marathon",
                description: "Make a mini reel using your photos and favorite audio",
                image: "Activityimage",
                time: "5 mins",
                status: .none,
                category: "Daily Dose of Us",
                scheduledDate: nil
            ),

            Activity(
                name: "Stuff-A-Memory Day",
                description: "Buy a tiny plush, both name it and take care of it together",
                image: "Activityimage",
                time: "5 mins",
                status: .none,
                category: "Acts of Love",
                scheduledDate: nil
            )
        ]
        self.activities = sampleActivities
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
    
    func loadSampleMemory()->[Memory] {
        let memories: [Memory] = [
            Memory(
                id: UUID(),
                date: Date().addingTimeInterval(-86400 * 5),
                imageName: "Couple1",
                location: "Bhopal",
                title: "Our First Hello 💌",
                description: "The moment everything quietly began.",
                uiImage: nil
            ),
            Memory(
                id: UUID(),
                date: Date().addingTimeInterval(-86400 * 2),
                imageName: "Couple2",
                location: "Pune",
                title: "Worth Remembering ✨",
                description: "One smile that made the whole day better.",
                uiImage: nil
            ),
            Memory(
                id: UUID(),
                date: Date(),
                imageName: "Couple3",
                location: "Pune",
                title: "A Random Smile 😊",
                description: "Some moments deserve to stay forever.",
                uiImage: nil
            )
        ]
        return memories
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
        if let existing = smallmodal.first(where: { $0.title == activity.name }) {
            return existing
        }
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

    // 1. The full pool of everything available
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
        // This starts the app with just the first 3 from the pool
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
                    PersonalInfoItem(title: "Phone Number", value: "+91 9876543210", showsChevron: false),
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

        userProfile = UserProfile(
            name: "Name",
            email: "name@email.com",
            profileImageName: "Profile",
            savedPreferences: [:]
        )

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
        let sampleTips: [Tip] = [
            Tip(title: "Make hot chocolate for her"),
            Tip(title: "Write her a sweet note"),
            Tip(title: "Give her a foot massage"),
            Tip(title: "Prepare dinner for her"),
            Tip(title: "Offer to do her chores"),
            Tip(title: "Plan a movie date night"),
            Tip(title: "Cook her favorite meal"),
            Tip(title: "Help her with her homework"),
            Tip(title: "Organize her closet")
        ]
        
        self.tips = sampleTips
    }
    
    func getAllTips() -> [Tip] {
        return [
            Tip(title: "Make hot chocolate for her"),
            Tip(title: "Write her a sweet note"),
            Tip(title: "Give her a foot massage"),
            Tip(title: "Prepare dinner for her"),
            Tip(title: "Offer to do her chores"),
            Tip(title: "Plan a movie date night"),
            Tip(title: "Cook her favorite meal"),
            Tip(title: "Help her with her homework"),
            Tip(title: "Organize her closet")
        ]
    }
    
    //build your bond
    func loadBuildYourbond() -> [BuildYourBond]{
        let sampleBuildYourBond: [BuildYourBond] = [
            BuildYourBond(name: "Navigate Conflict Together", imageName: "Conflict"),
            BuildYourBond(name: "Rekindle Honeymoon Phase", imageName: "Rekindle"),
            BuildYourBond(name: "Establishing Good Communication", imageName: "Communication")]
        
            return sampleBuildYourBond
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

        switch activityTitle {

        case "Chill & Glow Sesh":
            return [
                StepsToFollow(number: 1, title: "Set the mood",
                              descriptionLabel: "Dim the lights, light candles, and let the soft glow set your cozy vibe."),
                StepsToFollow(number: 2, title: "Glow Prep",
                              descriptionLabel: "Lay out your facemasks and favorite skincare treats for two."),
                StepsToFollow(number: 3, title: "Chill & Connect",
                              descriptionLabel: "Put on beats, sip something soothing, and enjoy the calm together."),
                StepsToFollow(number: 4, title: "Mask & Mingle",
                              descriptionLabel: "Apply your masks, relax side by side, and let the glow sink in.")
            ]

        case "Petal Hunt":
            return [
                StepsToFollow(number: 1, title: "Choose a Garden",
                              descriptionLabel: "Find a peaceful garden or park filled with flowers."),
                StepsToFollow(number: 2, title: "Petal Mission",
                              descriptionLabel: "Search for your favorite flowers together."),
                StepsToFollow(number: 3, title: "Capture Moments",
                              descriptionLabel: "Take photos of petals and smiles."),
                StepsToFollow(number: 4, title: "Reflect",
                              descriptionLabel: "Share how the experience made you feel.")
            ]
            
        case "Cozy Cocoon":
            return [
                StepsToFollow(number: 1, title: "Build Your Hideout",
                              descriptionLabel: "Use chairs,blankets and pillows to create a cozy fort."),
                StepsToFollow(number: 2, title: "Queue the Audio",
                              descriptionLabel: "Pick a relaxing movie or podcast and have it ready to go."),
                StepsToFollow(number: 3, title: "Gather Provisions",
                              descriptionLabel: "Bring in simple snacks and drinks so you don't have to leave."),
                StepsToFollow(number: 4, title: "Cocoon & Connect",
                              descriptionLabel: "Get comfortable inside, press play, and enjoy.")
            ]
        case "The Soft Start-Up":
            return [
                StepsToFollow(number: 1, title: "Sit Together",
                         descriptionLabel: "Sit next to each other or face the same direction."),
                     StepsToFollow(number: 2, title: "Pick One Word",
                         descriptionLabel: "Choose one word that captures what hurt."),
                     StepsToFollow(number: 3, title: "Reveal Together",
                         descriptionLabel: "Count to three and reveal the words at the same time."),
                     StepsToFollow(number: 4, title: "Pause",
                         descriptionLabel: "Pause and take in both words without reacting.")
            ]
            
        case "The Empathy Bridge":
            return [
                StepsToFollow(number: 1, title: "Look at the Word",
                    descriptionLabel: "Read your partner’s chosen word."),
                StepsToFollow(number: 2, title: "Make a Guess",
                    descriptionLabel: "Share your guess in one sentence."),
                StepsToFollow(number: 3, title: "Confirm",
                    descriptionLabel: "Partner responds with Yes or Not Quite."),
                StepsToFollow(number: 4, title: "Clarify",
                    descriptionLabel: "Clarify in one short sentence if needed.")
            ]
            
            
        case "Collaborative Sprint":
            return [
                StepsToFollow(number: 1, title: "Recall the Moment",
                        descriptionLabel: "Think about when things escalated."),
                StepsToFollow(number: 2, title: "Name the Behavior",
                        descriptionLabel: "Each name one behavior that made it worse."),
                StepsToFollow(number: 3, title: "Choose One Change",
                        descriptionLabel: "Agree on one behavior to stop next time."),
                StepsToFollow(number: 4, title: "Say It Together",
                        descriptionLabel: "Say the change out loud together.")
            ]
            
        case "The Pattern Interrupt":
            return [
                StepsToFollow(number: 1, title: "Pick an Activity",
                        descriptionLabel: "Choose a neutral activity you can do immediately."),
                StepsToFollow(number: 2, title: "Do It Together",
                        descriptionLabel: "Do the activity without discussing the conflict."),
                StepsToFollow(number: 3, title: "Closure Line",
                        descriptionLabel: "One person says: ‘We’re good.’"),
                StepsToFollow(number: 4, title: "Move On",
                        descriptionLabel: "Continue the day without reopening the issue.")
            ]
            
        case "The Battery Check":
            return [
                StepsToFollow(number: 1, title: "Check Energy",
                    descriptionLabel: "Rate your energy from 1–10 before starting the conversation."),
                StepsToFollow(number: 2, title: "Share Why",
                    descriptionLabel: "Briefly explain why your energy feels this way."),
                StepsToFollow(number: 3, title: "Set Boundary",
                    descriptionLabel: "If energy is low, agree to pause deep talk."),
                StepsToFollow(number: 4, title: "Offer Support",
                    descriptionLabel: "Ask what small thing could help them recharge.")
            ]
            
        case "No-Gatekeeping Needs":
            return [
                StepsToFollow(number: 1, title: "Identify Need",
                    descriptionLabel: "Pick one small thing you’ve been wanting."),
                StepsToFollow(number: 2, title: "Ask Directly",
                    descriptionLabel: "Say it clearly without hints or sarcasm."),
                StepsToFollow(number: 3, title: "Be Specific",
                    descriptionLabel: "Explain exactly what would help."),
                StepsToFollow(number: 4, title: "Appreciate",
                    descriptionLabel: "Thank them for hearing you out.")
            ]
            
        case "The Echo Chamber":
            return [
                StepsToFollow(number: 1, title: "Invite Sharing",
                    descriptionLabel: "Ask what’s been on their mind."),
                StepsToFollow(number: 2, title: "Reflect Back",
                    descriptionLabel: "Repeat what you heard in your own words."),
                StepsToFollow(number: 3, title: "Confirm",
                    descriptionLabel: "Ask if you understood them correctly."),
                StepsToFollow(number: 4, title: "Respond",
                    descriptionLabel: "Only share your thoughts after confirmation.")
            ]

        case "Safe Space Protocol":
            return [
                StepsToFollow(number: 1, title: "Choose Spot",
                    descriptionLabel: "Sit in your agreed safe-space location."),
                StepsToFollow(number: 2, title: "Set Rule",
                    descriptionLabel: "Agree nothing said will be used later."),
                StepsToFollow(number: 3, title: "Share Vulnerability",
                    descriptionLabel: "Share one honest fear or thought."),
                StepsToFollow(number: 4, title: "Seal It",
                    descriptionLabel: "End with a 10-second hug.")
            ]

        case "Love Map Update":
            return [
                StepsToFollow(number: 1, title: "Ask Curiously",
                    descriptionLabel: "Ask about a current favorite or interest."),
                StepsToFollow(number: 2, title: "Listen",
                    descriptionLabel: "Focus fully without interrupting."),
                StepsToFollow(number: 3, title: "Note It",
                    descriptionLabel: "Save the detail mentally or in notes."),
                StepsToFollow(number: 4, title: "Switch Roles",
                    descriptionLabel: "Now let them ask about you.")
            ]
        case "The Dopamine Drop":
            return [
                StepsToFollow(number: 1, title: "Choose New",
                    descriptionLabel: "Pick an activity neither of you has done."),
                StepsToFollow(number: 2, title: "Stay Present",
                    descriptionLabel: "No phones during the activity."),
                StepsToFollow(number: 3, title: "Embrace Awkward",
                    descriptionLabel: "Laugh through mistakes."),
                StepsToFollow(number: 4, title: "Reflect",
                    descriptionLabel: "Talk about the most fun moment.")
            ]
        case "Bid-Catching Pro":
            return [
                StepsToFollow(number: 1, title: "Notice Bids",
                    descriptionLabel: "Watch for small bids for attention."),
                StepsToFollow(number: 2, title: "Turn Toward",
                    descriptionLabel: "Pause what you’re doing and respond."),
                StepsToFollow(number: 3, title: "Validate",
                    descriptionLabel: "Acknowledge them warmly."),
                StepsToFollow(number: 4, title: "Repeat",
                    descriptionLabel: "Catch at least 3 bids today.")
            ]
            
        case "The Intimacy Architect":
            return [
                StepsToFollow(number: 1, title: "Reunion Moment",
                    descriptionLabel: "Do this when you first see each other."),
                StepsToFollow(number: 2, title: "Hold",
                    descriptionLabel: "Share a 6-second kiss."),
                StepsToFollow(number: 3, title: "Breathe",
                    descriptionLabel: "Stay present during the moment."),
                StepsToFollow(number: 4, title: "Commit",
                    descriptionLabel: "Make this a daily ritual.")
            ]

            

        default:
            return []
        }
    }
    
    func getActivities(for category: ActivityCategory) -> [Activity] {
        return activities.filter { $0.category == category.name }
    }
    
    func loadsampleBuildYourBond() {
        let bond :[BuildYourBondpage] = [
            BuildYourBondpage(
        Name: "Navigate Conflict Together",
    SubHeading: "Take each step together to rebuild your connection.",
        stepLabel:  "You are currently on Step 1: Identifying the Conflict.",
        step: ["Identify","Empathize","Solution","Sustain"],
        activity: [
        Activity(name: "The Soft Start-Up", description: "Learn to bring up a complaint without blame or criticism.", image: "noContextReveal", time: "5mins", status: .none,category: "Navigate Conflict Together"),
        Activity(name: "The Empathy Bridge", description: "Understand your partner's experience and perspective.", image: "GuessBeforeYouAreTold", time: "5mins", status: .none,category: "Navigate Conflict Together"),
        Activity(name: "Collaborative Sprint", description: "Shift from 'me vs you' to 'us vs the problem", image: "DeletetheGlitch", time: "5mins", status: .none,category: "Navigate Conflict Together"),
        Activity(name: "The Pattern Interrupt", description: "Identify and break negative communication cycles.", image: "BacktoUs", time: "5mins", status: .none,category: "Navigate Conflict Together")
    ],
        badge: "Harmony Seeker",
        badgesubHeading: "Master the art of peaceful resolution.", badgeImageName: "HarmonySeekerBadge",
        HIWStep: ["Identify the Conflict","Empathizing with Perspectives","Crafting Joint Solutions","Sustaining Harmony"]
            
            
            ),
        BuildYourBondpage(
        Name: "Establishing Good Communication",
        SubHeading: "Clear the static and really hear each other.",
        stepLabel: "You are currently on Step 1: The Battery Check.",
        step: [
            "Check-in",
            "Express",
            "Reflect",
            "Trust"
            ],
        activity: [
            Activity(
                name: "The Battery Check",
                description: "Check their energy before unloading your day.",
                image: "noContextReveal",
                time: "5 mins",
                status: .none,
                category: "Establishing Good Communication"
                ),
            Activity(
                name: "No-Gatekeeping Needs",
                description: "Say what you need—no hints, no guessing.",
                image: "GuessBeforeYouAreTold",
                time: "5 mins",
                status: .none,
                category: "Establishing Good Communication"
                ),
            Activity(
                name: "The Echo Chamber",
                description: "Repeat to prove you’re really listening.",
                image: "DeletetheGlitch",
                time: "5 mins",
                status: .none,
                category: "Establishing Good Communication"
                ),
            Activity(
                name: "Safe Space Protocol",
                description: "Create a no-judgment zone for honesty.",
                image: "BacktoUs",
                time: "5 mins",
                status: .none,
                category: "Establishing Good Communication"
                )
                ],
                badge: "Communication Champ",
                badgesubHeading: "You’ve built a strong foundation of open dialogue.",
                badgeImageName: "communicationChampBadge",
                HIWStep: [
                    "Checking emotional bandwidth",
                    "Expressing needs clearly",
                    "Active listening",
                    "Creating emotional safety"
                ]
            ),
            BuildYourBondpage(
                Name: "Rekindle Honeymoon Phase",
                SubHeading: "Bring back the spark and beat roommate mode.",
                stepLabel: "You are currently on Step 1: Love Map Update.",
                step: [
                    "Explore",
                    "Spark",
                    "Notice",
                    "Bond"
                ],
                activity: [
                    Activity(
                        name: "Love Map Update",
                        description: "Update your knowledge of your partner’s world.",
                        image: "noContextReveal",
                        time: "5 mins",
                        status: .none,
                        category: "Rekindle Honeymoon Phase"
                    ),
                    Activity(
                        name: "The Dopamine Drop",
                        description: "Do something new to trigger first-date energy.",
                        image: "GuessBeforeYouAreTold",
                        time: "10 mins",
                        status: .none,
                        category: "Rekindle Honeymoon Phase"
                    ),
                    Activity(
                        name: "Bid-Catching Pro",
                        description: "Notice and respond to small connection bids.",
                        image: "DeletetheGlitch",
                        time: "5 mins",
                        status: .none,
                        category: "Rekindle Honeymoon Phase"
                    ),
                    Activity(
                        name: "The Intimacy Architect",
                        description: "Build a daily ritual that bonds you deeply.",
                        image: "BacktoUs",
                        time: "5 mins",
                        status: .none,
                        category: "Rekindle Honeymoon Phase"
                    )
                ],
                badge: "Spark Keeper",
                badgesubHeading: "You’ve reignited closeness and emotional warmth.",
                badgeImageName: "sparkKeeperBadge",
                HIWStep: [
                    "Updating love maps",
                    "Introducing novelty",
                    "Catching connection bids",
                    "Daily bonding rituals"
                ]
            ),


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
            return
        }

        var newActivity = activity
        newActivity.status = .ongoing
        activities.append(newActivity)

        print("Added new ongoing activity:", newActivity.name)
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
    
    //small modal data
    func loadSmallModalData() {
        let sample: [SmallModalData] = [
            SmallModalData(
                title: "Chill & Glow Sesh",
                mainImageName: "Chill and Glow sesh",
                descriptionLabel: "Light up your calm with candles, a facemask, and your favorite tunes. Then breathe, smile, and just flow.",
                clockImageName: "clock",
                timerLabel: "5 mins"
            ),
            
            SmallModalData(
                title: "Petal Hunt",
                mainImageName: "Activityimage",
                descriptionLabel: "Pick pretty blooms and build your own bouquet together.",
               clockImageName: "clock",
                timerLabel: "5 mins"
            ),
            SmallModalData(
                title: "Cozy Cocoon",
                mainImageName: "Cozy Cocoon",
                descriptionLabel: "Create a comfy little fort, grab snacks and play something relaxing. Settle in and enjoy your cozy escape.",
               clockImageName: "clock",
                timerLabel: "15 mins")
            ,
            SmallModalData(
                title: "The Soft Start-Up",
                mainImageName: "noContextReveal",
                descriptionLabel: "One word can cut through a lot of noise. This level creates a quiet reveal that often makes the real issue obvious without restarting the fight.",
               clockImageName: "clock",
                timerLabel: "5 mins")
            ,
            SmallModalData(
                title: "The Empathy Bridge",
                mainImageName: "GuessBeforeYouAreTold",
                descriptionLabel: "Understanding becomes a small challenge here. Guessing first brings curiosity into the moment and often softens tension before anything is explained.",
               clockImageName: "clock",
                timerLabel: "10 mins")
            ,
            SmallModalData(
                title: "Collaborative Sprint",
                mainImageName: "DeletetheGlitch",
                descriptionLabel: "A simple upgrade that removes one move that keeps causing friction, helping future conflicts play out more smoothly.",
                clockImageName: "clock",
                timerLabel: "10 mins")
            ,
            SmallModalData(
                title: "The Pattern Interrupt",
                mainImageName: "BacktoUs",
                descriptionLabel: "Closure doesn’t always need more words. This level uses a simple shared action to reset the mood and help both people move forward.",
               clockImageName: "clock",
                timerLabel: "5 mins")
            ,
            SmallModalData(title: "The Battery Check", mainImageName: "noContextReveal", descriptionLabel: "Check their energy before unloading your day.", clockImageName: "clock", timerLabel: "10 mins")
            ,
            SmallModalData(title: "No-Gatekeeping Needs", mainImageName: "GuessBeforeYouAreTold", descriptionLabel: "Say what you need—no hints, no guessing.", clockImageName: "clock", timerLabel: "10 mins")
            ,
            SmallModalData(title: "The Echo Chamber", mainImageName: "DeletetheGlitch", descriptionLabel: "Repeat to prove you’re really listening.", clockImageName: "clock", timerLabel: "10 mins")
            ,
            SmallModalData(title: "Safe Space Protocol", mainImageName:"BacktoUs", descriptionLabel: "Create a no-judgment zone for honesty.", clockImageName:"clock", timerLabel: "5 mins")
            ,
            SmallModalData(title: "Love Map Update", mainImageName: "noContextReveal", descriptionLabel: "Update your knowledge of your partner’s world.", clockImageName: "clock", timerLabel: "10 mins")
            ,
            SmallModalData(title: "The Dopamine Drop", mainImageName: "GuessBeforeYouAreTold", descriptionLabel: "Do something new to trigger first-date energy.", clockImageName: "clock", timerLabel: "10 mins")
            ,
            SmallModalData(title: "Bid-Catching Pro", mainImageName: "DeletetheGlitch", descriptionLabel: "Notice and respond to small connection bids.", clockImageName: "clock", timerLabel: "10 mins")
            ,
            SmallModalData(title: "The Intimacy Architect", mainImageName: "BacktoUs", descriptionLabel: "Build a daily ritual that bonds you deeply.", clockImageName: "clock", timerLabel: "10 mins")
        ]
        
        self.smallmodal = sample
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
