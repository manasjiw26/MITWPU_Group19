//
//  MoodViewController.swift
//  Project Love 2.0
//
//  Created by SDC-USER on 08/12/25.
//

import UIKit

class MoodViewController: UIViewController {

    @IBOutlet weak var MoodCheckIn: UICollectionView!
    private var isFirstLoad = true
    var moods: [MoodCheckIn] = dataStore.getMood()
    var activitystats: [ActivityStats] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        activitystats = [
            ActivityStats(types: "Scheduled", imageName: "calendar", count: 0),
            ActivityStats(types: "Completed", imageName: "checkmark.circle", count: 0),
            ActivityStats(types: "Liked", imageName: "heart.circle", count: 0)
        ]

        MoodCheckIn.collectionViewLayout = generateLayout()
        MoodCheckIn.delegate = self
        MoodCheckIn.dataSource = self

        registerCells()
    }
   

       // MARK: - Open Tell Mood Screen
       private func openTellMoodSelection(indexPath: IndexPath? = nil) {
           let storyboard = UIStoryboard(name: "tell_Mood", bundle: nil)
           let vc = storyboard.instantiateViewController(
               withIdentifier: "TellMoodSelectionViewController"
           ) as! TellMoodSelectionViewController

           vc.selectedIndexPath = indexPath
           vc.delegate = self
           vc.modalPresentationStyle = .fullScreen
           present(vc, animated: true)
       }

    // MARK: - Cell Registration
    func registerCells() {
        MoodCheckIn.register(
            UINib(nibName: "MoodCheckInCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "mood_cell"
        )

        MoodCheckIn.register(
            UINib(nibName: "DailyCheckInCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "daily_CheckIn"
        )

        MoodCheckIn.register(
            UINib(nibName: "OngoingCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "noongoing_cell"
        )

        MoodCheckIn.register(
            UINib(nibName: "ActivityStatsCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "activitystats_cell"
        )

        MoodCheckIn.register(
            UINib(nibName: "TitleCollectionResuableView", bundle: nil),
            forSupplementaryViewOfKind: "title",
            withReuseIdentifier: "title_cell"
        )
    }

    // MARK: - Layout
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
                    top: 30, leading: 16, bottom: 0, trailing: 16
                )
                section.interGroupSpacing = 8

                return section
            }

            // SECTION 1 – Daily Check-In
            if section == 1 {

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

            // SECTION 2 – Ongoing Activity
            if section == 2 {

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
                    top: 10, leading: 16, bottom: 16, trailing: 16
                )
                section.boundarySupplementaryItems = [titleItem]

                return section
            }

            // SECTION 3 – Activity Stats
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .absolute(100),
                heightDimension: .absolute(140)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let groupSize = NSCollectionLayoutSize(
                widthDimension: .estimated(100),
                heightDimension: .absolute(140)
            )
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: groupSize,
                subitems: [item]
            )
            group.interItemSpacing = .fixed(15)

            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .continuous
            section.interGroupSpacing = 34
            section.contentInsets = NSDirectionalEdgeInsets(
                top: 10, leading: 16, bottom: 25, trailing: 16
            )
            section.boundarySupplementaryItems = [titleItem]

            return section
        }
    }
}

// MARK: - UICollectionView DataSource & Delegate
extension MoodViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 4
    }

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {

        switch section {
        case 0: return moods.count
        case 1: return 1
        case 2: return 1
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
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "daily_CheckIn",
                for: indexPath
            ) as! DailyCheckInCollectionViewCell
            cell.configureCells()
            return cell

        case 2:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "noongoing_cell",
                for: indexPath
            ) as! OngoingCollectionViewCell
            cell.configureCells()
            return cell

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

        if indexPath.section == 2 {
            title.configureTitle(title: "Ongoing Activity", subtitle: "")
        } else if indexPath.section == 3 {
            title.configureTitle(title: "Activity Stats", subtitle: "")
        }

        return title
    }
}

// MARK: - Mood Cell Delegate
extension MoodViewController: MoodCheckInCellDelegate {

    func didTapMood(in cell: MoodCheckInCollectionViewCell) {
        guard cell.label.text == "Me" else {
                    return
                }
        guard let indexPath = MoodCheckIn.indexPath(for: cell) else { return }
        
        
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

// MARK: - Tell Mood Delegate
extension MoodViewController: TellMoodSelectionDelegate {
    
    func didSelectMood(_ mood: MoodCheckIn, at indexPath: IndexPath) {
        moods[indexPath.row].imageName = mood.imageName
        moods[indexPath.row].moodLabel = mood.moodLabel
        
        if let cell = MoodCheckIn.cellForItem(at: indexPath)
            as? MoodCheckInCollectionViewCell {
            
            cell.updateMood(
                imageName: mood.imageName,
                moodText: mood.moodLabel
            )
        }
    }
}
