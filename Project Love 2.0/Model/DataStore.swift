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

    // MARK: - Vibe Session State (persisted across tab switches)
    var hasCompletedDailyCheckIn: Bool = false
    var resolvedVibeTitle: VibeTitle? = nil
    var hasAchievedNewVibe: Bool = false

    var currentUserId: UUID?
    var currentRelationshipId: UUID?
    var partnerUserId: UUID?
    var isUserA: Bool = false

    private var relationshipChannel: RealtimeChannelV2?
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
        stopPartnerDeletionListener()
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
        personalInfoSections = []
        savedMemories       = []
        // Reset vibe session state on sign-out
        hasCompletedDailyCheckIn = false
        resolvedVibeTitle        = nil
        hasAchievedNewVibe       = false
        suggestedActivities      = []
        loadPersonalInfoData()
        loadProfileData()
        loadSampleData()
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
                
                let activityName = json.title ?? json.name ?? "Activity"
                
                let activity = Activity(
                    id: json.id,
                    name: activityName,
                    description: json.description,
                    detailedDescription: json.detailedDescription,
                    modalDescription: json.modalDescription,
                    image: json.image,
                    time: json.time ?? "",
                    status: .none,
                    category: json.category,
                    scheduledDate: nil,
                    steps: json.steps,
                    location: json.location
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
    
        /// Returns the "type" prefix for a suggested activity name.
        /// e.g. "Love Note: Sweet Morning" → "Love Note",
        ///      "Blindfolded Route Road"   → "Activity"
        func suggestionTypePrefix(_ name: String) -> String {
            if let colonIndex = name.firstIndex(of: ":") {
                return String(name[name.startIndex..<colonIndex]).trimmingCharacters(in: .whitespaces)
            }
            return "Activity"
        }

        /// Picks `count` activities from `pool` ensuring no two share the same type prefix.
        /// First selects one item per type (shuffled), then fills remaining slots from leftover items.
        private func diverseSelection(from pool: [Activity], count: Int) -> [Activity] {
            // Group by type prefix
            var byType: [String: [Activity]] = [:]
            for a in pool.shuffled() {
                let key = suggestionTypePrefix(a.name)
                byType[key, default: []].append(a)
            }

            var result: [Activity] = []
            var usedTypes: Set<String> = []

            // 1. Pick one from each type (shuffled order)
            for (type, items) in byType.shuffled() {
                guard result.count < count else { break }
                if let pick = items.first {
                    result.append(pick)
                    usedTypes.insert(type)
                }
            }

            // 2. If we still need more, fill from remaining items (avoiding duplicates)
            if result.count < count {
                let usedNames = Set(result.map { $0.name })
                let remaining = pool.shuffled().filter { !usedNames.contains($0.name) }
                for item in remaining {
                    guard result.count < count else { break }
                    result.append(item)
                }
            }

            return result
        }

        @discardableResult
        func getSuggestedActivitiesForDailyCheckIn(selection: DailyCheckInSelection) -> [Activity] {
            lastDailyCheckInSelection = selection
            let group = resolveSuggestionGroup(selection: selection)
            lastSuggestionGroup = group
            let pool = groupedSuggestedActivities[group] ?? Array(groupedSuggestedActivities.values.flatMap { $0 })
            let count = 4

            // Separate activities with steps vs without steps
            let withSteps    = pool.filter { $0.steps != nil && !($0.steps?.isEmpty ?? true) }
            let withoutSteps = pool.filter { $0.steps == nil  ||  ($0.steps?.isEmpty ?? true) }

            // Try to build: (count-1) non-step picks + 1 step pick
            var nonStepPicks = diverseSelection(from: withoutSteps, count: count - 1)
            let stepPick     = withSteps.shuffled().first

            var result = nonStepPicks
            if let lastActivity = stepPick {
                result.append(lastActivity)
            }

            // Pad to exactly `count` if we're short (e.g. no step activity or thin pool)
            if result.count < count {
                let usedNames = Set(result.map { $0.name })
                let extras = pool.shuffled().filter { !usedNames.contains($0.name) }
                for extra in extras {
                    guard result.count < count else { break }
                    result.append(extra)
                }
            }

            // Trim to exactly `count` (should never exceed, but be safe)
            let final = materializeSuggestedActivities(Array(result.prefix(count)))
            self.suggestedActivities = final
            return final
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
    func refreshSuggestionsAfterFeedback(coupleActivityId: UUID) async -> [Activity] {
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

        // Exclude the just-completed activity
        let filtered = pool.filter { $0.coupleActivityId != coupleActivityId }
        let count = 4

        // Separate activities with steps vs without steps
        let withSteps = filtered.filter { $0.steps != nil && !($0.steps?.isEmpty ?? true) }
        let withoutSteps = filtered.filter { $0.steps == nil || ($0.steps?.isEmpty ?? true) }

        let nonStepPicks = diverseSelection(from: withoutSteps, count: count - 1)
        let stepPick = withSteps.shuffled().first

        var result = nonStepPicks
        if let lastActivity = stepPick {
            result.append(lastActivity)
        } else {
            let result = materializeSuggestedActivities(diverseSelection(from: filtered, count: count))
            return result
        }

        result = materializeSuggestedActivities(result)
        return result
    }

    private func normalize(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    private func exploreCategoryName(from suggestion: Activity) -> String? {
        let trimmedName = suggestion.name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedName.hasPrefix("Explore:") else { return nil }

        let rawCategory = trimmedName
            .replacingOccurrences(of: "Explore:", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        let cleanedCategory = rawCategory.replacingOccurrences(
            of: "\\s*\\([^)]*\\)\\s*$",
            with: "",
            options: .regularExpression
        )

        return cleanedCategory.isEmpty ? nil : cleanedCategory
    }

    private func materializeExploreSuggestion(
        _ suggestion: Activity,
        usedNames: inout Set<String>
    ) -> Activity {
        guard let categoryName = exploreCategoryName(from: suggestion) else {
            usedNames.insert(suggestion.name.lowercased())
            return suggestion
        }

        let candidates = activities
            .filter { $0.category == categoryName }
            .shuffled()

        if let concreteActivity = candidates.first(where: { candidate in
            !usedNames.contains(candidate.name.lowercased())
        }) {
            usedNames.insert(concreteActivity.name.lowercased())
            return concreteActivity
        }

        usedNames.insert(suggestion.name.lowercased())
        return suggestion
    }

    private func materializeSuggestedActivities(_ suggestions: [Activity]) -> [Activity] {
        var usedNames = Set<String>()
        return suggestions.map { suggestion in
            var mat = materializeExploreSuggestion(suggestion, usedNames: &usedNames)
            
            if let existing = self.activities.first(where: { $0.name == mat.name }) {
                mat.status = existing.status
                mat.coupleActivityId = existing.coupleActivityId
                mat.scheduledDate = existing.scheduledDate
            }
            
            return mat
        }
    }

    /// Maps the three Quick Vibe Check answers to one of the 12 relationship titles.
    /// Priority: most-specific combos first, generic catch-alls last.
    func resolveVibeTitle(vibe: String, need: String, closeness: String) -> VibeTitle {
        let v = normalize(vibe)
        let n = normalize(need)
        let c = normalize(closeness)

        let isVibing = v == "vibing"
        let isSynced = v == "synced"
        let isMeh    = v == "meh"
        let isDry    = v == "dry"

        let isQualityTime = n == "quality time"
        let isReassurance = n == "reassurance"
        let isDeepConvo   = n == "deep convo"
        let isSpace       = n == "space"

        let isAttached     = c == "attached"
        let isKindaClose   = c == "kinda close"
        let isChill        = c == "chill"
        let isDisconnected = c == "disconnected"

        // 1. The Always-Attached
        if isVibing && isQualityTime && isAttached {
            return VibeTitle(name: "The Always-Attached",
                             description: "You're inseparable right now—high energy, constant connection, and loving every second together.",
                             pageDescription: "Since you're both vibing and prioritizing quality time, you've created a beautiful, high-energy bubble. Choosing to stay so attached right now means you aren't just 'hanging out'—you're fully immersed in each other's world, making every second together feel like a core memory.")
        }
        if isVibing && isReassurance && isAttached {
            return VibeTitle(name: "The Always-Attached",
                             description: "You're inseparable right now—high energy, constant connection, and loving every second together.",
                             pageDescription: "You're combining a great vibe with intentional reassurance, which makes your current attached state feel incredibly secure. Hearing 'I've got you' while the energy is high acts like premium fuel for your connection, allowing you both to be your most vibrant, authentic selves.")
        }
        if isVibing && isDeepConvo && isAttached {
            return VibeTitle(name: "The Always-Attached",
                             description: "You're inseparable right now—high energy, constant connection, and loving every second together.",
                             pageDescription: "By pairing a playful vibe with a deep conversation, you've reached a state of total attachment where your hearts and minds are perfectly locked in. This is that rare 'soulmate' energy where a silly joke can instantly transition into a profound realization about your future together.")
        }
        // 2. The In-Sync Duo
        if isSynced && isQualityTime && isAttached {
            return VibeTitle(name: "The In-Sync Duo",
                             description: "Everything just flows—you're aligned, balanced, and naturally in sync with each other.",
                             pageDescription: "Because you're feeling synced and making quality time a priority, being attached feels completely effortless. You're moving as one unit without even trying; there's no pressure to 'perform' because your natural alignment makes just being in the same room feel exactly right.")
        }
        if isSynced && isDeepConvo && isAttached {
            return VibeTitle(name: "The In-Sync Duo",
                             description: "Everything just flows—you're aligned, balanced, and naturally in sync with each other.",
                             pageDescription: "You're finishing each other's sentences today. Because you're so synced, diving into a deep conversation only strengthens your attachment. It's one of those moments where you feel completely understood without having to over-explain a single thing.")
        }
        if isSynced && isReassurance && isAttached {
            return VibeTitle(name: "The In-Sync Duo",
                             description: "Everything just flows—you're aligned, balanced, and naturally in sync with each other.",
                             pageDescription: "You're perfectly synced on where you stand, so adding reassurance to your attached state isn't about fixing a problem—it's about celebrating your strength. You're staying proactive about your affection, ensuring your foundation remains rock-solid.")
        }
        // 9. The Power-Builders
        if isSynced && isSpace && isAttached {
            return VibeTitle(name: "The Power-Builders",
                             description: "You're focused, intentional, and building something meaningful together.",
                             pageDescription: "You are perfectly synced on your goals, so taking space doesn't weaken your attachment—it fuels it. This is 'power couple' energy: you're both working hard on your individual paths while remaining deeply tethered to your shared future.")
        }
        if isVibing && isSpace && isAttached {
            return VibeTitle(name: "The Power-Builders",
                             description: "You're focused, intentional, and building something meaningful together.",
                             pageDescription: "The vibe is high because you're both thriving. By choosing space while staying attached, you're acting as each other's loudest fans from the sidelines. You have the trust to let each other grow without ever losing your grip on one another.")
        }
        // 10. The Mending Souls
        if isMeh && isReassurance && isAttached {
            return VibeTitle(name: "The Mending Souls",
                             description: "You're putting in the effort to heal, grow, and make things better together.",
                             pageDescription: "Even with a meh mood, you've reached for reassurance to keep your attachment strong. You're choosing to stay close through the 'work' of the relationship, proving that love is a verb and that you're committed to mending any gaps together.")
        }
        if isMeh && isDeepConvo && isAttached {
            return VibeTitle(name: "The Mending Souls",
                             description: "You're putting in the effort to heal, grow, and make things better together.",
                             pageDescription: "You're using a deep conversation to tackle the meh feelings head-on. By staying attached while facing the tough stuff, you're doing the brave work required for a breakthrough. This is how a bond becomes unbreakable.")
        }
        // 11. The Fresh-Start Pair
        if isVibing && isReassurance && isKindaClose {
            return VibeTitle(name: "The Fresh-Start Pair",
                             description: "Things are improving—you're rediscovering each other and rebuilding the spark.",
                             pageDescription: "The sun is breaking through! You're vibing again, and using reassurance to bridge the gap as you move from kinda close back to total intimacy. It's a hopeful, tender time where every positive interaction feels like a new beginning.")
        }
        if isVibing && isQualityTime && isKindaClose {
            return VibeTitle(name: "The Fresh-Start Pair",
                             description: "Things are improving—you're rediscovering each other and rebuilding the spark.",
                             pageDescription: "You're rediscovering the fun! By pairing a great vibe with quality time, you're stepping out of old patterns. Staying kinda close gives you the room to 'date' each other again and rebuild that spark at a pace that feels fresh.")
        }
        // 3. The Deep-Dive Duo
        if isDeepConvo && isAttached {
            return VibeTitle(name: "The Deep-Dive Duo",
                             description: "Your bond thrives on meaningful conversations and truly understanding each other.",
                             pageDescription: "Regardless of your general mood, choosing a deep conversation while staying so attached shows how much you value the 'truth' of your bond. This vulnerability is the glue keeping you tight today, proving you can handle the weight of real, unfiltered intimacy.")
        }
        if isSynced && isDeepConvo && isKindaClose {
            return VibeTitle(name: "The Deep-Dive Duo",
                             description: "Your bond thrives on meaningful conversations and truly understanding each other.",
                             pageDescription: "You're perfectly synced in your thoughts, and using deep conversation to explore new layers. Even though you're keeping a little breathing room by staying kinda close, these meaningful talks are the bridge that keeps your hearts tethered and growing.")
        }
        if isVibing && isDeepConvo && isKindaClose {
            return VibeTitle(name: "The Deep-Dive Duo",
                             description: "Your bond thrives on meaningful conversations and truly understanding each other.",
                             pageDescription: "Since the vibe is so good, it feels safe to open up. You're using deep conversation to rediscover each other, and staying kinda close allows that discovery to happen at a pace that feels natural, unforced, and exciting.")
        }
        // 4. The Independent Hearts
        if isSpace && isAttached {
            return VibeTitle(name: "The Independent Hearts",
                             description: "You're strong together but equally value your individuality and personal space.",
                             pageDescription: "You've chosen to take some space, yet you feel completely attached. This is the peak of relationship security—being able to thrive in your own separate lanes while knowing, with total certainty, that your partner is still your ultimate home base.")
        }
        if isSynced && isSpace && isKindaClose {
            return VibeTitle(name: "The Independent Hearts",
                             description: "You're strong together but equally value your individuality and personal space.",
                             pageDescription: "You're both synced in your need for a breather. By choosing space while remaining kinda close, you're honoring your individuality without losing your connection. This balanced rhythm makes the moments when you do come together feel refreshed and intentional.")
        }
        if isVibing && isSpace && isKindaClose {
            return VibeTitle(name: "The Independent Hearts",
                             description: "You're strong together but equally value your individuality and personal space.",
                             pageDescription: "The vibe is light and fun, which makes taking a little space feel healthy rather than distant. By staying kinda close, you're enjoying the best of both worlds: honoring the 'you' outside of the relationship while keeping the 'us' fresh and happy.")
        }
        // 5. The Reassurers
        if isReassurance && isAttached {
            return VibeTitle(name: "The Reassurers",
                             description: "Care and emotional safety come first—you constantly check in and support each other.",
                             pageDescription: "You've prioritized reassurance above all else today, making your attached state feel like a safe harbor. Regardless of the outside world, that extra 'I'm here for you' is acting as a shield for your hearts, ensuring emotional safety comes first.")
        }
        if isSynced && isReassurance && isKindaClose {
            return VibeTitle(name: "The Reassurers",
                             description: "Care and emotional safety come first—you constantly check in and support each other.",
                             pageDescription: "You're synced up and checking in. By offering reassurance while staying kinda close, you're reinforcing the 'why' behind your partnership. It's a soft, supportive way to keep your connection growing without the pressure of being inseparable.")
        }
        if isVibing && isReassurance && isKindaClose {
            return VibeTitle(name: "The Reassurers",
                             description: "Care and emotional safety come first—you constantly check in and support each other.",
                             pageDescription: "With such a positive vibe, using reassurance right now is like pouring extra love into the 'emotional bank account.' Staying kinda close means you're giving each other room to breathe while making sure you both feel deeply seen and celebrated.")
        }
        // 6. The Routine-Steady
        if isSynced && isChill {
            return VibeTitle(name: "The Routine-Steady",
                             description: "Things feel calm and predictable—comfortable, but maybe missing a little spark.",
                             pageDescription: "You've hit a peaceful plateau. Because you're synced and feeling chill, there's no drama and no rush. This 'quiet comfort' is the result of a connection that doesn't need high-voltage energy to feel solid; your reliability is its own kind of romance.")
        }
        if isVibing && isChill {
            return VibeTitle(name: "The Routine-Steady",
                             description: "Things feel calm and predictable—comfortable, but maybe missing a little spark.",
                             pageDescription: "The vibe is good and the connection is chill. You're finding joy in the simple, everyday version of your love. Without the pressure to solve problems or plan big events, you're just enjoying the relaxed rhythm of being a pair.")
        }
        // 7. The Life-Logistics Team
        if isMeh && isQualityTime && isChill {
            return VibeTitle(name: "The Life-Logistics Team",
                             description: "You function like a perfect team in daily life, even if romance is on the backseat.",
                             pageDescription: "Even if the mood feels a bit meh, you're still choosing quality time in a chill way. You're functioning like a solid team, successfully navigating the routine of life together. Your loyalty shows in the fact that you're still choosing each other's company.")
        }
        if isMeh && isKindaClose {
            return VibeTitle(name: "The Life-Logistics Team",
                             description: "You function like a perfect team in daily life, even if romance is on the backseat.",
                             pageDescription: "Things might feel a little meh right now, but staying kinda close keeps you moving forward. You're checking off the boxes of daily life with efficiency, proving that a lasting relationship is a partnership of action and support, even when the spark is resting.")
        }
        // 8. The Wave-Riders
        if isVibing && isDisconnected {
            return VibeTitle(name: "The Wave-Riders",
                             description: "Your connection comes in highs and lows—passionate, but not always consistent.",
                             pageDescription: "You're vibing well in the moment, even if you feel a bit disconnected overall. It's like two separate islands enjoying the same beautiful sunset—enjoy the 'up' swing of the energy for what it is while you navigate the distance between you.")
        }
        if isSynced && isDisconnected {
            return VibeTitle(name: "The Wave-Riders",
                             description: "Your connection comes in highs and lows—passionate, but not always consistent.",
                             pageDescription: "You're synced on the facts of life, but the emotional connection feels a bit disconnected today. You're moving in the same direction, navigating the ebb and flow of a complex duo, and showing that you can still function as a team even when you feel far apart.")
        }
        // 12. The High-Emotion Duo
        if isMeh && isAttached {
            return VibeTitle(name: "The High-Emotion Duo",
                             description: "Big feelings, big energy—your relationship is intense, exciting, and evolving.",
                             pageDescription: "The mood might be meh, but your attachment is fierce. You aren't letting a temporary feeling push you apart; instead, you're clinging tighter. This is a high-stakes, intense kind of loyalty that proves your commitment outweighs your current mood.")
        }
        if isDry && isAttached {
            return VibeTitle(name: "The High-Emotion Duo",
                             description: "Big feelings, big energy—your relationship is intense, exciting, and evolving.",
                             pageDescription: "Things feel a bit dry or quiet, yet you've remained firmly attached. You're holding on through a lull in the spark, refusing to let a quiet day define your bond. You're in the trenches together, and that shared resilience is everything.")
        }
        // Default fallback
        return VibeTitle(name: "The Wave-Riders",
                         description: "Your connection comes in highs and lows—passionate, but not always consistent.",
                         pageDescription: "Your connection comes in highs and lows—passionate, but not always consistent. Enjoy the 'up' swing of the energy for what it is while you navigate the distance between you.")
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
        QnAOption(text: "Him", isSelected: false),
        QnAOption(text: "Her", isSelected: false)
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
                name: json.title ?? json.name ?? "Activity",
                description: json.description,
                detailedDescription: json.detailedDescription,
                image: json.image,
                time: json.time ?? "",
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
        let combined = self.suggestedActivities + materializeSuggestedActivities(newBatch)
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
                        ProfileItem(title: "Personal Info", iconName: "slider.horizontal.3", showsChevron: true),
                        ProfileItem(title: "Partner Info", iconName: "slider.horizontal.3", showsChevron: true)
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
        case "him":   return "her"
        case "her": return "him"
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

        // Ensure section structures exist so setPersonalInfoValue has somewhere to write
        if profileSections.isEmpty { loadProfileData() }
        if personalInfoSections.isEmpty { loadPersonalInfoData() }

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
        if let jsonActivity = bondJSONActivities.first(where: { ($0.title ?? $0.name) == activityTitle }),
           let steps = jsonActivity.steps, !steps.isEmpty {
            return parseJSONSteps(steps)
        }

        // Check explore activities JSON (activities.json) for explore/her/him activities
        if let jsonActivity = exploreJSONActivities.first(where: { ($0.title ?? $0.name) == activityTitle }),
           let steps = jsonActivity.steps, !steps.isEmpty {
            return parseJSONSteps(steps)
        }
        
        // Check suggested activities JSON (suggestedActivity.json)
        if let jsonActivity = suggestedJSONActivities.first(where: { ($0.title ?? $0.name) == activityTitle }),
           let steps = jsonActivity.steps, !steps.isEmpty {
            return parseJSONSteps(steps)
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
                        name: json.title ?? json.name ?? "Activity",
                        description: json.description,
                        detailedDescription: json.detailedDescription,
                        image: json.image,
                        time: json.time ?? "",
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
        updateStatus(for: activity, status: .completed, scheduledDate: nil)
        removeSuggestedActivity(activity)

        guard let coupleActivityId = activity.coupleActivityId else {
            return
        }

        Task {
            do {
                try await SupabaseManager.shared.completeActivity(
                    coupleActivityId: coupleActivityId
                )
            } catch {
                print("Failed to mark activity completed in Supabase: \(error)")
            }
        }
    }
    
    func markActivityOngoing(activity: Activity) {
        updateStatus(for: activity, status: .ongoing, scheduledDate: nil)
    }
    func markActivityNone(activity: Activity) {
        updateStatus(for: activity, status: .none, scheduledDate: nil)
    }

    func startActivity(_ activity: Activity, completion: ((UUID?) -> Void)? = nil) {

        if let index = activities.firstIndex(where: {
            $0.name == activity.name &&
            $0.category == activity.category
        }) {
            // Do nothing here, updateStatus below handles it
        } else {
            var newActivity = activity
            newActivity.status = .ongoing
            activities.append(newActivity)
        }
        
        self.markActivityOngoing(activity: activity)

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

                // Store the coupleActivityId back on the local activity in all arrays
                self.updateCoupleActivityId(for: activity, coupleActivityId: coupleActivity.coupleActivityId)

                // Send notification to partner — but skip Memory Jar activities:
                // those already send a "memory_added" notification inside
                // MemoryUploadManager once the memory is actually saved.
                let isMemoryJarActivity = activity.name.lowercased().hasPrefix("memory jar")
                if !isMemoryJarActivity {
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
    func checkPartnerDeletion() async -> Bool {
        // Only relevant if we previously had an active relationship
        guard currentRelationshipId != nil else { return false }

        do {
            let session = try await SupabaseManager.shared.client.auth.session
            let uid = session.user.id

            struct RelCheck: Decodable {
                let relationship_id: UUID?
            }

            let rows: [RelCheck] = try await SupabaseManager.shared.client
                .from("users")
                .select("relationship_id")
                .eq("user_id", value: uid.uuidString)
                .limit(1)
                .execute()
                .value

            // If the DB says relationship_id is now NULL → partner deleted
            if let row = rows.first, row.relationship_id == nil {
                // Clear local state
                self.currentRelationshipId = nil
                self.partnerUserId = nil
                return true
            }
        } catch {
            print("DEBUG: checkPartnerDeletion error: \(error)")
        }

        return false
    }

    /// Start a Supabase Realtime listener that fires instantly when
    /// the partner deletes their account (our relationship_id becomes NULL).
    func startPartnerDeletionListener() {
        guard let uid = currentUserId,
              currentRelationshipId != nil else { return }

        let channel = SupabaseManager.shared.client.channel("partner-deletion")

        let userChanges = channel.postgresChange(
            UpdateAction.self,
            schema: "public",
            table: "users",
            filter: "user_id=eq.\(uid.uuidString)"
        )

        Task {
            do {
                try await channel.subscribe()
                self.relationshipChannel = channel

                for await change in userChanges {
                    let newRecord = change.record

                    // Check if relationship_id was set to null
                    if let relValue = newRecord["relationship_id"],
                       relValue.value is NSNull || relValue.stringValue == nil || relValue.stringValue == "" {
                        // Partner deleted their account
                        await MainActor.run {
                            self.currentRelationshipId = nil
                            self.partnerUserId = nil
                            NotificationCenter.default.post(
                                name: .partnerAccountDeleted,
                                object: nil
                            )
                        }
                        // Unsubscribe after firing
                        await channel.unsubscribe()
                        self.relationshipChannel = nil
                        break
                    }
                }
            } catch {
                print("DEBUG: partnerDeletionListener error: \(error)")
            }
        }
    }

    /// Stop listening for partner deletion (call on sign-out).
    func stopPartnerDeletionListener() {
        Task {
            await relationshipChannel?.unsubscribe()
            relationshipChannel = nil
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
        // Return both preset and custom activities that are ongoing
        let presetOngoing = activities.filter { $0.status == .ongoing }
        let customOngoing = customActivities.filter { $0.status == .ongoing }
        let allOngoing = presetOngoing + customOngoing
        
        let excludedKeywords = ["nudge", "love note", "love tip", "memory jar", "explore"]
        return allOngoing.filter { activity in
            
            // Filter out items that the current user has already given feedback for
            if let id = activity.coupleActivityId,
               let dbCoupleActivity = coupleActivities.first(where: { $0.coupleActivityId == id }) {
                if isUserA && dbCoupleActivity.feedbackADone { return false }
                if !isUserA && dbCoupleActivity.feedbackBDone { return false }
            }
            
            let lowerName = activity.name.lowercased()
            let lowerCategory = activity.category.lowercased()
            
            // Check if name OR category contains any of the excluded keywords
            return !excludedKeywords.contains(where: { keyword in
                lowerName.contains(keyword) || lowerCategory.contains(keyword)
            })
        }
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
                self.isUserA = (relationship.user1_id == authUserId)
                self.partnerAssessmentPreferences = nil

                // Check for overdue scheduled love notes on every app launch
                await checkScheduledLoveNotes(relationshipId: relationship.relationship_id)
            } else {
            }
        } catch {
        }
    }

    /// Flip overdue scheduled love notes to is_sent=true and notify the receiver.
    /// Runs on app launch (from loadUserContext) so it works even if the
    /// Love Note screen is never opened.
    func checkScheduledLoveNotes(relationshipId: UUID) async {
        do {
            let updatedNotes: [DBLoveNote] = try await SupabaseManager.shared.client
                .from("love_notes")
                .update(["is_sent": true])
                .eq("relationship_id", value: relationshipId.uuidString)
                .eq("is_sent", value: false)
                .lte("scheduled_for", value: Date().ISO8601Format())
                .not("scheduled_for", operator: .is, value: "null")
                .select()
                .execute()
                .value

            for note in updatedNotes {
                do {
                    try await NotificationService.shared.sendDirectNotification(
                        relationshipId: relationshipId,
                        senderUserId: note.user_id,
                        receiverUserId: note.partner_user_id,
                        type: "love_note_sent",
                        message: "Your partner sent you a love note 💌",
                        entityType: "love_note",
                        entityId: note.love_note_id.uuidString
                    )
                } catch {
                    print("DEBUG checkScheduledLoveNotes notification error: \(error)")
                }
            }

            if !updatedNotes.isEmpty {
                print("DEBUG checkScheduledLoveNotes: flipped \(updatedNotes.count) notes")
            }
        } catch {
            print("DEBUG checkScheduledLoveNotes error: \(error)")
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
                    let status: ActivityStatus = {
                        switch row.status {
                        case "ongoing": return .ongoing
                        case "completed": return .completed
                        case "scheduled": return .scheduled
                        default: return .none
                        }
                    }()
                    return Activity(
                        coupleActivityId: row.coupleActivityId,
                        name: row.activityName,
                        description: row.description ?? "",
                        image: "Activityimage",
                        time: displayDate,
                        status: status,
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
                            self.activities[index].scheduledDate = nil
                        case "completed":
                            self.activities[index].status = .completed
                            self.activities[index].scheduledDate = nil
                        case "scheduled":
                            self.activities[index].status = .scheduled
                            self.activities[index].scheduledDate = coupleActivity.scheduledDate
                        default:
                            self.activities[index].status = .none
                            self.activities[index].scheduledDate = nil
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

                self.buildAllActivities()

                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .activitiesSynced, object: nil)
                }
            } catch {
                
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
        return suggestedActivities.filter { !isActivityCompleted($0) }
    }

    func isActivityCompleted(_ activity: Activity) -> Bool {
        if let match = activities.first(where: { matchesActivity($0, activity) }) {
            return match.status == .completed
        }

        if let match = allActivities.first(where: { matchesActivity($0, activity) }) {
            return match.status == .completed
        }

        return activity.status == .completed
    }

    func removeSuggestedActivity(_ activity: Activity) {
        suggestedActivities.removeAll { matchesActivity($0, activity) }
        buildAllActivities()

        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .activitiesSynced, object: nil)
        }
    }
    func updateScheduledDate(for activity: Activity, date: Date) {
        var scheduledActivity = activity
        scheduledActivity.status = .scheduled
        scheduledActivity.scheduledDate = date

        let updatedActivities = updateActivity(in: &activities, with: scheduledActivity)
        let updatedSuggestedActivities = updateActivity(in: &suggestedActivities, with: scheduledActivity)
        var updatedBondActivity = false

        for pageIndex in bondpage.indices {
            let didUpdate = updateActivity(in: &bondpage[pageIndex].activity, with: scheduledActivity)
            updatedBondActivity = updatedBondActivity || didUpdate
        }

        if !updatedActivities && !updatedSuggestedActivities && !updatedBondActivity {
            activities.append(scheduledActivity)
        }

        buildAllActivities()

        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .activitiesSynced, object: nil)
        }

        guard let relationshipId = currentRelationshipId,
              let userId = currentUserId else {
            return
        }

        Task {
            do {
                let coupleActivity = try await SupabaseManager.shared.scheduleActivity(
                    relationshipId: relationshipId,
                    userId: userId,
                    activity: scheduledActivity,
                    scheduledDate: date
                )

                DispatchQueue.main.async {
                    self.updateCoupleActivityId(
                        for: scheduledActivity,
                        coupleActivityId: coupleActivity.coupleActivityId
                    )
                    NotificationCenter.default.post(name: .activitiesSynced, object: nil)
                }
            } catch {
                
            }
        }
    }

    func getScheduledActivities() -> [Activity] {
        return activities.filter {
            $0.status == .scheduled && $0.scheduledDate != nil
        }
    }
    func buildAllActivities() {
        var mergedActivities: [Activity] = []

        // Explore
        mergeActivities(from: activities, into: &mergedActivities)

        // Suggested (Vibe)
        mergeActivities(from: suggestedActivities, into: &mergedActivities)

        // Build Your Bond
        bondpage.forEach { page in
            mergeActivities(from: page.activity, into: &mergedActivities)
        }

        allActivities = mergedActivities
    }

    @discardableResult
    private func updateActivity(in source: inout [Activity], with updatedActivity: Activity) -> Bool {
        if let index = source.firstIndex(where: { matchesActivity($0, updatedActivity) }) {
            source[index] = mergeActivity(source[index], with: updatedActivity)
            return true
        }

        return false
    }

    private func updateCoupleActivityId(for activity: Activity, coupleActivityId: UUID) {
        updateCoupleActivityId(in: &activities, for: activity, coupleActivityId: coupleActivityId)
        updateCoupleActivityId(in: &suggestedActivities, for: activity, coupleActivityId: coupleActivityId)

        for pageIndex in bondpage.indices {
            updateCoupleActivityId(
                in: &bondpage[pageIndex].activity,
                for: activity,
                coupleActivityId: coupleActivityId
            )
        }

        buildAllActivities()
    }

    private func updateCoupleActivityId(
        in source: inout [Activity],
        for activity: Activity,
        coupleActivityId: UUID
    ) {
        guard let index = source.firstIndex(where: { matchesActivity($0, activity) }) else {
            return
        }

        source[index].coupleActivityId = coupleActivityId
    }

    private func matchesActivity(_ lhs: Activity, _ rhs: Activity) -> Bool {
        if let lhsId = lhs.id, let rhsId = rhs.id, lhsId == rhsId {
            return true
        }

        return lhs.name == rhs.name && lhs.category == rhs.category
    }

    private func mergeActivity(_ existing: Activity, with updated: Activity) -> Activity {
        Activity(
            id: existing.id ?? updated.id,
            coupleActivityId: updated.coupleActivityId ?? existing.coupleActivityId,
            name: updated.name,
            description: updated.description,
            detailedDescription: updated.detailedDescription ?? existing.detailedDescription,
            image: updated.image,
            time: updated.time,
            status: updated.status,
            category: updated.category,
            scheduledDate: updated.scheduledDate,
            steps: updated.steps ?? existing.steps
        )
    }

    private func mergeActivities(from source: [Activity], into target: inout [Activity]) {
        for activity in source {
            if let index = target.firstIndex(where: { matchesActivity($0, activity) }) {
                target[index] = mergeActivity(target[index], with: activity)
            } else {
                target.append(activity)
            }
        }
    }

    private func updateStatus(for activity: Activity, status: ActivityStatus, scheduledDate: Date?) {
        updateStatus(in: &activities, for: activity, status: status, scheduledDate: scheduledDate)
        updateStatus(in: &suggestedActivities, for: activity, status: status, scheduledDate: scheduledDate)

        for pageIndex in bondpage.indices {
            updateStatus(
                in: &bondpage[pageIndex].activity,
                for: activity,
                status: status,
                scheduledDate: scheduledDate
            )
        }

        buildAllActivities()

        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .activitiesSynced, object: nil)
        }
    }

    private func updateStatus(
        in source: inout [Activity],
        for activity: Activity,
        status: ActivityStatus,
        scheduledDate: Date?
    ) {
        guard let index = source.firstIndex(where: { matchesActivity($0, activity) }) else {
            return
        }

        source[index].status = status
        source[index].scheduledDate = scheduledDate
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
