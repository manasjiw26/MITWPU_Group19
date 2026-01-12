//
//  MemoryLaneViewController.swift
//  Project Love 2.0
//
//  Created by SDC-USER on 17/12/25.
//

import UIKit

class MemoryLaneViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    
    @IBOutlet weak var memoryLaneItemCollectionView: UICollectionView!
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return memoryLaneItems.count
    }
    
    
    var memoryLaneItems: [MemoryItem] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.memoryLaneItems = dataStore.savedMemories.map { memory in
            return MemoryItem(imageName: memory.imageName)
        }
        
        memoryLaneItemCollectionView.dataSource = self
        memoryLaneItemCollectionView.delegate = self
        memoryLaneItemCollectionView.collectionViewLayout = generateLayout()
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "MemoryGridCell",
            for: indexPath
        ) as! MemoryGridCell

        let memory = dataStore.savedMemories[indexPath.item]
        
        if let realPhoto = memory.uiImage {
            cell.ImageView.image = realPhoto
        } else {
            cell.ImageView.image = UIImage(named: memory.imageName)
        }

        return cell
    }
    
    private func generateLayout() -> UICollectionViewLayout {
        
        let spacing: CGFloat = 1

        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0/3.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        item.contentInsets = NSDirectionalEdgeInsets(
            top: spacing,
            leading: spacing,
            bottom: spacing,
            trailing: spacing
        )

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalWidth(1.0/3.0)
        )
        
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )

        // 4. SECTION
        let section = NSCollectionLayoutSection(group: group)
        
        
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)

        return UICollectionViewCompositionalLayout(section: section)
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
