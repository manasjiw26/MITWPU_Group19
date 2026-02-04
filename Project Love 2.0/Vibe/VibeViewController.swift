//
//  VibeViewController.swift
//  Project Love 2.0
//
//  Created by SDC-USER on 25/11/25.
//

import UIKit

protocol LoveTipsSelectionDelegate: AnyObject {
    func didUpdateSelectedTips(_ tips: [Tip])
}

class VibeViewController: UIViewController,UICollectionViewDelegate,MoodCheckInCellDelegate, TellMoodSelectionDelegate, DailyCheckInCellDelegate, SmallModalDelegate {
    
    @IBOutlet weak var vibeCollectionView: UICollectionView!
    
    var makeSmileData: [MakeSmile] = []
    var didScrollToMiddle = false
    var BuildBond : [BuildYourBond] = []
    var selectedbondOption: BuildYourBond?
    var hasCompletedDailyCheckIn = false
    var suggestedActivities: [Activity] = []
    var selectedTips: [Tip] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeSmileData = [
            MakeSmile(types: "Send Lovenote", imageName: "pencil.and.list.clipboard"),
            MakeSmile(types: "Love Tips", imageName: "lightbulb.max"),
            MakeSmile(types: "Activities for Her", imageName: "checklist")
        ]

        BuildBond = dataStore.loadBuildYourbond()
        suggestedActivities = DataStore.shared.getSuggestedActivities()
        registerCell()
        vibeCollectionView.setCollectionViewLayout(generateLayout(), animated: true)
        vibeCollectionView.dataSource = self
        vibeCollectionView.delegate = self
    }
    
    
    private var hasCheckedInToday: Bool {
        return DataStore.shared.getHisMood() != nil
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

                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .estimated(3000),
                    heightDimension: .estimated(estimatedHeight)
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

                sectionLayout.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
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
        print("Activity started")

        DispatchQueue.main.async {
            self.vibeCollectionView.reloadData()
        }
    }
    
    @IBAction func profileTapped(_ sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "HomePageProfileNew", bundle: nil)
        let profileVC = storyboard.instantiateInitialViewController()!
        let navVC = UINavigationController(rootViewController: profileVC)
        navVC.modalPresentationStyle = .pageSheet
        present(navVC, animated: true)
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
            print("Section 3 files")
            print("\(makeSmileData.count)")
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
                    // ME card
                    let hisMood = dataStore.getHisMood()
                    mood = MoodCheckIn(
                        label: "Me",
                        imageName: hisMood?.imageName ?? "neutral",
                        moodLabel: hisMood?.title ?? "Not set"
                    )
                } else {
                    // HER card
                    let herMood = dataStore.getHerMood()
                    mood = MoodCheckIn(
                        label: "Her",
                        imageName: herMood?.imageName ?? "waiting",
                        moodLabel: herMood?.title ?? "Waiting"
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
                // Only show refresh cell if it's the last item AND we haven't reached 6 yet
                if indexPath.row == suggestedActivities.count && suggestedActivities.count < 6 {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "refresh_cell", for: indexPath) as! RefreshActivityCollectionViewCell
                    
                    cell.onRefreshTapped = { [weak self] in
                        guard let self = self else { return }

                        let startIndex = self.suggestedActivities.count
                        let newActivities = DataStore.shared.getMoreActivities(excluding: self.suggestedActivities)
                        guard !newActivities.isEmpty else { return }

                        self.suggestedActivities.append(contentsOf: newActivities)

                        let newIndexPaths = (0..<newActivities.count).map {
                            IndexPath(item: startIndex + $0, section: 2)
                        }

                        self.vibeCollectionView.performBatchUpdates({
                            self.vibeCollectionView.deleteItems(at: [IndexPath(item: startIndex, section: 2)])
                            self.vibeCollectionView.insertItems(at: newIndexPaths)
                            if self.suggestedActivities.count < 6 {
                                self.vibeCollectionView.insertItems(at: [IndexPath(item: self.suggestedActivities.count, section: 2)])
                            }

                        }, completion: { _ in
                            self.vibeCollectionView.scrollToItem(
                                at: IndexPath(item: startIndex, section: 2),
                                at: .right,
                                animated: true
                            )
                        })
                    }

                    return cell
                } else {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "suggestedActivity_cell", for: indexPath) as! SuggestedActivityCollectionViewCell
                    cell.configureCells(activity: suggestedActivities[indexPath.row])
                    return cell
                }
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "daily_CheckIn", for: indexPath) as! DailyCheckInCollectionViewCell
                cell.configureCells()
                cell.delegate = self
                return cell
            }
        }
        
        else if indexPath.section == 3 {
            print("collectionView 3 working")
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
            title.configureTitle(title: "Make Her Smile", subtitle: "")
        } else if indexPath.section == 4 {
            title.configureTitle(title: "Build Your Bond", subtitle: "Focus on one theme, grow as a couple.")
        }
        return title
    }
    
    func didTapMood(in cell: MoodCheckInCollectionViewCell) {

        guard cell.label.text == "Me",
              let indexPath = vibeCollectionView.indexPath(for: cell) else { return }

        if !MoodManager.shared.canChangeMood() {
            showAlert()
            return
        }

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
        
        MoodManager.shared.registerMoodChange()

        // Layout switches from one card to two cards
        vibeCollectionView.setCollectionViewLayout(
            generateLayout(),
            animated: false
        )

        // Reload entire section
        vibeCollectionView.performBatchUpdates {
            vibeCollectionView.reloadSections(IndexSet(integer: 1))
        }
    }
    
    func showAlert() {

        let message = MoodManager.shared.remainingTimeText()

        let alert = UIAlertController(
            title: "Mood Locked",
            message: message,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
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
        if indexPath.row == suggestedActivities.count {

            let startIndex = suggestedActivities.count
            let newActivities = DataStore.shared.getMoreActivities(excluding: self.suggestedActivities)

            // Update data source FIRST
            self.suggestedActivities.append(contentsOf: newActivities)

            let indexPathsToAdd = (0..<newActivities.count).map {
                IndexPath(row: startIndex + $0, section: 2)
            }

            // Let layout prepare outside animation
            UIView.performWithoutAnimation {
                self.vibeCollectionView.collectionViewLayout.invalidateLayout()
            }

            vibeCollectionView.performBatchUpdates({

                // Remove old refresh cell
                vibeCollectionView.deleteItems(at: [IndexPath(row: startIndex, section: 2)])

                // Insert new activity cells
                vibeCollectionView.insertItems(at: indexPathsToAdd)

                // Add refresh back if still needed
                if self.suggestedActivities.count < 6 {
                    vibeCollectionView.insertItems(at: [IndexPath(row: self.suggestedActivities.count, section: 2)])
                }

            }, completion: nil)

            return
        }

        // Section 3- Make Her Smile
        if indexPath.section == 3 {
            switch indexPath.row {
            case 0:
                performSegue(withIdentifier: "openLoveNote", sender: nil)
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
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        vibeCollectionView.reloadSections(IndexSet(integer: 1))
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("HIS MOOD =", DataStore.shared.getHisMood())

    }

    func reloadData() {
        vibeCollectionView.reloadData()
        
    }
}

extension VibeViewController: DailyCheckInCompletionDelegate {

    func didCompleteDailyCheckIn() {
        hasCompletedDailyCheckIn = true

        vibeCollectionView.setCollectionViewLayout(
            generateLayout(),
            animated: false
        )

        DispatchQueue.main.async {
            self.vibeCollectionView.reloadSections(IndexSet(integer: 2))
        }
    }
}
extension VibeViewController: LoveTipsSelectionDelegate {
    func didUpdateSelectedTips(_ tips: [Tip]) {
        self.selectedTips = tips
        self.vibeCollectionView.reloadData()
    }
}
// Add this at the bottom of VibeViewController.swift
extension VibeViewController: DailyExerciseFlowDelegate {
    func dailyExerciseDidFinish() {
        // This is what happens when the user finishes all questions
        self.hasCompletedDailyCheckIn = true
        
        DispatchQueue.main.async {
            self.vibeCollectionView.reloadData()
        }
    }
}
