//
//  VibeViewController.swift
//  Project Love 2.0
//
//  Created by SDC-USER on 25/11/25.
//

import UIKit

class VibeViewController: UIViewController,UICollectionViewDelegate,MoodCheckInCellDelegate, TellMoodSelectionDelegate, DailyCheckInCellDelegate, SmallModalDelegate {
    
    @IBOutlet weak var vibeCollectionView: UICollectionView!
    var days : [DayInfo] = []
    var makeSmileData: [MakeSmile] = []
    var didScrollToMiddle = false
    var BuildBond : [BuildYourBond] = []
    var selectedbondOption: BuildYourBond?
    var hasCompletedDailyCheckIn = false
    var suggestedActivities: [Activity] = []
    //var hasCheckedInToday = false

    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeSmileData = [
            MakeSmile(types: "Send Lovenote", imageName: "pencil.and.list.clipboard"),
            MakeSmile(types: "Love Tips", imageName: "lightbulb.max"),
            MakeSmile(types: "Activities for Her", imageName: "checklist")
        ]
        days = dataStore.getLastAndNext15Days()
        BuildBond = dataStore.loadBuildYourbond()
        suggestedActivities = DataStore.shared.getSuggestedActivities()
        registerCell()
        vibeCollectionView.setCollectionViewLayout(generateLayout(), animated: true)
        vibeCollectionView.dataSource = self
        vibeCollectionView.delegate = self
        if !didScrollToMiddle {
            let mid = days.count / 2
            let indexPath = IndexPath(item: mid, section: 0)
            //                vibeCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
            didScrollToMiddle = true
        }
        
        
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
            }  else if section == 2 {
                
                //  DAILY CHECK-IN
                if !self.hasCompletedDailyCheckIn {

                    let itemSize = NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1.0),
                        heightDimension: .estimated(180)
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

                // SUGGESTED ACTIVITIES (horizontal + peek)
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .absolute(350),
                    heightDimension: .estimated(120)
                )
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(
                    top: 0,
                    leading: 4,
                    bottom: 0,
                    trailing: 4
                )

                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .absolute(350),
                    heightDimension: .estimated(140)
                )
                let group = NSCollectionLayoutGroup.horizontal(
                    layoutSize: groupSize,
                    subitems: [item]
                )

                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .continuous
                section.interGroupSpacing = 2

                section.contentInsets = NSDirectionalEdgeInsets(
                    top: 6,
                    leading: 16,
                    bottom: 12,
                    trailing: 16
                )
                section.supplementaryContentInsetsReference = .none

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
                    leading: 16,
                    bottom: 0,
                    trailing: 16
                )

                section.boundarySupplementaryItems = [titleHeader]
                return section
            } else if section == 3 { //make her smile

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
            } else { //build your bond
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .fractionalHeight(1.0)
                )
                let item = NSCollectionLayoutItem(layoutSize: itemSize)

                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .absolute(260),
                    heightDimension: .absolute(290)
                )
                let group = NSCollectionLayoutGroup.horizontal(
                    layoutSize: groupSize,
                    subitems: [item]
                )
 
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
                
                section.interGroupSpacing = 16
                
                section.contentInsets = NSDirectionalEdgeInsets(
                    top: 10,
                    leading: 16,
                    bottom: 12,
                    trailing: 16
                )
                section.boundarySupplementaryItems = [largeTitleHeader]
                
                return section
            }
        }
        
        return layout
    }
    
    func didTapGetExercise() {
        let storyboard = UIStoryboard(name: "onbording", bundle: nil)
        let nav = storyboard.instantiateViewController(
            withIdentifier: "QuestionNavController"
        ) as! UINavigationController

        let vc = nav.viewControllers.first as! QuestionViewController
        vc.completionDelegate = self

        nav.modalPresentationStyle = .pageSheet
        present(nav, animated: true)
    }
    func didStartActivity() {
        print("Activity started")

        // Optional: update UI if needed
        DispatchQueue.main.async {
            self.vibeCollectionView.reloadData()
        }
    }
    
    @IBAction func profileTapped(_ sender: UIBarButtonItem) {
        print("hello button clicked")
        let storyboard = UIStoryboard(name: "HomePageProfileNew", bundle: nil)
        
        let profileVC = storyboard.instantiateInitialViewController()!
        let navVC = UINavigationController(rootViewController: profileVC)
        present(navVC, animated: true)

        present(navVC, animated: true)

    
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
            return hasCompletedDailyCheckIn ? suggestedActivities.count : 1
        } else if section == 3 {
            print("Section 3 files")
            print("\(makeSmileData.count)")
            return makeSmileData.count
        } else {
            return BuildBond.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = vibeCollectionView.dequeueReusableCell(withReuseIdentifier: "calendar_cell", for: indexPath) as! CalendarCollectionViewCell
            let dayInfo = days[indexPath.row]
            if Int(dayInfo.date) == Calendar.current.component(.day, from: Date()) {
                cell.configureTodayCell(day : dayInfo)
            } else {
                cell.configureCell(day : dayInfo)}
            return cell
        }
        else if indexPath.section == 1 {

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
            }
            else {
                // SHOW "HOW ARE YOU FEELING TODAY?"
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "mood_cell",
                    for: indexPath
                ) as! MoodCardCollectionViewCell

                cell.configureCell()
                return cell
            }
        } else if indexPath.section == 2 {
            if hasCompletedDailyCheckIn {
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "suggestedActivity_cell",
                    for: indexPath
                ) as! SuggestedActivityCollectionViewCell

                cell.configureCells(activity: suggestedActivities[indexPath.row])
                return cell

            } else {
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "daily_CheckIn",
                    for: indexPath
                ) as! DailyCheckInCollectionViewCell

                cell.configureCells()
                cell.delegate = self
                return cell
            }
        }
        else if indexPath.section == 3{  
            print("collectionView 3 working")
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "makeSmile_cell",
                for: indexPath
            ) as! MakeHerSmileCollectionViewCell
            
            let item = makeSmileData[indexPath.row]
            cell.configureCell(item: item)

            return cell
        }
        else{
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

        // Layout switches from single card → two cards
        vibeCollectionView.setCollectionViewLayout(
            generateLayout(),
            animated: false
        )

        // Reload entire section safely
        vibeCollectionView.performBatchUpdates {
            vibeCollectionView.reloadSections(IndexSet(integer: 1))
        }
    }
}

extension VibeViewController {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // SECTION 1 - How are you feeling today?
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
        if indexPath.section == 2, hasCompletedDailyCheckIn {

            let selectedActivity = suggestedActivities[indexPath.row]

            let destinationVC = SmallModalViewController(
                nibName: "SmallModalViewController",
                bundle: nil
            )
            
            destinationVC.selectedActivity = selectedActivity

            if let modalData = DataStore.shared.smallmodal.first(
                where: { $0.title == selectedActivity.name }
            ) {
                destinationVC.modalData = modalData
            }

            destinationVC.flowSource = .activitiesForHer
            destinationVC.modalPresentationStyle = .overFullScreen
            destinationVC.delegate = self
            present(destinationVC, animated: false)
            return
        }
      
        // SECTION 3- Make Her Smile
        if indexPath.section == 3 {
            switch indexPath.row {
            case 0:
                performSegue(withIdentifier: "openLoveNote", sender: nil)
            case 1:
                performSegue(withIdentifier: "LoveTipsModal", sender: self)
            case 2:
                performSegue(withIdentifier: "ActivityForHerShow", sender: self)
            default: break
            }
            return
        }

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
        // Re-fetch data
        

        // Reload UI
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
