//
//  ExploreViewController.swift
//  Project Love 2.0
//
//  Created by SDC-USER on 25/11/25.
//

import UIKit

class ExploreViewController: UIViewController, UICollectionViewDelegate {
    
    @IBOutlet var activity_collection: UICollectionView!
    var rewards: [Reward] = []
    var activityCategory: [ActivityCategory] = []
    var activity : [Activity] = []
    var selectedSegmentIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rewards = dataStore.rewards
        
        dataStore.loadActivityCategory()
        dataStore.loadSampleData()
        activityCategory = dataStore.activityCategory
        activity=dataStore.activities
        registerCell()
        
        activity_collection.setCollectionViewLayout(generateLayout(), animated: true)
        activity_collection.dataSource = self
        activity_collection.delegate = self
    }
    
    func registerCell() {
        activity_collection.register(UINib(nibName: "RewardsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "reward_cell")
        
        activity_collection.register(UINib(nibName: "ActivityCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "activity_cell")
        
        activity_collection.register(UINib(nibName: "ActivitySectionHeaderViewCollectionReusableView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header_cell")
        
    }
    
    func generateLayout()->UICollectionViewLayout{
        let layout = UICollectionViewCompositionalLayout { section, env in
            
            if section == 0 { //Rewards
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .fractionalHeight(1.0)   // enough for circle + label
                )

                let item = NSCollectionLayoutItem(layoutSize: itemSize)
//                item.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)

                
                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .absolute(100),
                    heightDimension: .absolute(120)
                )
                
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                group.interItemSpacing = .fixed(24)
                group.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
                
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .continuous
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
                
                return section
            } else {  // Activities (FlowLayout style)
                
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(115)   // your FlowLayout height
                )
                let item = NSCollectionLayoutItem(layoutSize: itemSize)

                // Full width group, height = 115 per cell
                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(115)
                )
                let group = NSCollectionLayoutGroup.vertical(
                    layoutSize: groupSize,
                    subitems: [item]
                )

                let section = NSCollectionLayoutSection(group: group)

                // match your top/left/bottom/right insets and line spacing
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

            print("Inside numberOfItemsInSection → selected segment =", selectedSegmentIndex)

            if selectedSegmentIndex == 0 {
                return activityCategory.count
            }
            else if selectedSegmentIndex == 1 {
                activity = dataStore.getOngoingActivities()
                return activity.count// or filter ongoing count
            }
            else if selectedSegmentIndex == 2 {
                activity = dataStore.getCompletedActivities()
                return activity.count// or filter completed count
            }
            else if selectedSegmentIndex == 3 {
                return 3// or custom
            }

            return activityCategory.count
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = activity_collection.dequeueReusableCell(withReuseIdentifier: "reward_cell", for: indexPath) as! RewardsCollectionViewCell
            let reward = rewards[indexPath.row]
            cell.configureCell(reward: reward)
            return cell
        } else {
            if selectedSegmentIndex == 0 {
                let cell = activity_collection.dequeueReusableCell(withReuseIdentifier: "activity_cell", for: indexPath) as! ActivityCollectionViewCell
                let activity = activityCategory[indexPath.row]
                cell.configureCell(activityCategory: activity)
                return cell
            } else if selectedSegmentIndex == 1 {   // ongoing
                let cell = activity_collection.dequeueReusableCell(
                    withReuseIdentifier: "activity_cell",
                    for: indexPath
                ) as! ActivityCollectionViewCell

                let ongoingActivities = dataStore.getOngoingActivities()
                let ongoingactivity = ongoingActivities[indexPath.row]
                cell.configureCells(activity: ongoingactivity)
                return cell
            }else if selectedSegmentIndex == 2 {   // Completed
                let cell = activity_collection.dequeueReusableCell(
                    withReuseIdentifier: "activity_cell",
                    for: indexPath
                ) as! ActivityCollectionViewCell

                let completedActivities = dataStore.getCompletedActivities()
                let completedactivity = completedActivities[indexPath.row]
                cell.configureCells(activity: completedactivity)
                return cell
            }
            let cell = activity_collection.dequeueReusableCell(withReuseIdentifier: "activity_cell", for: indexPath) as! ActivityCollectionViewCell
            let activity = activityCategory[indexPath.row]
            cell.configureCell(activityCategory: activity)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if indexPath.section != 0{
            let header = activity_collection.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header_cell", for: indexPath) as! ActivitySectionHeaderViewCollectionReusableView
            
            switch selectedSegmentIndex {
            case 0:
                header.titleLabel.text = "Activities"
                
            case 1:
                header.titleLabel.text = "Ongoing"
                
            case 2:
                header.titleLabel.text = "Completed"
                
            case 3:
                header.titleLabel.text = "Custom"
                
            default:
                break
            }
            header.delegate = self
            header.segmentedControl.selectedSegmentIndex = selectedSegmentIndex
            return header
        }
        return UICollectionReusableView()
    }
    
}
extension ExploreViewController: ActivityHeaderDelegate {
    func didChangeSegment(to index: Int) {
        selectedSegmentIndex = index
//        activity_collection.setCollectionViewLayout(generateLayout(), animated: true)
        activity_collection.reloadSections(IndexSet(integer : 1))
//        activity_collection.reloadData()
//        print("Selected segment:", selectedSegmentIndex)
    }
}
