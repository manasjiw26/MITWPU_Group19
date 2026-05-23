import Foundation
import UserNotifications

class ScheduleManager {
    static let shared = ScheduleManager()
    
    private init() {}
    
    let morningMessages = [
        "Good morning! Did you send a good morning text? ☀️",
        "Start the day right! Send a quick Nudge. 👀"
    ]
    
    let afternoonMessages = [
        "Take a break and randomly pop a memory from your jar! 📸",
        "It's a great time to do something special for your partner! 💖"
    ]
    
    let nightMessages = [
        "Time to wrap up! Send a sweet good night message to your partner 🌙",
        "End your day perfectly with a quick Love Note! 💌",
        "A late night cuddle reminder! 🥰"
    ]
    
    func scheduleAppSideNotifications() {
        let center = UNUserNotificationCenter.current()
        
        // Remove old pending notifications to avoid spam
        center.removeAllPendingNotificationRequests()
        
        // Schedule notifications up to 3 days in advance
        for dayOffset in 1...3 {
            // 1) Morning Notification (Between 8 AM and 11 AM)
            scheduleNotification(message: morningMessages.randomElement()!, baseDelayDays: dayOffset, hourRange: 8...11, identifier: "morning-\(dayOffset)")
            
            // 2) Afternoon Notification (Between 1 PM and 5 PM)
            scheduleNotification(message: afternoonMessages.randomElement()!, baseDelayDays: dayOffset, hourRange: 13...17, identifier: "afternoon-\(dayOffset)")
            
            // 3) Night Notification (Between 8 PM and 11 PM)
            scheduleNotification(message: nightMessages.randomElement()!, baseDelayDays: dayOffset, hourRange: 20...23, identifier: "night-\(dayOffset)")
        }
    }
    
    private func scheduleNotification(message: String, baseDelayDays: Int, hourRange: ClosedRange<Int>, identifier: String) {
        let center = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        content.title = "TwoTales"
        content.body = message
        content.sound = .default
        content.userInfo = ["notificationType": "motivational"]
        content.launchImageName = "AppIcon"
        
        // Calculate the future date
        var dateComponents = DateComponents()
        guard let futureDate = Calendar.current.date(byAdding: .day, value: baseDelayDays, to: Date()) else { return }
        
        dateComponents.year = Calendar.current.component(.year, from: futureDate)
        dateComponents.month = Calendar.current.component(.month, from: futureDate)
        dateComponents.day = Calendar.current.component(.day, from: futureDate)
        
        // Pick a random hour inside the given time block, and a random minute
        dateComponents.hour = Int.random(in: hourRange)
        dateComponents.minute = Int.random(in: 0...59)
        
        // Create trigger & request
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        center.add(request) { error in
            if let error = error {
                print("Error scheduling \(identifier): \(error)")
            }
        }
    }
    
    func cancelScheduledNotifications() {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
    }
    
    // MARK: - Testing
    func schedule5SecondTestNotification() {
        let center = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        content.title = "TEST NOTIFICATION"
        content.body = "If you see this, notifications are working! Tap me to deep-link."
        content.sound = .default
        content.userInfo = ["notificationType": "motivational"]
        
        // 5 seconds from right now
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5.0, repeats: false)
        let request = UNNotificationRequest(identifier: "TestNotification", content: content, trigger: trigger)
        
        center.add(request) { error in
            if let error = error {
                print("Error scheduling 5s test: \(error)")
            }
        }
    }
}
