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
    var completed: Bool
    var ongoing: Bool
}

struct ActivityCategory{
    var name : String
    var description : String
    var image : String
}

struct Reward{
    var image : String
    var name : String
}

struct DayInfo{
    // Original date for logic
    var rawDate: Date
    // Formatted display strings
    var day : String       // e.g. "Mon"
    var date : String      // e.g. "27"
    var color : UIColor
}

struct MakeSmile{
    var types: String
    var imageName: String    
}
struct BuildYourBond {
    var name : String
    var imageName: String
    
    
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
//struct DailyCheckIn {
//    var Title: String
//    var imageName: String
//    var Subtitle: String
//}
struct ActivityStats{
    var types: String
    var imageName: String
    var count: Int
}
struct SmallModalData{
    var title: String
    var mainImageName: String
    var descriptionLabel: String
    var pointsymbol: String
    var pointsLabel: String
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
