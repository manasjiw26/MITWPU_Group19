//
//  VibeViewController.swift
//  Project Love 2.0
//
//  Created by SDC-USER on 25/11/25.
//

import UIKit
import Supabase

protocol LoveTipsSelectionDelegate: AnyObject {
    func didUpdateSelectedTips(_ tips: [Tip])
}

class VibeViewController: UIViewController,UICollectionViewDelegate,MoodCheckInCellDelegate, TellMoodSelectionDelegate, DailyCheckInCellDelegate, SmallModalDelegate, UIAdaptivePresentationControllerDelegate {
    
    @IBOutlet weak var vibeCollectionView: UICollectionView!
    @IBOutlet weak var showAllActivityButton: UIButton!
    @IBOutlet weak var secondOngoingActivityView: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var activityImage: UIImageView!
    @IBOutlet weak var ongoingActivitiesView: UIView!
    @IBOutlet weak var activityName: UILabel!
    @IBOutlet weak var notificationButton: UIBarButtonItem!
    
    var ongoingActivites: [Activity] = []
    var makeSmileData: [MakeSmile] = []
    var didScrollToMiddle = false
    var BuildBond : [BuildYourBond] = []
    var selectedbondOption: BuildYourBond?
    var hasCompletedDailyCheckIn = false
    var suggestedActivities: [Activity] = []
    var selectedTips: [Tip] = []
    
    let supabase = SupabaseManager.shared.client
    var partnerMoodTitle: String = "Waiting"
    var partnerMoodImage: String = "waiting"
    var myMoodTitle: String = "Not set"
    var myMoodImage: String = "neutral"
    
    var moodChannel: RealtimeChannelV2?
    var partnerDisplayText: String { DataStore.shared.partnerDisplayText }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkNotifications()
        BuildBond = dataStore.loadBuildYourbond()
        suggestedActivities = DataStore.shared.getSuggestedActivities()
        registerCell()
        vibeCollectionView.setCollectionViewLayout(generateLayout(), animated: true)
        vibeCollectionView.dataSource = self
        vibeCollectionView.delegate = self
        setupOngoing()
        configureOngoingActivity()

        // Refresh gender-dependent UI when preferences change (e.g. from Profile modal)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handlePreferencesChanged),
            name: .preferencesDidChange,
            object: nil
        )

        // Load user/relationship context from Supabase, then sync activities
        Task {
            await DataStore.shared.loadUserContext()
            DataStore.shared.syncActivitiesFromSupabase()
            await fetchPartnerMood()
        }
    }

    @objc private func handlePreferencesChanged() {
        makeSmileData = [
            MakeSmile(types: "Send Lovenote", imageName: "pencil.and.list.clipboard"),
            MakeSmile(types: "Love Tips", imageName: "lightbulb.max"),
            MakeSmile(types: "Activities for \(partnerDisplayText)", imageName: "checklist")
        ]
        vibeCollectionView.reloadData()
    }
    private func checkNotifications() {
        Task { @MainActor in
            do {
                let session = try await SupabaseManager.shared.client.auth.session
                let currentUserId = session.user.id
                let notifications = try await NotificationService.shared.fetchNotifications(for: currentUserId)
                let hasUnread = notifications.contains { !$0.isRead }

                if hasUnread {
                    if #available(iOS 15.0, *) {
                        let config = UIImage.SymbolConfiguration(paletteColors: [.systemRed, .label])
                        self.notificationButton.image = UIImage(systemName: "bell.badge.fill", withConfiguration: config)
                    } else {
                        self.notificationButton.image = UIImage(systemName: "bell.fill")
                        self.notificationButton.tintColor = .systemRed
                    }
                } else {
                    self.notificationButton.image = UIImage(systemName: "bell.fill")
                    self.notificationButton.tintColor = nil
                }
            } catch {
            }
        }
    }
    
    func setupOngoing(){
            ongoingActivitiesView.layer.cornerRadius = ongoingActivitiesView.layer.frame.height / 2
            secondOngoingActivityView.layer.cornerRadius = secondOngoingActivityView.layer.frame.height / 2
            ongoingActivitiesView.layer.masksToBounds = true
            secondOngoingActivityView.layer.masksToBounds = true
            ongoingActivitiesView.applyLiquidGlassEffect(animated: false)
            
        }
        func configureOngoingActivity(){
            ongoingActivites = DataStore.shared.getOngoingActivities()
            if(ongoingActivites.count > 1){
                ongoingActivitiesView.isHidden = false
                showAllActivityButton.isHidden = false
                secondOngoingActivityView.isHidden = false
                activityImage.image = UIImage(named: ongoingActivites[0].image)
                activityName.text = ongoingActivites[0].name
            }
            else if (ongoingActivites.count == 1){
                secondOngoingActivityView.isHidden = true
                showAllActivityButton.isHidden = true
                ongoingActivitiesView.isHidden = false
                activityImage.image = UIImage(named: ongoingActivites[0].image)
                activityName.text = ongoingActivites[0].name
            }
            else{
                ongoingActivitiesView.isHidden = true
                secondOngoingActivityView.isHidden = true
                showAllActivityButton.isHidden = true
            }
        }
    
    private var hasCheckedInToday: Bool {
        return myMoodTitle != "Not set"
    }
    
    func registerCell() {
        vibeCollectionView.register(UINib(nibName: "CalendarCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "calendar_cell")
        vibeCollectionView.register(UINib(nibName: "MoodCardCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "mood_cell")
        vibeCollectionView.register(UINib(nibName: "MakeHerSmileCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "makeSmile_cell")
        vibeCollectionView.register(UINib(nibName: "BuildYourBondCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "bond_cell")
        vibeCollectionView.register(UINib(nibName: "TitleCollectionResuableView", bundle: nil), forSupplementaryViewOfKind: "title", withReuseIdentifier: "title_cell")
        vibeCollectionView.register(UINib(nibName: "MoodCheckInCollectionViewCell", bundle: nil),forCellWithReuseIdentifier: "mood_checkin_cell")
        vibeCollectionView.register(UINib(nibName: "DailyCheckInCollectionViewCell", bundle: nil),forCellWithReuseIdentifier: "daily_CheckIn")
        vibeCollectionView.register(UINib(nibName: "SuggestedActivityCollectionViewCell", bundle: nil),forCellWithReuseIdentifier: "suggestedActivity_cell")
        vibeCollectionView.register(UINib(nibName: "RefreshActivityCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "refresh_cell")
        vibeCollectionView.register(
            UINib(nibName: "ScheduleCalendarCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "scheduleCalendar_cell"
        )

    }
    
    func generateLayout() ->UICollectionViewLayout{
        let layout = UICollectionViewCompositionalLayout { section, env in
            
            let largeTitleSize = NSCollectionLayoutSize(
                   widthDimension: .fractionalWidth(1.0),
                   heightDimension: .absolute(56)   // title + subtitle
               )

               let compactTitleSize = NSCollectionLayoutSize(
                   widthDimension: .fractionalWidth(1.0),
                   heightDimension: .absolute(34)   // title only
               )

               let largeTitleHeader = NSCollectionLayoutBoundarySupplementaryItem(
                   layoutSize: largeTitleSize,
                   elementKind: "title",
                   alignment: .top
               )

               let compactTitleHeader = NSCollectionLayoutBoundarySupplementaryItem(
                   layoutSize: compactTitleSize,
                   elementKind: "title",
                   alignment: .top
               )
            
            if section == 0 {
                                
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .absolute(52),heightDimension: .absolute(72)
                )
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .estimated(2200),
                    heightDimension: .absolute(72)
                )
                
                let group = NSCollectionLayoutGroup.horizontal(
                    layoutSize: groupSize,
                    subitems: [item])
                group.interItemSpacing = .fixed(20)
                
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .continuous
                
                section.interGroupSpacing = 10
                section.contentInsets = NSDirectionalEdgeInsets(top: 15, leading: 0, bottom: 15, trailing: 0)
                return section
            }
            else if section == 1  { //mood
                
                if !self.hasCheckedInToday { //how are feeling card
                    let itemSize = NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(160)
                    )
                    let item = NSCollectionLayoutItem(layoutSize: itemSize)
                    
                    let groupSize = NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(160)
                    )
                    let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
                    
                    let section = NSCollectionLayoutSection(group: group)
                    section.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 8, trailing: 16)
                    
                    return section
                }
                
                else { //mood cards
                    let itemSize = NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(0.5),   
                        heightDimension: .estimated(180)
                    )
                    let item = NSCollectionLayoutItem(layoutSize: itemSize)

                    item.contentInsets = NSDirectionalEdgeInsets(
                        top: 0,
                        leading: 4,
                        bottom: 0,
                        trailing: 4
                    )

                    let groupSize = NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1.0),
                        heightDimension: .estimated(220)
                    )

                    let group = NSCollectionLayoutGroup.horizontal(
                        layoutSize: groupSize,
                        subitems: [item, item]
                    )

                    let section = NSCollectionLayoutSection(group: group)
                    section.contentInsets = NSDirectionalEdgeInsets(
                        top: 30,
                        leading: 16,
                        bottom: 12,
                        trailing: 16
                    )
                    section.interGroupSpacing = 8

                    return section

                }
            } else if section == 2 {
                
                // Daily check in (before completing exercise)
                if !self.hasCompletedDailyCheckIn {

                    let itemSize = NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1.0),
                        heightDimension: .estimated(120)
                    )
                    let item = NSCollectionLayoutItem(layoutSize: itemSize)

                    let group = NSCollectionLayoutGroup.vertical(
                        layoutSize: itemSize,
                        subitems: [item]
                    )

                    let section = NSCollectionLayoutSection(group: group)
                    section.contentInsets = NSDirectionalEdgeInsets(
                        top: 12, leading: 16, bottom: 12, trailing: 16
                    )

                    return section
                }
                let normalWidth: CGFloat = 350
                let smallWidth: CGFloat = 80
                let spacing: CGFloat = 8
                let estimatedHeight: CGFloat = 120

                let activityCount = self.suggestedActivities.count
                let totalItems = activityCount < 6 ? activityCount + 1 : activityCount
                let totalWidth = (CGFloat(max(totalItems - 1, 0)) * spacing)
                + (CGFloat(activityCount) * normalWidth)
                + (activityCount < 6 ? smallWidth : 0)

                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .absolute(totalWidth),
                    heightDimension: .absolute(estimatedHeight)
                )

                let group = NSCollectionLayoutGroup.custom(layoutSize: groupSize) { environment in
                    
                    var items: [NSCollectionLayoutGroupCustomItem] = []
                    var xOffset: CGFloat = 0
                    
                    let activityCount = self.suggestedActivities.count
                    let totalItems = activityCount < 6 ? activityCount + 1 : activityCount
                    
                    for index in 0..<totalItems {
                        
                        let isRefreshCell = (activityCount < 6 && index == totalItems - 1)
                        let width = isRefreshCell ? smallWidth : normalWidth
                        
                        let frame = CGRect(x: xOffset, y: 0, width: width, height: estimatedHeight)
                        items.append(NSCollectionLayoutGroupCustomItem(frame: frame))
                        
                        xOffset += width + spacing
                    }
                    
                    return items
                }

                let sectionLayout = NSCollectionLayoutSection(group: group)

                sectionLayout.orthogonalScrollingBehavior = .continuous
                sectionLayout.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 16, bottom: 12, trailing: 16)
                sectionLayout.interGroupSpacing = 0
                let titleSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(52)
                )

                let titleHeader = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: titleSize,
                    elementKind: "title",
                    alignment: .top
                )

                titleHeader.contentInsets = NSDirectionalEdgeInsets(
                    top: 16,
                    leading: 0,
                    bottom: 0,
                    trailing: 16
                )

                sectionLayout.boundarySupplementaryItems = [titleHeader]

                return sectionLayout
            }

            else if section == 3 { //make her smile

                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .absolute(100),
                    heightDimension: .absolute(120)
                )
                let item = NSCollectionLayoutItem(layoutSize: itemSize)

                let groupWidth: CGFloat = 332
                
                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .absolute(groupWidth),
                    heightDimension: .absolute(120)
                )

                let group = NSCollectionLayoutGroup.horizontal(
                    layoutSize: groupSize,
                    subitems: [item, item, item]
                )
                group.interItemSpacing = .fixed(16)

                let section = NSCollectionLayoutSection(group: group)

                let containerWidth = env.container.effectiveContentSize.width
                let sideInset = max((containerWidth - groupWidth) / 2, 16)

                section.contentInsets = NSDirectionalEdgeInsets(
                    top: 8,
                    leading: sideInset,
                    bottom: 12,
                    trailing: sideInset
                )

                section.supplementaryContentInsetsReference = .none

                let titleSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(34)
                )

                let titleHeader = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: titleSize,
                    elementKind: "title",
                    alignment: .top
                )

                titleHeader.contentInsets = NSDirectionalEdgeInsets(
                    top: 0,
                    leading: 16,
                    bottom: 0,
                    trailing: 16
                )

                section.boundarySupplementaryItems = [titleHeader]
                section.orthogonalScrollingBehavior = .none

                return section
            } else { // Section 4 - Build Your Bond (Peek Carousel)
                // 1. Item takes up full width of the group
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .fractionalHeight(1.0)
                )
                let item = NSCollectionLayoutItem(layoutSize: itemSize)

                // 2. Group width is less than 1.0 (e.g., 0.8) to allow "peeking"
                // Adjust fractionalWidth here: 0.8 means 80% of screen width
                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(0.59),
                    heightDimension: .absolute(290)
                )
                let group = NSCollectionLayoutGroup.horizontal(
                    layoutSize: groupSize,
                    subitems: [item]
                )

                let section = NSCollectionLayoutSection(group: group)
                
                // 3. Carousel behavior: snaps to the center of the group
                section.orthogonalScrollingBehavior = .groupPagingCentered
                
                // 4. Spacing between cards
                section.interGroupSpacing = 0
                
                // 5. Section Insets
                section.contentInsets = NSDirectionalEdgeInsets(
                    top: 16,
                    leading: 16, // Centered paging handles side insets automatically
                    bottom: 0,
                    trailing: 0
                )
                // Add this inside the Section 4 else block
                section.visibleItemsInvalidationHandler = { (items, offset, env) in
                    let containerWidth = env.container.contentSize.width
                    let scrollOffset = offset.x
                    let viewportCenter = scrollOffset + (containerWidth / 2.0)

                    items.forEach { item in
                        // 1. Determine the 'True' target center (Your existing logic)
                        var targetCenterX = viewportCenter
                        
                        if item.indexPath.item == 0 {
                            let firstCardRestCenter = item.center.x
                            let transitionFactor = min(max(scrollOffset / 100, 0), 1)
                            targetCenterX = firstCardRestCenter + (transitionFactor * (viewportCenter - firstCardRestCenter))
                        }

                        // 2. Calculate distance and normalization
                        let distanceFromCenter = abs(item.center.x - targetCenterX)
                        let range = containerWidth * 0.35
                        let normalizedDistance = min(distanceFromCenter / range, 1.0)
                        
                        item.alpha = 1.0
                        
                        if let cell = self.vibeCollectionView.cellForItem(at: item.indexPath) as? BuildYourBondCollectionViewCell {
                            // --- Keep your Alpha Logic ---
                            let minAlpha: CGFloat = 0.4
                            cell.contentView.alpha = 1.0 - (normalizedDistance * (1.0 - minAlpha))
                            
                            // --- ADD: Size Logic ---
                            // 1.0 at center, 0.85 (15% smaller) at the edges
                            let minScale: CGFloat = 0.85
                            let scale = 1.0 - (normalizedDistance * (1.0 - minScale))
                            
                            // Apply the shrinking transform
                            cell.contentView.transform = CGAffineTransform(scaleX: scale, y: scale)
                        }
                    }
                }
                section.boundarySupplementaryItems = [largeTitleHeader]
                
                return section
            }
        }
        
        return layout
    }
    
    func didTapGetExercise() {
            performSegue(withIdentifier: "openQuestions", sender: self)
    }
    func didStartActivity() {

        DispatchQueue.main.async {
            self.vibeCollectionView.reloadData()
        }
    }
    
    func fetchPartnerMood() async {
        guard let currentUserId = supabase.auth.currentUser?.id else { return }

        do {
            
            let relationships: [DBRelationship] = try await supabase
                .from("relationships")
                .select()
                .or("user1_id.eq.\(currentUserId),user2_id.eq.\(currentUserId)")
                .limit(1)
                .execute()
                .value

            guard let relationship = relationships.first else {
                return
            }

            // Use DBMoodLogWithMood (the struct you defined earlier)
            let moods: [DBMoodLogWithMood] = try await supabase
                .from("user_mood_logs")
                .select("*, moods(*)")
                .eq("relationship_id", value: relationship.relationship_id)
                .neq("user_id", value: currentUserId)
                .order("created_at", ascending: false)
                .limit(1)
                .execute()
                .value

            if let moodLog = moods.first {
                await MainActor.run {
                
                    self.updateMoodUI(with: moodLog)
                }
            }

        } catch {
        }
    }
    func fetchMyMood() async {
        guard let currentUserId = supabase.auth.currentUser?.id,
                  let relationshipId = DataStore.shared.currentRelationshipId else { return }

        do {
            let moods: [DBMoodLogWithMood] = try await supabase
                   .from("user_mood_logs")
                   .select("*, moods(*)")
                   .eq("relationship_id", value: relationshipId.uuidString)
                   .eq("user_id", value: currentUserId.uuidString)
                   .order("created_at", ascending: false)
                   .limit(1)
                   .execute()
                   .value

            if let moodLog = moods.first {
                await MainActor.run {
                    self.myMoodTitle = moodLog.moods.title
                    self.myMoodImage = moodLog.moods.image
                    self.vibeCollectionView.reloadSections(IndexSet(integer: 1))
                }
            }
        } catch {
        }
    }
    //  Realtime listener
    func listenForPartnerMoodUpdates() async {
        guard let currentUserId = supabase.auth.currentUser?.id else { return }

        do {
            let relationships: [DBRelationship] = try await supabase
                .from("relationships")
                .select()
                .or("user1_id.eq.\(currentUserId),user2_id.eq.\(currentUserId)")
                .limit(1)
                .execute()
                .value

            guard let relationship = relationships.first else { return }

            let channel = supabase.channel("mood-updates")

            let moodChanges = channel.postgresChange(
                AnyAction.self,
                schema: "public",
                table: "user_mood_logs",
                filter: "relationship_id=eq.\(relationship.relationship_id)"
            )

            try await channel.subscribe()
            self.moodChannel = channel

            Task {
                for await change in moodChanges {
                    
                    switch change {
                    case .insert(let action):
                        let newRecord = action.record
                       
                        if let changedUserId = newRecord["user_id"]?.value as? String,
                           changedUserId != currentUserId.uuidString {
                            await self.fetchPartnerMood()
                        }
                    default:
                        break
                    }
                }
            }

        } catch {
        }
    }

    private func updateMoodUI(with log: DBMoodLogWithMood) {
        self.partnerMoodTitle = log.moods.title
        self.partnerMoodImage = log.moods.image
        
        self.vibeCollectionView.reloadData()
    }
    
    @IBAction func profileTapped(_ sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "HomePageProfileNew", bundle: nil)
           let profileVC = storyboard.instantiateInitialViewController()!
           let navVC = UINavigationController(rootViewController: profileVC)
           navVC.modalPresentationStyle = .pageSheet
           navVC.presentationController?.delegate = self
           present(navVC, animated: true)
    }
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        Task { [weak self] in
            guard let self else { return }
            await DataStore.shared.refreshUserProfileFromSupabase()
            await MainActor.run {
                self.makeSmileData = [
                    MakeSmile(types: "Send Lovenote", imageName: "pencil.and.list.clipboard"),
                    MakeSmile(types: "Love Tips", imageName: "lightbulb.max"),
                    MakeSmile(types: "Activities for \(self.partnerDisplayText)", imageName: "checklist")
                ]
                self.vibeCollectionView.reloadData()
            }
        }
    }

}


extension VibeViewController:  UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 0
        }
        else if section == 1 {
            return hasCheckedInToday ? 2 : 1
        } else if section == 2{
            if hasCompletedDailyCheckIn {
                        return suggestedActivities.count < 6 ? (suggestedActivities.count + 1) : suggestedActivities.count
                    } else {
                        return 1
                    }
        } else if section == 3 {
            return makeSmileData.count
        } else {
            return BuildBond.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.section == 1 {
            if hasCheckedInToday {
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "mood_checkin_cell",
                    for: indexPath
                ) as! MoodCheckInCollectionViewCell

                let mood: MoodCheckIn

                if indexPath.item == 0 {
                    mood = MoodCheckIn(
                        label: "Me",
                        imageName: myMoodImage,
                        moodLabel: myMoodTitle
                    )
                    
                } else {
                    mood = MoodCheckIn(
                        label: partnerDisplayText,
                        imageName: partnerMoodImage,
                        moodLabel: partnerMoodTitle
                    )
                }

                cell.configureCells(mood: mood)
                cell.delegate = self
                return cell
            } else {
                // how are you feeling card
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "mood_cell",
                    for: indexPath
                ) as! MoodCardCollectionViewCell

                cell.configureCell()
                return cell
            }
        }
        
        else if indexPath.section == 2 {
            if hasCompletedDailyCheckIn {
                       // Check if we should show the Refresh Cell (it's the last item and we have < 6 activities)
                       if indexPath.row == suggestedActivities.count && suggestedActivities.count < 6 {
                           let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "refresh_cell", for: indexPath) as! RefreshActivityCollectionViewCell
                           // This closure handles the tap on the BUTTON specifically
                           cell.onRefreshTapped = { [weak self] in
                               guard let self = self else { return }
                               // Call the same selection logic manually if the button is pressed
                               self.collectionView(self.vibeCollectionView, didSelectItemAt: indexPath)    }
                           return cell
                       } else {
                           // Show the standard Activity Cell
                           let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "suggestedActivity_cell", for: indexPath) as! SuggestedActivityCollectionViewCell
                           cell.configureCells(activity: suggestedActivities[indexPath.row])
                           return cell
                       }
            } else {
                       // Daily Check-In card (Locked state)
                       let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "daily_CheckIn", for: indexPath) as! DailyCheckInCollectionViewCell
                       cell.configureCells()
                       cell.delegate = self
                       return cell
            }
        }
        
        else if indexPath.section == 3 {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "makeSmile_cell",
                for: indexPath
            ) as! MakeHerSmileCollectionViewCell
            
            let item = makeSmileData[indexPath.row]
            cell.configureCell(item: item)
            return cell
        }
        
        else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "bond_cell", for: indexPath) as! BuildYourBondCollectionViewCell
            cell.configureCell(bond: BuildBond[indexPath.row])
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let title = collectionView.dequeueReusableSupplementaryView(ofKind: "title", withReuseIdentifier: "title_cell", for: indexPath) as! TitleCollectionResuableView
        if indexPath.section == 2 {
            title.configureTitle(title: "Suggested Activity", subtitle: "")
        } else if indexPath.section == 3 {
            title.configureTitle(title: "Make \(partnerDisplayText) Smile", subtitle: "")
        } else if indexPath.section == 4 {
            title.configureTitle(title: "Build Your Bond", subtitle: "Focus on one theme, grow as a couple.")
        }
        return title
    }
    
    func didTapMood(in cell: MoodCheckInCollectionViewCell) {

        guard cell.label.text == "Me",
              let indexPath = vibeCollectionView.indexPath(for: cell) else { return }

//        if !MoodManager.shared.canChangeMood() {
//            showAlert()
//            return
//        }

        let storyboard = UIStoryboard(name: "tell_Mood", bundle: nil)
        let vc = storyboard.instantiateViewController(
            withIdentifier: "TellMoodSelectionViewController"
        ) as! TellMoodSelectionViewController

        vc.delegate = self
        vc.selectedIndexPath = indexPath
        vc.modalPresentationStyle = .pageSheet

        present(vc, animated: true)
    }

    func didSelectMood(_ mood: MoodCheckIn, at indexPath: IndexPath) {

        guard let currentUserId = supabase.auth.currentUser?.id else {
            return
        }

        self.myMoodTitle = mood.moodLabel
        self.myMoodImage = mood.imageName

        self.vibeCollectionView.reloadSections(IndexSet(integer: 1))

        Task {
            do {
                // Get relationship
                let relationships: [DBRelationship] = try await supabase
                    .from("relationships")
                    .select()
                    .or("user1_id.eq.\(currentUserId),user2_id.eq.\(currentUserId)")
                    .limit(1)
                    .execute()
                    .value

                guard let relationship = relationships.first else {
                    return
                }

                // Get mood_id
                let moods: [DBMood] = try await supabase
                    .from("moods")
                    .select()
                    .eq("title", value: mood.moodLabel)
                    .limit(1)
                    .execute()
                    .value

                guard let selectedMood = moods.first else {
                    return
                }

                // Insert
                try await supabase
                    .from("user_mood_logs")
                    .insert([
                        "relationship_id": relationship.relationship_id,
                        "user_id": currentUserId,
                        "mood_id": selectedMood.mood_id
                    ])
                    .execute()


            } catch {
            }
        }
    }
    
//    func showAlert() {
//
//        let message = MoodManager.shared.remainingTimeText()
//
//        let alert = UIAlertController(
//            title: "Mood Locked",
//            message: message,
//            preferredStyle: .alert
//        )
//
//        alert.addAction(UIAlertAction(title: "OK", style: .default))
//        present(alert, animated: true)
//    }
}

extension VibeViewController {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // section 1 - How are you feeling today?
        if indexPath.section == 1 && !hasCheckedInToday {

            let storyboard = UIStoryboard(name: "tell_Mood", bundle: nil)
            let vc = storyboard.instantiateViewController(
                withIdentifier: "TellMoodSelectionViewController"
            ) as! TellMoodSelectionViewController

            vc.delegate = self
            
            vc.selectedIndexPath = IndexPath(item: 0, section: 1)
            
            vc.modalPresentationStyle = .pageSheet

            if let sheet = vc.sheetPresentationController {
                sheet.detents = [
                    .custom { _ in
                        return 800
                    }
                ]
                sheet.prefersGrabberVisible = true
                sheet.preferredCornerRadius = 28
                sheet.largestUndimmedDetentIdentifier = nil
            }

            present(vc, animated: true)
            return
        }
        //section 2
                if indexPath.section == 2 {
                    // If daily check-in isn't done, we don't want to open activities yet
                                guard hasCompletedDailyCheckIn else { return }
                                
                    
                                // 1. Check if the Refresh Cell was tapped
                                if indexPath.row == suggestedActivities.count {
                                    // completely replace current 3 activities with 3 new ones
                                    let newActivities = DataStore.shared.getRefreshSuggestedActivities()
                                    guard !newActivities.isEmpty else { return }

                                    self.suggestedActivities = newActivities
                                    
                                    UIView.transition(with: collectionView, duration: 0.3, options: .transitionCrossDissolve, animations: {
            collectionView.reloadSections(IndexSet(integer: 2))
        }, completion: nil)
            return
        }
            // 2. Handle Activity Selection (This is the part that was missing!)
            else {
                let selectedActivity = suggestedActivities[indexPath.row]

                let destinationVC = SmallModalViewController( nibName: "SmallModalViewController", bundle: nil )
                destinationVC.selectedActivity = selectedActivity
                // Link the modal data (steps/description) from DataStore
                destinationVC.modalData = DataStore.shared.getSmallModalData(for: selectedActivity)
                destinationVC.flowSource = .activitiesForHer // This ensures the modal knows which flow to use
                destinationVC.modalPresentationStyle = .overFullScreen
                destinationVC.delegate = self
                present(destinationVC, animated: false)
                return
            }
        }

        // Section 3- Make Her Smile
        if indexPath.section == 3 {
            switch indexPath.row {
            case 0:
                performSegue(withIdentifier: "LoveNotePage", sender: nil)
            case 1:
                let vc: UIViewController

                if selectedTips.isEmpty {
                    let storyboard = UIStoryboard(name: "LoveTips", bundle: nil)
                    let loveTipsVC = storyboard.instantiateViewController(
                        withIdentifier: "LoveTipsVC"
                    ) as! LoveTipsViewController

                    loveTipsVC.selectedTips = self.selectedTips
                    loveTipsVC.delegate = self
                    vc = loveTipsVC

                } else {
                    let selectedVC = UIStoryboard(
                        name: "LoveTipsSelected",
                        bundle: nil
                    ).instantiateViewController(
                        withIdentifier: "LoveTipsSelectedViewController"
                    ) as! LoveTipsSelectedViewController

                    selectedVC.selectedTips = self.selectedTips
                    selectedVC.delegate = self
                    vc = selectedVC
                }
                
                if let sheet = vc.sheetPresentationController {
                    sheet.detents = [.medium(), .large()]
                    sheet.prefersGrabberVisible = true
                    sheet.selectedDetentIdentifier = .medium
                }
                present(vc, animated: true)

                
            case 2:
                performSegue(withIdentifier: "ActivityForHerShow", sender: self)
            default: break
            }
            return
        }
        
        // section 4 - bub
        if indexPath.section == 4 {
            selectedbondOption = BuildBond[indexPath.row]
            performSegue(withIdentifier: "BUBSheet", sender: nil)
            return
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "BUBSheet" {
            if let dest = segue.destination as? BuildYourBondViewController {
                dest.selectedbondOption = selectedbondOption
            }
        }
        if segue.identifier == "openQuestions" {
                if let vc = segue.destination as? Questions_OptionsViewController {

                    vc.flowDelegate = self
                }
            }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Prevent duplicate channel creation
        if moodChannel != nil { return }

        Task {
            await listenForPartnerMoodUpdates()
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkNotifications()

        Task { [weak self] in
            guard let self else { return }

            await DataStore.shared.refreshUserProfileFromSupabase()

            await MainActor.run {
                self.makeSmileData = [
                    MakeSmile(types: "Send Lovenote", imageName: "pencil.and.list.clipboard"),
                    MakeSmile(types: "Love Tips", imageName: "lightbulb.max"),
                    MakeSmile(types: "Activities for \(self.partnerDisplayText)", imageName: "checklist")
                ]
                
                if self.hasCompletedDailyCheckIn && self.suggestedActivities.isEmpty {
                    self.suggestedActivities = DataStore.shared.getSuggestedActivities()
                }
                
                self.configureOngoingActivity()
                self.vibeCollectionView.reloadData()
            }
            await self.fetchMyMood()
            await self.fetchPartnerMood()
            
        }
    }

    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        Task {
            await moodChannel?.unsubscribe()
            moodChannel = nil
        }
    }

    func reloadData() {
        vibeCollectionView.reloadData()
        
    }
}

extension VibeViewController: LoveTipsSelectionDelegate {
    func didUpdateSelectedTips(_ tips: [Tip]) {
        self.selectedTips = tips
        self.vibeCollectionView.reloadData()
    }
}
extension VibeViewController: DailyExerciseFlowDelegate {
    func dailyExerciseDidFinish() {
        self.hasCompletedDailyCheckIn = true
        self.suggestedActivities = DataStore.shared.getSuggestedActivities() // IMPORTANT
        DispatchQueue.main.async {
            self.vibeCollectionView.reloadSections(IndexSet(integer: 2))
        }
    }
}

extension VibeViewController {
    
    @IBAction func continueActivityTapped(_ sender: UIButton) {
            // 1. Ensure there is an active activity to continue
            guard !ongoingActivites.isEmpty else { return }
            
            let activity = ongoingActivites[0]
            
            // 2. Load the Steps storyboard
            let storyboard = UIStoryboard(name: "Steps", bundle: nil)
            
            // 3. Instantiate and configure the StepsViewController
            if let stepsVC = storyboard.instantiateViewController(withIdentifier: "StepsViewController") as? StepsViewController {
                stepsVC.activitytitle = activity.name
                stepsVC.activity = activity
                
                // Setting flowSource to .vibe (assuming you have this case) or .explore
                // to ensure the back button/completion logic knows where it came from
                stepsVC.flowSource = .explore
                
                stepsVC.modalPresentationStyle = .fullScreen
                
                // 4. Present the steps
                self.present(stepsVC, animated: true, completion: nil)
            }
        }
    /// Logic for the cross button to remove an activity and update the UI stack
    @IBAction func cancelActivityTapped(_ sender: UIButton) {
        // Ensure there is an activity to cancel
        guard !ongoingActivites.isEmpty else { return }
        
        // 1. Identify the current active activity
        let activityToCancel = ongoingActivites[0]
        
        // 2. Update the status in your DataStore to .none
        // This ensures it won't show up in the ongoing list anymore
        DataStore.shared.markActivityNone(activity: activityToCancel)
        
        // 3. Animate the primary view disappearing
        // This creates a "sliding" or "fading" effect to reveal what's behind
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.ongoingActivitiesView.alpha = 0
            self.ongoingActivitiesView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { _ in
            // 4. Reset the view properties for the next time it's used
            self.ongoingActivitiesView.alpha = 1
            self.ongoingActivitiesView.transform = .identity
            
            // 5. Refresh the data and UI to shift the second activity to the front
            self.configureOngoingActivity()
            
            // Optional: Reload collection view if the activity affects other sections
            // self.vibeCollectionView.reloadData()
        }
    }
    
    /// Call this inside your configureOngoingActivity() to manage the two-view stack
    func updateActivityStackVisibility() {
        let activities = DataStore.shared.getOngoingActivities()
        
        if activities.count > 1 {
            // Two or more activities: show both views for the "stacked" effect
            ongoingActivitiesView.isHidden = false
            secondOngoingActivityView.isHidden = false
            showAllActivityButton.isHidden = false
        } else if activities.count == 1 {
            // One activity: hide the background view and "show all" button
            ongoingActivitiesView.isHidden = false
            secondOngoingActivityView.isHidden = true
            showAllActivityButton.isHidden = true
        } else {
            // No activities: hide the entire container
            ongoingActivitiesView.isHidden = true
            secondOngoingActivityView.isHidden = true
            showAllActivityButton.isHidden = true
        }
    }
    @IBAction func showAllOngoingTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Vibe", bundle: nil) // Update with your actual storyboard name
        guard let modalVC = storyboard.instantiateViewController(withIdentifier: "OngoingActivitiesModalViewController") as? OngoingActivitiesModalViewController else { return }
        
        modalVC.modalPresentationStyle = .pageSheet
        
        if let sheet = modalVC.sheetPresentationController {
            // We force the layout immediately to get the activity count
            let activitiesCount = DataStore.shared.getOngoingActivities().prefix(3).count
            let calculatedHeight = CGFloat(activitiesCount * 115) + CGFloat((activitiesCount - 1) * 12) + 100
            
            sheet.detents = [
                .custom { _ in
                    return min(calculatedHeight, 600) // Caps the height so it doesn't take the whole screen
                }
            ]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 28
        }
        
        present(modalVC, animated: true)
    }
}
