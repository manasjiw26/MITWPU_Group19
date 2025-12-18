//
//  MoodViewController.swift
//  Project Love 2.0
//
//  Created by SDC-USER on 08/12/25.
//

import UIKit
private let ongoingActivityCountKey = "ongoingActivityCount"

class MoodViewController: UIViewController, SmallModalDelegate {

    @IBOutlet weak var MoodCheckIn: UICollectionView!
    
    private var isFirstLoad = true
    var moods: [MoodCheckIn] = dataStore.getMood()
    var activitystats: [ActivityStats] = []
    
    var hasCompletedDailyCheckIn = false
    var suggestedActivities: [Activity] = []
    private let completedActivityCountKey = "completedActivityCount"

    override func viewDidLoad() {
        super.viewDidLoad()

        activitystats = [
            ActivityStats(types: "Ongoing", imageName: "clock.arrow.circlepath", count: 0),
            ActivityStats(types: "Scheduled", imageName: "calendar", count: 0),
            ActivityStats(types: "Completed", imageName: "checkmark.circle", count: 0)
        ]

        MoodCheckIn.collectionViewLayout = generateLayout()
        MoodCheckIn.delegate = self
        MoodCheckIn.dataSource = self
        suggestedActivities = dataStore.getSuggestedActivities()

        registerCells()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // ✅ Ongoing count
        let ongoing = UserDefaults.standard.integer(
            forKey: ongoingActivityCountKey
        )
        activitystats[0].count = ongoing

        // ✅ Completed count
        let completed = UserDefaults.standard.integer(
            forKey: completedActivityCountKey
        )
        activitystats[2].count = completed

        // ✅ Update moods
        moods = DataStore.shared.moods

        // ✅ Reload Activity Stats section
        MoodCheckIn.reloadSections(IndexSet(integer: 2))

        // ✅ Reload mood cards
        MoodCheckIn.reloadData()
    }

    private func openOngoingScreen() {

        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        let vc = storyboard.instantiateViewController(
            withIdentifier: "ActivityForHerVC"
        ) as! ActivitiesForHerViewController

        vc.activitiesForHer = DataStore.shared.ongoingActivities   // ✅ KEY LINE
        vc.screenTitle = "Ongoing"

        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
   
//       private func openTellMoodSelection(indexPath: IndexPath? = nil) {
//           let storyboard = UIStoryboard(name: "tell_Mood", bundle: nil)
//           let vc = storyboard.instantiateViewController(
//               withIdentifier: "TellMoodSelectionViewController"
//           ) as! TellMoodSelectionViewController
//
//           vc.selectedIndexPath = indexPath
//           vc.delegate = self
//           vc.modalPresentationStyle = .fullScreen
//           present(vc, animated: true)
//       }

    func registerCells() {
        MoodCheckIn.register(
            UINib(nibName: "MoodCheckInCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "mood_cell"
        )

        MoodCheckIn.register(
            UINib(nibName: "DailyCheckInCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "daily_CheckIn"
        )

//        MoodCheckIn.register(
//            UINib(nibName: "OngoingCollectionViewCell", bundle: nil),
//            forCellWithReuseIdentifier: "noongoing_cell"
//        )

        MoodCheckIn.register(
            UINib(nibName: "ActivityStatsCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "activitystats_cell"
        )

        MoodCheckIn.register(
            UINib(nibName: "TitleCollectionResuableView", bundle: nil),
            forSupplementaryViewOfKind: "title",
            withReuseIdentifier: "title_cell"
        )
        MoodCheckIn.register(
            UINib(nibName: "SuggestedActivityCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "suggestedActivity_cell"
        )
    }

    func generateLayout() -> UICollectionViewCompositionalLayout {

        UICollectionViewCompositionalLayout { section, _ in

            let titleSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(40)
            )

            let titleItem = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: titleSize,
                elementKind: "title",
                alignment: .top
            )

            // SECTION 0 – Mood cards
            if section == 0 {

                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .estimated(180)
                )
                let item = NSCollectionLayoutItem(layoutSize: itemSize)

                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .estimated(220)
                )
                let group = NSCollectionLayoutGroup.horizontal(
                    layoutSize: groupSize,
                    subitem: item,
                    count: 2
                )
                group.interItemSpacing = .fixed(8)

                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(
                    top: 30, leading: 16, bottom: 20, trailing: 16
                )
                section.interGroupSpacing = 8

                return section
            }

            // SECTION 1 – Daily Check-In
//            if section == 1 {
//
//                let itemSize = NSCollectionLayoutSize(
//                    widthDimension: .fractionalWidth(1.0),
//                    heightDimension: .estimated(180)
//                )
//                let item = NSCollectionLayoutItem(layoutSize: itemSize)
//
//                let group = NSCollectionLayoutGroup.vertical(
//                    layoutSize: itemSize,
//                    subitems: [item]
//                )
//
//                let section = NSCollectionLayoutSection(group: group)
//                section.contentInsets = NSDirectionalEdgeInsets(
//                    top: 25, leading: 16, bottom: 12, trailing: 16
//                )
//
//                return section
//            }
            // SECTION 1 – Daily Check-In / Suggested Activities
            if section == 1 {

                // ✅ DAILY CHECK-IN (single full-width card)
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
                        top: 25, leading: 16, bottom: 12, trailing: 16
                    )

                    return section
                }

                // SUGGESTED ACTIVITIES (horizontal + peek)
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .absolute(350),   // card width
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
                    top: 10,
                    leading: 16,
                    bottom: 20,
                    trailing: 10
                )
                section.boundarySupplementaryItems = [titleItem]
                return section
            }
            // SECTION 2 – Ongoing Activity
//            if section == 2 {
//
//                let itemSize = NSCollectionLayoutSize(
//                    widthDimension: .fractionalWidth(1.0),
//                    heightDimension: .estimated(180)
//                )
//                let item = NSCollectionLayoutItem(layoutSize: itemSize)
//
//                let group = NSCollectionLayoutGroup.vertical(
//                    layoutSize: itemSize,
//                    subitems: [item]
//                )
//
//                let section = NSCollectionLayoutSection(group: group)
//                section.contentInsets = NSDirectionalEdgeInsets(
//                    top: 10, leading: 16, bottom: 20, trailing: 16
//                )
//                section.boundarySupplementaryItems = [titleItem]
//
//                return section
//            }

            // SECTION 3 – Activity Stats
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .absolute(110),
                heightDimension: .absolute(130)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let groupSize = NSCollectionLayoutSize(
                widthDimension: .estimated(110),
                heightDimension: .absolute(130)
            )
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: groupSize,
                subitems: [item]
            )
            group.interItemSpacing = .fixed(15)

            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .continuous
            section.interGroupSpacing = 19
            section.contentInsets = NSDirectionalEdgeInsets(
                top: 10, leading: 16, bottom: 25, trailing: 16
            )
            section.boundarySupplementaryItems = [titleItem]

            return section
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {

        // Suggested Activities
        if indexPath.section == 1, hasCompletedDailyCheckIn {

            let selectedActivity = suggestedActivities[indexPath.row]

            let destinationVC = SmallModalViewController(
                nibName: "SmallModalViewController",
                bundle: nil
            )

            if let modalData = dataStore.smallmodal.first(
                where: { $0.title == selectedActivity.name }
            ) {
                destinationVC.selectedActivity = modalData
            }

            destinationVC.flowSource = .activitiesForHer
            destinationVC.modalPresentationStyle = .overFullScreen
            destinationVC.delegate = self
            present(destinationVC, animated: false)
            return
        }

        // ✅ ONGOING CARD TAP
        if indexPath.section == 2, indexPath.row == 0 {
            openOngoingScreen()
        }
    }
        func didStartActivity() {
               // Increase ongoing count
               activitystats[0].count += 1

               UserDefaults.standard.set(
                   activitystats[0].count,
                   forKey: ongoingActivityCountKey
               )

               // Reload Activity Stats section
               MoodCheckIn.reloadSections(IndexSet(integer: 2))
           }

}


extension MoodViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {

        switch section {
        case 0: return moods.count
        case 1:
            return hasCompletedDailyCheckIn ? suggestedActivities.count : 1

        default: return activitystats.count
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        switch indexPath.section {

        case 0:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "mood_cell",
                for: indexPath
            ) as! MoodCheckInCollectionViewCell

            cell.configureCells(mood: moods[indexPath.row])
            cell.delegate = self
            return cell

        case 1:

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


//        case 2:
//            let cell = collectionView.dequeueReusableCell(
//                withReuseIdentifier: "noongoing_cell",
//                for: indexPath
//            ) as! OngoingCollectionViewCell
//            cell.configureCells()
//            return cell

        default:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "activitystats_cell",
                for: indexPath
            ) as! ActivityStatsCollectionViewCell

            cell.configureCell(item: activitystats[indexPath.row])
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {

        let title = collectionView.dequeueReusableSupplementaryView(
            ofKind: "title",
            withReuseIdentifier: "title_cell",
            for: indexPath
        ) as! TitleCollectionResuableView

        if indexPath.section == 1 {
            title.configureTitle(title: "Suggested Activity", subtitle: "")
        }
        else if indexPath.section == 2 {
            title.configureTitle(title: "Activity Stats", subtitle: "")
        }
//        else if indexPath.section == 3 {
//            title.configureTitle(title: "Activity Stats", subtitle: "")
//        }

        return title
    }
}

extension MoodViewController: MoodCheckInCellDelegate {

    func didTapMood(in cell: MoodCheckInCollectionViewCell) {
        guard cell.label.text == "Me",
              let indexPath = MoodCheckIn.indexPath(for: cell) else { return }

        let storyboard = UIStoryboard(name: "tell_Mood", bundle: nil)
        let vc = storyboard.instantiateViewController(
            withIdentifier: "TellMoodSelectionViewController"
        ) as! TellMoodSelectionViewController
        vc.selectedIndexPath = indexPath
        vc.delegate = self
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
}

extension MoodViewController: TellMoodSelectionDelegate {

    func didSelectMood(_ mood: MoodCheckIn, at indexPath: IndexPath) {
        moods[indexPath.row].imageName = mood.imageName
        moods[indexPath.row].moodLabel = mood.moodLabel
        moods = DataStore.shared.moods
        MoodCheckIn.reloadItems(at: [indexPath])
    }
}
extension MoodViewController: DailyCheckInCellDelegate {

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

}
extension MoodViewController: DailyCheckInCompletionDelegate {

    func didCompleteDailyCheckIn() {
        hasCompletedDailyCheckIn = true

        MoodCheckIn.reloadSections(IndexSet(integer: 1))
    }
}

