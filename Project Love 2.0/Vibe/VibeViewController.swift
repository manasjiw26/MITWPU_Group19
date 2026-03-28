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

class SectionBackgroundDecorationView: UICollectionReusableView {
    static let kind = "section-background"
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        layer.cornerRadius = 32
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    required init?(coder: NSCoder) { fatalError() }
}

class PlainWhiteBackgroundView: UICollectionReusableView {
    static let kind = "plain-white-background"
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
    }
    required init?(coder: NSCoder) { fatalError() }
}

class PurpleSectionBackgroundView: UICollectionReusableView {
    static let kind = "purple-section-background"
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(red: 206/255, green: 213/255, blue: 243/255, alpha: 1.0)
    }
    required init?(coder: NSCoder) { fatalError() }
}

private enum VibeSection {
    static let schedule = 0
    static let quickVibe = 1
    static let mood = 2
    static let makeSmile = 3
    static let buildBond = 4
}

class VibeViewController: UIViewController,UICollectionViewDelegate,MoodCheckInCellDelegate, TellMoodSelectionDelegate, DailyCheckInCellDelegate, SmallModalDelegate, InfoModalDelegate, UIAdaptivePresentationControllerDelegate, SuggestedActivitiesModalDelegate {
    
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
    var resolvedVibeTitle: VibeTitle?
    var hasOpenedSuggestedModal = false
    
    let supabase = SupabaseManager.shared.client
    var partnerMoodTitle: String = "Waiting"
    var partnerMoodImage: String = "waiting"
    var myMoodTitle: String = "Not set"
    var myMoodImage: String = "neutral"
    
    var moodChannel: RealtimeChannelV2?
    var notificationChannel: RealtimeChannelV2?
    var partnerDisplayText: String { DataStore.shared.partnerDisplayText }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Vibe"
        checkNotifications()
        BuildBond = dataStore.loadBuildYourbond()
        suggestedActivities = DataStore.shared.getSuggestedActivities()
        registerCell()
        vibeCollectionView.setCollectionViewLayout(generateLayout(), animated: true)
        vibeCollectionView.dataSource = self
        vibeCollectionView.delegate = self
        setupOngoing()
        configureOngoingActivity()
        setupNavigationBar()

        // Refresh gender-dependent UI when preferences change (e.g. from Profile modal)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleActivitiesSynced),
            name: .activitiesSynced,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handlePreferencesChanged),
            name: .preferencesDidChange,
            object: nil
        )

        // Load user/relationship context from Supabase, then sync activities
        Task {
            await DataStore.shared.loadUserContext()
            
            let partnerWasDeleted = await DataStore.shared.checkPartnerDeletion()
            if partnerWasDeleted {
                // Post global notification — SceneDelegate shows the alert
                NotificationCenter.default.post(name: .partnerAccountDeleted, object: nil)
                return
            }

            // Start real-time listener for partner deletion (fires instantly)
            DataStore.shared.startPartnerDeletionListener()
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

    private func setupNavigationBar() {
        let lavender = UIColor(red: 206/255, green: 213/255, blue: 243/255, alpha: 1.0)
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = lavender
        appearance.shadowColor = .clear
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.black]
        appearance.titleTextAttributes = [.foregroundColor: UIColor.black]
        
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        navigationItem.compactAppearance = appearance
        navigationController?.navigationBar.tintColor = .black
        navigationController?.navigationBar.prefersLargeTitles = true
    }

    private func resetNavigationBarAppearance() {
        navigationItem.standardAppearance = nil
        navigationItem.scrollEdgeAppearance = nil
        navigationItem.compactAppearance = nil
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
        vibeCollectionView.backgroundColor = .white
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
    
    func generateLayout() -> UICollectionViewLayout {
        
        let layout = UICollectionViewCompositionalLayout { section, env in
            let headerToItemsSpacing: CGFloat = 10
            let sectionTopSpacing: CGFloat = 18
            
            let largeTitleSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(56)
            )
            
            let compactTitleSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(34)
            )
            
            let largeTitleHeader = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: largeTitleSize,
                elementKind: "title",
                alignment: .top
            )
            
            _ = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: compactTitleSize,
                elementKind: "title",
                alignment: .top
            )
            
            if section == VibeSection.schedule {
                
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .absolute(52),
                    heightDimension: .absolute(72)
                )
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .estimated(2200),
                    heightDimension: .absolute(72)
                )
                
                let group = NSCollectionLayoutGroup.horizontal(
                    layoutSize: groupSize,
                    subitems: [item]
                )
                group.interItemSpacing = .fixed(20)
                
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .continuous
                section.interGroupSpacing = 10
                section.contentInsets = NSDirectionalEdgeInsets(
                    top: 8, leading: 0, bottom: 8, trailing: 0
                )
                section.decorationItems = [
                    NSCollectionLayoutDecorationItem.background(elementKind: PurpleSectionBackgroundView.kind)
                ]
                
                return section
            }
            
            // Section 1: Quick Vibe Check (Moved from Section 2)
            else if section == VibeSection.quickVibe {
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .estimated(220)
                )
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let group = NSCollectionLayoutGroup.vertical(
                    layoutSize: itemSize,
                    subitems: [item]
                )
                
                let sectionLayout = NSCollectionLayoutSection(group: group)
                sectionLayout.contentInsets = NSDirectionalEdgeInsets(
                    top: 8, leading: 16, bottom: 18, trailing: 16
                )
                sectionLayout.decorationItems = [
                    NSCollectionLayoutDecorationItem.background(elementKind: PurpleSectionBackgroundView.kind)
                ]
                
                return sectionLayout
            }
            
            // Section 2: How are you feeling / Moods (Moved from Section 1)
            else if section == VibeSection.mood {
                
                if !self.hasCheckedInToday {
                    
                    let itemSize = NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(165)
                    )
                    let item = NSCollectionLayoutItem(layoutSize: itemSize)
                    
                    let groupSize = NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1.0),
                        heightDimension: .absolute(165)
                    )
                    
                    let group = NSCollectionLayoutGroup.vertical(
                        layoutSize: groupSize,
                        subitems: [item]
                    )
                    
                    let sectionLayout = NSCollectionLayoutSection(group: group)
                    sectionLayout.contentInsets = NSDirectionalEdgeInsets(
                        top: 14, leading: 16, bottom: 0, trailing: 16
                    )
                    sectionLayout.decorationItems = [
                        NSCollectionLayoutDecorationItem.background(elementKind: SectionBackgroundDecorationView.kind)
                    ]
                    
                    return sectionLayout
                } else {
                    
                    let itemSize = NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(0.5),
                        heightDimension: .estimated(180)
                    )
                    let item = NSCollectionLayoutItem(layoutSize: itemSize)
                    
                    item.contentInsets = NSDirectionalEdgeInsets(
                        top: 0, leading: 4, bottom: 0, trailing: 4
                    )
                    
                    let groupSize = NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1.0),
                        heightDimension: .estimated(220)
                    )
                    
                    let group = NSCollectionLayoutGroup.horizontal(
                        layoutSize: groupSize,
                        subitems: [item, item]
                    )
                    
                    let sectionLayout = NSCollectionLayoutSection(group: group)
                    sectionLayout.contentInsets = NSDirectionalEdgeInsets(
                        top: 14, leading: 16, bottom: 0, trailing: 16
                    )
                    sectionLayout.interGroupSpacing = 8
                    sectionLayout.decorationItems = [
                        NSCollectionLayoutDecorationItem.background(elementKind: SectionBackgroundDecorationView.kind)
                    ]
                    
                    return sectionLayout
                }
            }
            
            else if section == VibeSection.makeSmile {
                
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
                
                let sectionLayout = NSCollectionLayoutSection(group: group)
                
                let containerWidth = env.container.effectiveContentSize.width
                let sideInset = max((containerWidth - groupWidth) / 2, 16)
                
                sectionLayout.contentInsets = NSDirectionalEdgeInsets(
                    top: 16,
                    leading: sideInset,
                    bottom: 30,
                    trailing: sideInset
                )
                
                sectionLayout.supplementaryContentInsetsReference = .none
                
                let titleSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(50)
                )
                
                let titleHeader = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: titleSize,
                    elementKind: "title",
                    alignment: .top
                )
                
                titleHeader.contentInsets = NSDirectionalEdgeInsets(
                    top: 15, leading: 16, bottom: 8, trailing: 16
                )
                
                sectionLayout.boundarySupplementaryItems = [titleHeader]
                sectionLayout.orthogonalScrollingBehavior = .none
                sectionLayout.decorationItems = [
                    NSCollectionLayoutDecorationItem.background(elementKind: PlainWhiteBackgroundView.kind)
                ]
                
                return sectionLayout
            }
            
            else {
                
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .fractionalHeight(1.0)
                )
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(0.64),
                    heightDimension: .absolute(318)
                )
                
                let group = NSCollectionLayoutGroup.horizontal(
                    layoutSize: groupSize,
                    subitems: [item]
                )
                
                let sectionLayout = NSCollectionLayoutSection(group: group)
                sectionLayout.orthogonalScrollingBehavior = .groupPagingCentered
                sectionLayout.interGroupSpacing = 0
                
                sectionLayout.contentInsets = NSDirectionalEdgeInsets(
                    top: 8, leading: 16, bottom: 32, trailing: 16
                )
                
                largeTitleHeader.contentInsets = NSDirectionalEdgeInsets(
                    top: 0, leading: 0, bottom: headerToItemsSpacing, trailing: 0
                )
                
                sectionLayout.visibleItemsInvalidationHandler = { (items, offset, env) in
                    
                    let containerWidth = env.container.contentSize.width
                    let scrollOffset = offset.x
                    let viewportCenter = scrollOffset + (containerWidth / 2.0)
                    
                    items.forEach { item in
                        
                        var targetCenterX = viewportCenter
                        
                        if item.indexPath.item == 0 {
                            let firstCardRestCenter = item.center.x
                            let transitionFactor = min(max(scrollOffset / 100, 0), 1)
                            targetCenterX = firstCardRestCenter + (transitionFactor * (viewportCenter - firstCardRestCenter))
                        }
                        
                        let distanceFromCenter = abs(item.center.x - targetCenterX)
                        let range = containerWidth * 0.35
                        let normalizedDistance = min(distanceFromCenter / range, 1.0)
                        
                        item.alpha = 1.0
                        
                        if let cell = self.vibeCollectionView.cellForItem(at: item.indexPath) as? BuildYourBondCollectionViewCell {
                            
                            let minAlpha: CGFloat = 0.4
                            cell.contentView.alpha = 1.0 - (normalizedDistance * (1.0 - minAlpha))
                            
                            let minScale: CGFloat = 0.85
                            let scale = 1.0 - (normalizedDistance * (1.0 - minScale))
                            
                            cell.contentView.transform = CGAffineTransform(scaleX: scale, y: scale)
                        }
                    }
                }
                
                sectionLayout.boundarySupplementaryItems = [largeTitleHeader]
                sectionLayout.decorationItems = [
                    NSCollectionLayoutDecorationItem.background(elementKind: PlainWhiteBackgroundView.kind)
                ]
                
                return sectionLayout
            }
        }
        
        layout.register(SectionBackgroundDecorationView.self, forDecorationViewOfKind: SectionBackgroundDecorationView.kind)
        layout.register(PlainWhiteBackgroundView.self, forDecorationViewOfKind: PlainWhiteBackgroundView.kind)
        layout.register(PurpleSectionBackgroundView.self, forDecorationViewOfKind: PurpleSectionBackgroundView.kind)
        
        return layout
    }
    
    func didTapGetExercise() {
        // Require mood to be set before daily check-in
        guard hasCheckedInToday else {
            let alert = UIAlertController(
                title: "No mood, no check-in 😉",
                message: "Please update your mood before starting the daily check-in.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Set Mood", style: .default) { [weak self] _ in
                guard let self else { return }
                let storyboard = UIStoryboard(name: "tell_Mood", bundle: nil)
                let vc = storyboard.instantiateViewController(
                    withIdentifier: "TellMoodSelectionViewController"
                ) as! TellMoodSelectionViewController
                vc.delegate = self
                vc.selectedIndexPath = IndexPath(item: 0, section: VibeSection.mood)
                vc.modalPresentationStyle = .pageSheet
                self.present(vc, animated: true)
            })
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(alert, animated: true)
            return
        }
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
                    let newTitle = moodLog.moods.title
                    let newImage = moodLog.moods.image
                    
                    if self.myMoodTitle != newTitle || self.myMoodImage != newImage {
                        self.myMoodTitle = newTitle
                        self.myMoodImage = newImage
                        self.vibeCollectionView.setCollectionViewLayout(self.generateLayout(), animated: false)
                        self.vibeCollectionView.reloadSections(IndexSet(integer: VibeSection.mood))
                    }
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
        let newTitle = log.moods.title
        let newImage = log.moods.image
        
        if self.partnerMoodTitle != newTitle || self.partnerMoodImage != newImage {
            self.partnerMoodTitle = newTitle
            self.partnerMoodImage = newImage
            self.vibeCollectionView.reloadSections(IndexSet(integer: VibeSection.mood))
        }
    }
    
    // Notification Realtime Listener
    func listenForNotifications() async {
        guard let currentUserId = supabase.auth.currentUser?.id else { return }

        let channel = supabase.channel("vibe-notifications")

        let notificationChanges = channel.postgresChange(
            AnyAction.self,
            schema: "public",
            table: "notifications",
            filter: "receiver_user_id=eq.\(currentUserId.uuidString)"
        )

        do {
            try await channel.subscribe()
            self.notificationChannel = channel

            Task {
                for await change in notificationChanges {
                    switch change {
                    case .insert(_), .update(_):
                        await MainActor.run {
                            self.checkNotifications()
                        }
                    default:
                        break
                    }
                }
            }
        } catch {
        }
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
        if section == VibeSection.schedule {
            return 0
        }
        else if section == VibeSection.quickVibe {
            // Quick Vibe / Daily Check-in (Moved from section 2)
            return 1
        } else if section == VibeSection.mood {
            // Mood card (Moved from section 1)
            return hasCheckedInToday ? 2 : 1
        } else if section == VibeSection.makeSmile {
            return makeSmileData.count
        } else {
            return BuildBond.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.section == VibeSection.quickVibe {
            // Daily Check-in Cell (Quick Vibe check)
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "daily_CheckIn", for: indexPath) as! DailyCheckInCollectionViewCell
            if hasCompletedDailyCheckIn, let vibeTitle = resolvedVibeTitle {
                // Completed state: button text depends on activity count & modal state
                cell.configureAsCompleted(
                    vibeTitle: vibeTitle,
                    remainingCount: suggestedActivities.count,
                    hasOpenedModal: hasOpenedSuggestedModal
                )
            } else {
                // Default state: Quick Vibe Check card
                cell.configureCells()
            }
            cell.delegate = self
            return cell
        }
        
        else if indexPath.section == VibeSection.mood {
            // Mood Check-in Cells
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
        
        else if indexPath.section == VibeSection.makeSmile {
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
        if indexPath.section == VibeSection.makeSmile {
            title.configureTitle(title: "Make \(partnerDisplayText) Smile", subtitle: "")
        } else if indexPath.section == VibeSection.buildBond {
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

        // Regenerate layout because section 1 switches between
        // a single "how are you feeling" card and two mood cards
        self.vibeCollectionView.setCollectionViewLayout(self.generateLayout(), animated: false)
        self.vibeCollectionView.reloadData()

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
        
        // section 2 - How are you feeling today?
        if indexPath.section == VibeSection.mood && !hasCheckedInToday {

            let storyboard = UIStoryboard(name: "tell_Mood", bundle: nil)
            let vc = storyboard.instantiateViewController(
                withIdentifier: "TellMoodSelectionViewController"
            ) as! TellMoodSelectionViewController

            vc.delegate = self
            
            vc.selectedIndexPath = IndexPath(item: 0, section: VibeSection.mood)
            
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
        // Section 2 taps are handled by the cell delegate (didTapShowSuggestedActivities)

        // Section 3- Make Her Smile
        if indexPath.section == VibeSection.makeSmile {
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
        if indexPath.section == VibeSection.buildBond {
            selectedbondOption = BuildBond[indexPath.row]
            performSegue(withIdentifier: "BUBSheet", sender: nil)
            return
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is NotificationViewController {
            resetNavigationBarAppearance()
        }

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
        if segue.identifier == "ActivityForHerShow" {
            if let dest = segue.destination as? ActivitiesForHerViewController {
                dest.screenTitle = "Activities for \(partnerDisplayText)"
            }
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if moodChannel == nil {
            Task {
                await listenForPartnerMoodUpdates()
            }
        }
        
        if notificationChannel == nil {
            Task {
                await listenForNotifications()
            }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
        checkNotifications()

        Task { [weak self] in
            guard let self else { return }

            await DataStore.shared.refreshUserProfileFromSupabase()
            
            // Initial sync of activities from Supabase
            DataStore.shared.syncActivitiesFromSupabase()

            // Setup real-time listener for activities (if relationship_id exists)
            if let relationshipId = DataStore.shared.currentRelationshipId {
                SupabaseManager.shared.listenForActivityChanges(relationshipId: relationshipId) { [weak self] in
                    DataStore.shared.syncActivitiesFromSupabase()
                }
            }

            await MainActor.run {
                self.makeSmileData = [
                    MakeSmile(types: "Send Lovenote", imageName: "pencil.and.list.clipboard"),
                    MakeSmile(types: "Love Tips", imageName: "lightbulb.max"),
                    MakeSmile(types: "Activities for \(self.partnerDisplayText)", imageName: "checklist")
                ]
                
                // Always sync suggested activities from DataStore
                let latestSuggestions = DataStore.shared.getSuggestedActivities()
                if self.hasCompletedDailyCheckIn && !latestSuggestions.isEmpty {
                    self.suggestedActivities = latestSuggestions
                }
                
                self.configureOngoingActivity()
                self.vibeCollectionView.setCollectionViewLayout(self.generateLayout(), animated: false)
                self.vibeCollectionView.reloadData()
            }
            await self.fetchMyMood()
            await self.fetchPartnerMood()
        }
    }

    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        resetNavigationBarAppearance()

        Task {
            await moodChannel?.unsubscribe()
            moodChannel = nil
            
            await notificationChannel?.unsubscribe()
            notificationChannel = nil
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
    func dailyExerciseDidFinish(with selection: DailyCheckInSelection) {
        self.hasCompletedDailyCheckIn = true
        self.suggestedActivities = DataStore.shared.getSuggestedActivities()

        // Resolve the matching vibe title from the user's answers
        self.resolvedVibeTitle = DataStore.shared.resolveVibeTitle(
            vibe: selection.vibe,
            need: selection.need,
            closeness: selection.closeness
        )

        DispatchQueue.main.async {
            // Reload section 1 — the card updates in-place with the vibe title
            self.vibeCollectionView.reloadSections(IndexSet(integer: VibeSection.quickVibe))
        }
    }
}

// MARK: - Suggested Activities Modal
extension VibeViewController {
    func didTapShowSuggestedActivities() {
        // Mark that the user has opened the modal at least once
        hasOpenedSuggestedModal = true

        let modalVC = SuggestedActivitiesModalViewController()
        modalVC.suggestedActivities = self.suggestedActivities
        modalVC.delegate = self
        modalVC.modalPresentationStyle = .pageSheet

        if let sheet = modalVC.sheetPresentationController {
            let activityCount = suggestedActivities.count
            let calculatedHeight = CGFloat(activityCount * 140) + 100
            sheet.detents = [
                .custom { _ in
                    return min(calculatedHeight, 600)
                }
            ]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 28
        }

        // Reload the card so button text updates to "Continue"
        vibeCollectionView.reloadSections(IndexSet(integer: VibeSection.quickVibe))

        present(modalVC, animated: true)
    }

    func didSelectSuggestedActivity(_ activity: Activity) {
        // Same logic as the old section 2 tap handler
        if activity.steps == nil || activity.steps?.isEmpty == true {
            let storyboard = UIStoryboard(name: "InfoModal", bundle: nil)
            let infoVC = storyboard.instantiateViewController(withIdentifier: "InfoModalViewController") as! InfoModalViewController
            infoVC.activity = activity
            infoVC.delegate = self
            infoVC.modalPresentationStyle = .overFullScreen
            present(infoVC, animated: false)
        } else {
            let destinationVC = SmallModalViewController(nibName: "SmallModalViewController", bundle: nil)
            destinationVC.selectedActivity = activity
            destinationVC.modalData = DataStore.shared.getSmallModalData(for: activity)
            destinationVC.flowSource = .activitiesForHer
            destinationVC.modalPresentationStyle = .overFullScreen
            destinationVC.delegate = self
            present(destinationVC, animated: false)
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
        let modalVC = OngoingActivitiesModalViewController()
        
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

// MARK: - InfoModalDelegate
extension VibeViewController {
    func didTapLetsDoThis(for activity: Activity) {
        // Mark as ongoing in DataStore & Supabase
        DataStore.shared.startActivity(activity) { [weak self] _ in
            DispatchQueue.main.async {
                self?.configureOngoingActivity()
                self?.vibeCollectionView.reloadData()
            }
        }

        // Remove the activity from suggested activities locally
        if let index = suggestedActivities.firstIndex(where: { $0.name == activity.name && $0.category == activity.category }) {
            suggestedActivities.remove(at: index)
            DataStore.shared.suggestedActivities = suggestedActivities
            vibeCollectionView.reloadSections(IndexSet(integer: VibeSection.quickVibe))
        }
    }

    @objc private func handleActivitiesSynced() {
        DispatchQueue.main.async {
            self.configureOngoingActivity()
            self.vibeCollectionView.reloadData()
        }
    }
}
