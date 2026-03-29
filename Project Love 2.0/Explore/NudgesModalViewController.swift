//
//  NudgesModalViewController.swift
//  Project Love 2.0
//
//  Created by SDC-USER on 25/03/26.
//

import UIKit

class NudgesModalViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var nudgesCollectionView: UICollectionView!
    @IBOutlet weak var titleLabel: UILabel!
    
    var rewards: [Reward] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        nudgesCollectionView.backgroundColor = .clear
        
        nudgesCollectionView.register(
            UINib(nibName: "RewardsCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "reward_cell"
        )
        
        nudgesCollectionView.delegate = self
        nudgesCollectionView.dataSource = self
        nudgesCollectionView.showsHorizontalScrollIndicator = false
    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return rewards.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "reward_cell",
            for: indexPath
        ) as! RewardsCollectionViewCell
        cell.configureCell(reward: rewards[indexPath.row])
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let reward = rewards[indexPath.row]
        let modalVC = RewardModalViewController(nibName: "RewardModalViewController", bundle: nil)
        
        modalVC.rewardName = reward.name
        modalVC.rewardEmoji = reward.emoji
        modalVC.initialStep = reward.progressStep
        
        modalVC.onProgressUpdate = { [weak self] newStep in
            self?.rewards[indexPath.row].progressStep = newStep
            collectionView.reloadItems(at: [indexPath])
        }
        
        modalVC.modalPresentationStyle = .pageSheet
        
        if let sheet = modalVC.sheetPresentationController {
            sheet.detents = [
                .custom { _ in return 350 }
            ]
            sheet.preferredCornerRadius = 30
        }
        
        self.present(modalVC, animated: true)
    }
}
