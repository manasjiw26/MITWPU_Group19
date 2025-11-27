//
//  DataStore.swift
//  Project Love 2.0
//
//  Created by SDC-USER on 26/11/25.
//

import Foundation
class DataStore {
    var activities: [Activity] = []
    var rewards: [Reward] = []
    var activityCategory: [ActivityCategory] = []
    
    init() {
        loadSampleData()
        loadSampleRewards()
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
    
    func getActivities() -> [Activity] {
        return activities
    }
    func getOngoingActivities() -> [Activity] {
        return activities.filter { $0.ongoing == true }
    }
    func getCompletedActivities() -> [Activity] {
        return activities.filter { $0.completed == true }
    }
}

// Create one shared instance
let dataStore = DataStore()
