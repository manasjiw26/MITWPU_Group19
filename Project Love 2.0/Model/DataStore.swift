//
//  DataStore.swift
//  Project Love 2.0
//
//  Created by SDC-USER on 26/11/25.
//

import Foundation
import UIKit
class DataStore {
    var activities: [Activity] = []
    var rewards: [Reward] = []
    var activityCategory: [ActivityCategory] = []
    var buildYourBond : [BuildYourBond] = []
    var tips: [Tip] = []
    var moods: [MoodCheckIn] = []
    var bondpage: [BuildYourBondpage] = []
    
    init() {
        loadSampleData()
        loadSampleRewards()
        loadSampleTips()
        sampleMoods()
        loadBuildYourbond()
        loadsampleBuildYourBond()
    }
    
    func loadSampleData() {
        let sampleActivities: [Activity] = [
            Activity(name: "Chill & Glow Sesh", description: "Facemasks, candles, chill beats — just cozy vibes and glow time", image: "", time: "5 mins",completed: false ,ongoing: true),
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
            BuildYourBond(name: "Navigate Conflict Together", imageName: "Conflict"),
            BuildYourBond(name: "Rekindle Honeymoon Phase", imageName: "Rekindle"),
            BuildYourBond(name: "Establishing Good Communication", imageName: "Communication")]
        
            return sampleBuildYourBond
    }
    
    func sampleMoods() -> [MoodCheckIn] {
        let moods: [MoodCheckIn] = [
            MoodCheckIn(label: "Me", imageName: "calm_icon", moodLabel: "Calm"),
            MoodCheckIn(label: "Her", imageName: "drained_icon", moodLabel: "Drained")
        ]
        return moods
    }
    func loadsampleBuildYourBond() {
        let bond :[BuildYourBondpage] = [
            BuildYourBondpage(
                Name: "Navigate Conflict Together",
                SubHeading: "Take each step together to rebuild your connection.",
                stepLabel:  "You are currently on Step 1: Identifying the Conflict.",
                step: ["Identify","Empathize","Solution","Sustain"],
                activity: [
                    Activity(name: "The Soft Start-Up", description: "Learn to bring up a complaint without blame or criticism.", image: "Activityimage", time: "5mins", completed: false, ongoing: false),
                    Activity(name: "The Empathy Bridge", description: "Understand your partner's experience and perspective.", image: "Activityimage", time: "5mins", completed: false, ongoing: false),
                    Activity(name: "Collaborative Sprint", description: "Shift from 'me vs you' to 'us vs the problem", image: "Activityimage", time: "5mins", completed: false, ongoing: false),
                    Activity(name: "The Pattern Interrupt", description: "Identify and break negative communication cycles.", image: "Activityimage", time: "5mins", completed: false, ongoing: false)
                ],
                badge: "Harmony Seeker",
                badgesubHeading: "Master the art of peaceful resolution.",
                HIWStep: ["Identify the Conflict","Empathizing with Perspectives","Crafting Joint Solutions","Sustaining Harmony"]
            )
        ]
        self.bondpage = bond
    }
    func getBuildYourBondPages(name : String) -> BuildYourBondpage? {
        return bondpage.first { $0.Name == name }
    }
    
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
    
//    func makeSmileData() {
//        MakeSmile(types: "Send Lovenote", imageName: "pencil.and.list.clipboard")
//        MakeSmile(types: "Love Tips", imageName: "lightbulb.max")
//        MakeSmile(types: "Activities for Her", imageName: "checklist")
//    }
    
    
}
// Create one shared instance
let dataStore = DataStore()
