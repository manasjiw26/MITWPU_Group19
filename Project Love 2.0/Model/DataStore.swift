//
//  DataStore.swift
//  Project Love 2.0
//
//  Created by SDC-USER on 26/11/25.
//

import Foundation
import UIKit
class DataStore {
    static let shared = DataStore()
    var activities: [Activity] = []
    var rewards: [Reward] = []
    var activityCategory: [ActivityCategory] = []
    var buildYourBond : [BuildYourBond] = []
    var tips: [Tip] = []
    var moods: [MoodCheckIn] = []
    var smallmodal: [SmallModalData] = []
    var steps: [StepsToFollow] = []
    var moodOptions: [Mood] = []
    var questions: [Question] = []
    var suggestedActivities: [Activity] = []
    var bondpage: [BuildYourBondpage] = []
    var savedMemories: [Memory] = []
    
    private(set) var allActivities: [Activity] = []

    //var ongoingActivities: [Activity] = []
    
    private var HisMood: Mood?
    private var HerMood: Mood? = Mood(
        id: -1,
        title: "Calm",
        imageName: "calm"
    )

   
    private(set) var notifications: [AppNotification] = []
    // MARK: - Profile Data

    var userProfile: UserProfile?
    var profileSections: [ProfileSection] = []

    
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

        loadProfileData()
        buildAllActivities()
        //loadCheckIn()
        
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
                isRead: true
            )
        ]
    }
    
    
    // update mood
    
    private(set) var savedFeedback: [FeedBackGiven] = []

        func saveFeedback(_ feedback: FeedBackGiven) {
            savedFeedback.append(feedback)
            print(" Saved feedback:", feedback)
        }
    
    private func mood(by id: Int) -> Mood? {
        moodOptions.first { $0.id == id }
    }
    
    func loadSampleData() {
        let sampleActivities: [Activity] = [

            // Fun & Playful
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

            // Daily Dose of Us
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
    
    func loadSuggestedActivity () {
        let suggestedActivity: [Activity] = [
            Activity(name: "Cozy Cocoon", description: "Escape the noise and sink into your cozy little cocoon.", image: "Cozy Cocoon", time: "15 min", status: .none ,category : "suggestedActivity",scheduledDate: nil),
            Activity(name: "The Gratitude Glimmer", description: "Trade small thank yous for today's quiet joys.", image: "The Gratitude Glimmer", time: "10 min", status: .none,category : "suggestedActivity",scheduledDate: nil) ,
            Activity(name: "Story Sprout", description: "Watch a silly tale grow, one word at a time.", image: "Story Sprout", time: "10 min", status: .none, category : "suggestedActivity",scheduledDate: nil)
        ]
        self.suggestedActivities = suggestedActivity
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
    func loadSampleRewards() {
        let sampleRewards: [Reward] = [
            Reward(image: "Send_Hug", name: "Send hug", emoji: "🤗", progressStep: 0),
            Reward(image: "Send_Flower", name: "Send flower", emoji: "🌻", progressStep: 0),
            Reward(image: "Send_Kiss", name: "Send kiss", emoji: "😘", progressStep: 0),
            Reward(image: "Send_Heart", name: "Send heart", emoji: "🫶🏻", progressStep: 0),
            Reward(image: "Send_Note", name: "Send note", emoji: "💌", progressStep: 0),
            Reward(image: "Send_Wave", name: "Send wave", emoji: "👋", progressStep: 0),
            Reward(image: "Send_Hug", name: "Send high five", emoji: "🙌", progressStep: 0)
        ]
        
        self.rewards = sampleRewards
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
    
    func loadBuildYourbond() -> [BuildYourBond]{
        let sampleBuildYourBond: [BuildYourBond] = [
            BuildYourBond(name: "Navigate Conflict Together", imageName: "Conflict"),
            BuildYourBond(name: "Rekindle Honeymoon Phase", imageName: "Rekindle"),
            BuildYourBond(name: "Establishing Good Communication", imageName: "communication")]
        
            return sampleBuildYourBond
    }
    
    func sampleMoods() -> [MoodCheckIn] {
        let mood: [MoodCheckIn] = [
            MoodCheckIn(label: "Me", imageName: "calm", moodLabel: "Calm"),
            MoodCheckIn(label: "Her", imageName: "drained", moodLabel: "Drained")
        ]
        return mood
    }
    //Profile data
    func loadProfileData() {

        userProfile = UserProfile(
            name: "Name",
            email: "name@email.com",
            profileImageName: "Profile"
        )

        profileSections = [
           
            ProfileSection(
                title: "Account",
                items: [
                    ProfileItem(title: "Personal Info", iconName: "slider.horizontal.3", showsChevron: true)
                ]
            ),
            ProfileSection(
                title: "Activity",
                items: [
                    ProfileItem(title: "Status", iconName: "slider.horizontal.3", showsChevron: true)
                    
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

//    func loadCheckIn() {
//        let sampleCheckIn: [DailyCheckIn] = [
//            DailyCheckIn(Title: "Daily Check-In", imageName: "calm", Subtitle: "Get personalised exercises based on your relationship")
//        ]
//        
//        self.checkin = sampleCheckIn
//    }
    func setHisMood(_ mood: Mood) {
        HisMood = mood
        print("His mood ", mood.title)
    }

//    func setHisMood(moodId: Int) {
//        HisMood = mood(by: moodId)
//    }

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



    
    //calendar
    func getDayInfo(for date: Date, color: UIColor) -> DayInfo {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.calendar = Calendar.current

        formatter.dateFormat = "EEE"
        let day = formatter.string(from: date)

        formatter.dateFormat = "dd"
        let dateNumber = formatter.string(from: date)

        return DayInfo(rawDate: date, day: day, date: dateNumber, color: color)
    }

    func getLastAndNext15Days() -> [DayInfo] {
        let calendar = Calendar.current
        let today = Date()
        var result: [DayInfo] = []
        
        // Last 15 days colors (RGB)
        let lastColors: [UIColor] = [
            UIColor(red: 164/255, green: 189/255, blue: 215/255, alpha: 1),
            UIColor(red: 240/255, green: 196/255, blue: 228/255, alpha: 1),
            UIColor(red: 200/255, green: 187/255,  blue: 240/255, alpha: 1),
            UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
        ]
        
        let white = UIColor.white
        
        // LAST 15 DAYS
        for offset in -15...(-1) {
            if let date = calendar.date(byAdding: .day, value: offset, to: today) {
                result.append(getDayInfo(for: date, color: lastColors.randomElement()!))
            }
        }
        
        // TODAY
        result.append(getDayInfo(for: today, color: white))
        
        // NEXT 15 DAYS
        for offset in 1...15 {
            if let date = calendar.date(byAdding: .day, value: offset, to: today) {
                result.append(getDayInfo(for: date, color: white))
            }
        }
        
        return result
    }
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
            // Add more for other activities
        ]
        
        self.smallmodal = sample
    }

//    func makeSmileData() {
//        MakeSmile(types: "Send Lovenote", imageName: "pencil.and.list.clipboard")
//        MakeSmile(types: "Love Tips", imageName: "lightbulb.max")
//        MakeSmile(types: "Activities for Her", imageName: "checklist")
//    }
    
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

    func loadMoodOptions() -> [Mood] {
        return [
            Mood(id: 1, title: "Joyful", imageName: "Joyful"),
            Mood(id: 2, title: "Playful", imageName: "Playful"),
            Mood(id: 3, title: "Peaceful", imageName: "Peaceful"),

            Mood(id: 4, title: "Satisfied", imageName: "Satisfied"),
            Mood(id: 5, title: "Calm", imageName: "calm"),
            Mood(id: 6, title: "Productive", imageName: "Productive"),

            Mood(id: 7, title: "Determined", imageName: "Determined"),
            Mood(id: 8, title: "Adventurous", imageName: "Adventurous"),
            Mood(id: 9, title: "Curious", imageName: "Curious"),

            Mood(id: 10, title: "Attached", imageName: "Attached"),
            Mood(id: 11, title: "Regretful", imageName: "Regretful"),
            Mood(id: 12, title: "Sad", imageName: "Sad"),

            Mood(id: 13, title: "Disappointed", imageName: "Disappointed"),
            Mood(id: 14, title: "Drained", imageName: "drained"),
            Mood(id: 15, title: "Angry", imageName: "Angry")
        ]
    }
    
    
    // unlock of activities in build your bond
    func unlockNextBondActivity( bondName: String,
                                 completedIndex: Int) {
       
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
