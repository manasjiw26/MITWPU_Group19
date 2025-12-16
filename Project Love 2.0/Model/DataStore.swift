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

   
    
    init() {
        loadSampleData()
        loadSampleRewards()
        loadSampleTips()
        moods = sampleMoods()
        loadSmallModalData()
        moodOptions = loadMoodOptions()
        //loadCheckIn()
        
    }
    private(set) var savedFeedback: [FeedBackGiven] = []

        func saveFeedback(_ feedback: FeedBackGiven) {
            savedFeedback.append(feedback)
            print(" Saved feedback:", feedback)
        }
   

    func loadSampleData() {
        let sampleActivities: [Activity] = [
            Activity(name: "Chill & Glow Sesh", description: "Facemasks, candles, chill beats — just cozy vibes and glow time", image: "Chill and Glow sesh", time: "5 mins",completed: false ,ongoing: true),
            Activity(name: "Petal Hunt", description: "Pick pretty blooms and build your own bouquet together.", image: "Activityimage", time: "5 mins",completed: false ,ongoing: false),
            Activity(name: "Wholesome Craft Challenge", description: "Make a doodle / note / digital collage for her", image: "Activityimage", time: "5 mins",completed: false ,ongoing: false),
            Activity(name: "Memory Lane Marathon", description: "Make a mini reel using your photos and favorite audio", image: "Activityimage", time: "5 mins",completed: true ,ongoing: false),
            Activity(name: "Stuff-A-Memory Day", description: "Buy a tiny plush, both name it and take care of it together", image: "Activityimage", time: "5 mins",completed: false ,ongoing: false),
            Activity(name: "Wholesome Craft Challenge", description: "Make a doodle / note / digital collage for her", image: "Activityimage", time: "5 mins",completed: true ,ongoing: false),
            Activity(name: "Memory Lane Marathon", description: "Make a mini reel using your photos and favorite audio", image: "Activityimage", time: "5 mins",completed: false ,ongoing: false),
            Activity(name: "Stuff-A-Memory Day", description: "Buy a tiny plush, both name it and take care of it together", image: "Activityimage", time: "5 mins",completed: false ,ongoing: true)
        ]
        self.activities = sampleActivities
    }
    
    func loadSampleRewards() {
        let sampleRewards: [Reward] = [
            Reward(image: "Send_Hug", name: "Send hug"),
            Reward(image: "Send_Flower", name: "Send flower"),
            Reward(image: "Send_Kiss", name: "Send kiss"),
            Reward(image: "Send_Heart", name: "Send heart"),
            Reward(image: "Send_Note", name: "Send note"),
            Reward(image: "Send_Wave", name: "Send wave"),
            Reward(image: "Send_Hug", name: "Send high five")
        ]
        
        self.rewards = sampleRewards
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
            BuildYourBond(name: "Navigating Conflicts together", imageName: "Conflict"),
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
    
//    func loadSteps() -> [StepsToFollow] {
//        let steps: [StepsToFollow] = [
//            StepsToFollow(number: 1, title: "Set the mood", descriptionLabel: "Dim the lights, light candles, and let the soft glow set your cozy vibe."),
//            StepsToFollow(number: 2, title: "Glow Prep", descriptionLabel: "Lay out your facemasks and favorite skincare treats for two."),
//            StepsToFollow(number: 3, title: "Chill & Connect", descriptionLabel: " Put on beats, sip something soothing, and enjoy the calm together."),
//            StepsToFollow(number: 4, title: "Mask & Mingle", descriptionLabel: "Apply your masks, relax side by side, and let the glow, good vibes sink in."),
//            ]
//        return steps
//        
//    }
//
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

        default:
            return []
        }
    }

//    func loadCheckIn() {
//        let sampleCheckIn: [DailyCheckIn] = [
//            DailyCheckIn(Title: "Daily Check-In", imageName: "calm", Subtitle: "Get personalised exercises based on your relationship")
//        ]
//        
//        self.checkin = sampleCheckIn
//    }
    
    func getActivities() -> [Activity] {
        return activities
    }
    func getOngoingActivities() -> [Activity] {
        return activities.filter { $0.ongoing == true }
    }
    func getCompletedActivities() -> [Activity] {
        return activities.filter { $0.completed == true }
    }
    func getTips() -> [Tip] {
        return tips
    }
    func getMood() -> [MoodCheckIn] {
        return moods
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
                pointsymbol: "star.fill",
                pointsLabel: "5 ",
                clockImageName: "clock",
                timerLabel: "5 mins"
            ),
            
            SmallModalData(
                title: "Petal Hunt",
                mainImageName: "Activityimage",
                descriptionLabel: "Pick pretty blooms and build your own bouquet together.",
                pointsymbol: "star.fill",
                pointsLabel: "5 ",
                clockImageName: "clock",
                timerLabel: "5 mins"
            )
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
                subTitle:"How did that activity make you feel?",
                imageName: "camera",
                userMessage: nil,
                selectedMood: nil
            ),
            
            FeedBackGiven(
                title: "Petal Hunt",
                subTitle: "How did that activity make you feel?",
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

}
// Create one shared instance
let dataStore = DataStore()
