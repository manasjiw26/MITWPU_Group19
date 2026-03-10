//
//  ExploreViewController.swift
//  Project Love 2.0
//
//  Created by SDC-USER on 25/11/25.
//

import UIKit

class ExploreViewController: UIViewController, UICollectionViewDelegate {
    
    @IBOutlet var activity_collection: UICollectionView!
    @IBOutlet var calendarButton: UIButton!
    
    var rewards: [Reward] = []
    var activityCategory: [ActivityCategory] = []
    var activity : [Activity] = []
    var selectedSegmentIndex: Int = 0
    var selectedCategory: ActivityCategory?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        calendarButton.configuration = .glass()
        calendarButton.setImage(UIImage(systemName: "calendar"), for: .normal)
        
        rewards = DataStore.shared.rewards
        
        DataStore.shared.loadActivityCategory()
        
        activityCategory = DataStore.shared.activityCategory
        activity = DataStore.shared.activities
        
        registerCell()
        
        activity_collection.setCollectionViewLayout(generateLayout(), animated: true)
        activity_collection.dataSource = self
        activity_collection.delegate = self

        // Listen for Supabase sync completions
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleActivitiesSynced),
            name: .activitiesSynced,
            object: nil
        )
    }

    @objc private func handleActivitiesSynced() {
        activity_collection.reloadData()
    }
    private func isEmptyState() -> Bool {
        if selectedSegmentIndex == 1 {
            return DataStore.shared.getOngoingActivities().isEmpty
        }
        if selectedSegmentIndex == 2 {
            return DataStore.shared.getCompletedActivities().isEmpty
        }
        return false
    }
    private func showCustomActivityAlert() {
        let storyboard = UIStoryboard(name: "WriteActivity", bundle: nil)
        let vc = storyboard.instantiateViewController(
            withIdentifier: "WriteActivity"
        ) as! WriteActivityViewController

        if let nav = self.navigationController {
            nav.pushViewController(vc, animated: true)
        } else {
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true)
        }
    }
    private func openActivity(_ activity: Activity) {
        let modalVC = CustomModalViewController(
            nibName: "CustomModalViewController",
            bundle: nil
        )

        // Passing the data
        modalVC.activityName = activity.name
        modalVC.activityDescription = activity.description
        modalVC.imageName = activity.image

        modalVC.modalPresentationStyle = .overFullScreen

        present(modalVC, animated: true)
    }

    @IBAction func calendarTapped(_ sender: UIButton) {
        openCalendarModal()
    }
    
    private func openCalendarModal() {

        let storyboard = UIStoryboard(name: "Calendar", bundle: nil)
            let calendarVC = storyboard.instantiateViewController(
                withIdentifier: "CalendarViewController"
            )

            navigationController?.pushViewController(calendarVC, animated: true)
    }
    
    func registerCell() {
        activity_collection.register(UINib(nibName: "RewardsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "reward_cell")
        
        activity_collection.register(UINib(nibName: "ActivityCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "activity_cell")
        
        activity_collection.register(UINib(nibName: "ActivitySectionHeaderViewCollectionReusableView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header_cell")
        
        activity_collection.register( UINib(nibName: "TitleCollectionResuableView", bundle: nil), forSupplementaryViewOfKind: "title", withReuseIdentifier: "title_cell")

        activity_collection.register(
            UINib(nibName: "EmptyStateCollectioViewCellCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "empty_cell"
        )
        activity_collection.register(
            UINib(nibName: "CustomCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "custom_cell"
        )
        activity_collection.register(
            UINib(nibName: "ScheduleCalendarCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "scheduleCalendar_cell"
        )
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "CategoryVC" {
                let vc = segue.destination as! CategoryViewController
                vc.category = selectedCategory
            }
        }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Ensure user context is loaded before syncing
        Task {
            if DataStore.shared.currentRelationshipId == nil {
                await DataStore.shared.loadUserContext()
            }
            DataStore.shared.syncActivitiesFromSupabase()
        }

        activity_collection.reloadData()
    }
    
    func generateLayout()->UICollectionViewLayout{
        let layout = UICollectionViewCompositionalLayout { section, env in
            
            if section == 0 { //Rewards
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .fractionalHeight(1.0)   // for circle and label
                )

                let item = NSCollectionLayoutItem(layoutSize: itemSize)

                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .absolute(100),
                    heightDimension: .absolute(120)
                )
                
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                group.interItemSpacing = .fixed(24)
                group.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 10, bottom: 10, trailing: 10)
                
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .continuous
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 5, trailing: 10)

                
                let headerSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .estimated(70)
                )

                let titleSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(36)
                )

                let titleHeader = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: titleSize,
                    elementKind: "title",
                    alignment: .top
                )

                titleHeader.contentInsets = NSDirectionalEdgeInsets(
                    top: -5,
                    leading: 16,
                    bottom: 4,
                    trailing: 16
                )

                section.boundarySupplementaryItems = [titleHeader]


                return section
            } else {  // Activities
                
                if self.isEmptyState() {

                        let itemSize = NSCollectionLayoutSize(
                            widthDimension: .fractionalWidth(1.0),
                            heightDimension: .absolute(450)
                        )

                        let item = NSCollectionLayoutItem(layoutSize: itemSize)

                        let groupSize = NSCollectionLayoutSize(
                            widthDimension: .fractionalWidth(1.0),
                            heightDimension: .absolute(450)
                        )

                        let group = NSCollectionLayoutGroup.vertical(
                            layoutSize: groupSize,
                            subitems: [item]
                        )

                        let section = NSCollectionLayoutSection(group: group)
                        section.contentInsets = NSDirectionalEdgeInsets(
                            top: 40, leading: 16, bottom: 40, trailing: 16
                        )

                        // header
                        let headerSize = NSCollectionLayoutSize(
                            widthDimension: .fractionalWidth(1),
                            heightDimension: .estimated(70)
                        )

                        let headerItem = NSCollectionLayoutBoundarySupplementaryItem(
                            layoutSize: headerSize,
                            elementKind: UICollectionView.elementKindSectionHeader,
                            alignment: .top
                        )

                        section.boundarySupplementaryItems = [headerItem]
                        return section
                    }

                
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(115)
                )
                let item = NSCollectionLayoutItem(layoutSize: itemSize)

                
                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(115)
                )
                let group = NSCollectionLayoutGroup.vertical(
                    layoutSize: groupSize,
                    subitems: [item]
                )

                let section = NSCollectionLayoutSection(group: group)

                section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
                section.interGroupSpacing = 12

                // header
                let headerSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .estimated(70)
                )
                let headerItem = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: headerSize,
                    elementKind: UICollectionView.elementKindSectionHeader,
                    alignment: .top
                )

                section.boundarySupplementaryItems = [headerItem]

                return section
            }
        }
        return layout
    }
}

extension ExploreViewController:  UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return rewards.count
        }
        else {


            if selectedSegmentIndex == 0 {
                return activityCategory.count
            }
            else if selectedSegmentIndex == 1 {
                let count = DataStore.shared.getOngoingActivities().count
                return count == 0 ? 1 : count
            }
            else if selectedSegmentIndex == 2 {
                let count = DataStore.shared.getCompletedActivities().count
                return count == 0 ? 1 : count
            }
            else if selectedSegmentIndex == 3 {
                return 1 + DataStore.shared.customActivities.count
            }

            return activityCategory.count
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        // Rewards
        if indexPath.section == 0 {
            let cell = activity_collection.dequeueReusableCell(
                withReuseIdentifier: "reward_cell",
                for: indexPath
            ) as! RewardsCollectionViewCell

            let reward = rewards[indexPath.row]
            cell.configureCell(reward: reward)
            return cell
        }

        // Activities
        // Emty state – Ongoing
        if selectedSegmentIndex == 1,
           DataStore.shared.getOngoingActivities().isEmpty {

            let cell = activity_collection.dequeueReusableCell(
                withReuseIdentifier: "empty_cell",
                for: indexPath
            ) as! EmptyStateCollectioViewCellCollectionViewCell

            cell.configure(
                title: "No ongoing activities",
                subtitle: "Take a moment to check in or try a new activity that fits your vibe today.",
                imageName: "empty_ongoing"
            )
            return cell
        }

        // Emty state – Completed
        if selectedSegmentIndex == 2,
           DataStore.shared.getCompletedActivities().isEmpty {

            let cell = activity_collection.dequeueReusableCell(
                withReuseIdentifier: "empty_cell",
                for: indexPath
            ) as! EmptyStateCollectioViewCellCollectionViewCell

            cell.configure(
                title: "No completed activities ",
                subtitle: "Try exploring something fun and make your first memory today!",
                imageName: "empty_completed"
            )
            return cell
        }


        if selectedSegmentIndex == 0 {
            let cell = activity_collection.dequeueReusableCell(
                withReuseIdentifier: "activity_cell",
                for: indexPath
            ) as! ActivityCollectionViewCell

            let activity = activityCategory[indexPath.row]
            cell.configureCell(activityCategory: activity)
            return cell
        }

        if selectedSegmentIndex == 1 {
            let cell = activity_collection.dequeueReusableCell(
                withReuseIdentifier: "activity_cell",
                for: indexPath
            ) as! ActivityCollectionViewCell

            let ongoingActivities = DataStore.shared.getOngoingActivities()
            let ongoingactivity = ongoingActivities[indexPath.row]
            cell.configureCells(activity: ongoingactivity)
            return cell
        }

        if selectedSegmentIndex == 2 {
            let cell = activity_collection.dequeueReusableCell(
                withReuseIdentifier: "activity_cell",
                for: indexPath
            ) as! ActivityCollectionViewCell

            let completedActivities = DataStore.shared.getCompletedActivities()
            let completedactivity = completedActivities[indexPath.row]
            cell.configureCells(activity: completedactivity)
            return cell
        }
        
        if selectedSegmentIndex == 3 {
            if indexPath.row == 0 {
                let cell = activity_collection.dequeueReusableCell(
                    withReuseIdentifier: "custom_cell",
                    for: indexPath
                ) as! CustomCollectionViewCell
                cell.configureCells(imageName: "customBorder", title: "Create your own activity!", subtitle: "Add your unique spark.")
                return cell
            }else {
                let cell = activity_collection.dequeueReusableCell(
                    withReuseIdentifier: "activity_cell",
                    for: indexPath
                ) as! ActivityCollectionViewCell
                
                let customActivity = DataStore.shared.customActivities[indexPath.row - 1]
                
                cell.configureCells(activity: customActivity)

                cell.activityDescriptionLabel.text = customActivity.time
                
                return cell
            }
        }

        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {

        if kind == "title" {
            let title = collectionView.dequeueReusableSupplementaryView(
                ofKind: "title",
                withReuseIdentifier: "title_cell",
                for: indexPath
            ) as! TitleCollectionResuableView

            title.configureTitle(title: "Nudges", subtitle: "")
            return title
        }

        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "header_cell",
            for: indexPath
        ) as! ActivitySectionHeaderViewCollectionReusableView

        header.segmentedControl.isHidden = false
        header.delegate = self
        header.segmentedControl.selectedSegmentIndex = selectedSegmentIndex

        switch selectedSegmentIndex {
        case 0: header.titleLabel.text = "Activities"
        case 1: header.titleLabel.text = "Ongoing"
        case 2: header.titleLabel.text = "Completed"
        case 3: header.titleLabel.text = "Custom"
        default: break
        }

        return header
    }


    
}
extension ExploreViewController: ActivityHeaderDelegate {
    func didChangeSegment(to index: Int) {
        selectedSegmentIndex = index
        activity_collection.reloadSections(IndexSet(integer : 1))
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            let reward = rewards[indexPath.row]
            let modalVC = RewardModalViewController(nibName: "RewardModalViewController", bundle: nil)

            modalVC.rewardName = reward.name
            modalVC.rewardEmoji = reward.emoji
            modalVC.initialStep = reward.progressStep

            modalVC.onProgressUpdate = { [weak self] newStep in
                self?.rewards[indexPath.row].progressStep = newStep
            }

            modalVC.modalPresentationStyle = .pageSheet

            if let sheet = modalVC.sheetPresentationController {
                sheet.detents = [
                        .custom { _ in
                            return 350 //height of the modal
                        }
                    ]
                sheet.preferredCornerRadius = 30
                
            }

            self.present(modalVC, animated: true)
            return
        }

        guard indexPath.section == 1 else { return }

        switch selectedSegmentIndex {

        case 0: // All Category
            selectedCategory = activityCategory[indexPath.row]
            performSegue(withIdentifier: "CategoryVC", sender: self)

        case 1: // Ongoing
            let ongoingActivities = DataStore.shared.getOngoingActivities()
            let activity = ongoingActivities[indexPath.row] 
            let storyboard = UIStoryboard(name: "Steps", bundle: nil)
            if let stepsVC = storyboard.instantiateViewController(withIdentifier: "StepsViewController") as? StepsViewController {
                stepsVC.activitytitle = activity.name
                stepsVC.activity = activity
                stepsVC.flowSource = .explore
                stepsVC.modalPresentationStyle = .fullScreen
                self.present(stepsVC, animated: true, completion: nil)
            }

//        case 2: // Completed → Open feedback / summary
//            let activity = DataStore.shared.getCompletedActivities()[indexPath.row]
//            openActivity(activity)
        case 3: // Custom
            if indexPath.row == 0 {

                showCustomActivityAlert()
                
            } else {
                let customActivity = DataStore.shared.customActivities[indexPath.row - 1]
                openActivity(customActivity)
            }

        default:
            break
        }
    }
}
