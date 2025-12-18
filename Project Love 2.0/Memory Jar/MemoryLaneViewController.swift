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
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "MemoryGridCell",
            for: indexPath
        ) as! MemoryGridCell

        let item = memoryLaneItems[indexPath.item]
        cell.ImageView.image = UIImage(named: item.imageName)

        return cell
    }
    
    var memoryLaneItems: [MemoryItem] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        memoryLaneItemCollectionView.dataSource = self
              memoryLaneItemCollectionView.delegate = self
        
//        memoryLaneItems = dataStore.memoryLaneItems
        memoryLaneItemCollectionView.collectionViewLayout = generateLayout()
    }
    
    private func generateLayout() -> UICollectionViewLayout {


        let spacing: CGFloat = 2

        // ITEM (square)
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.33),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(
            top: spacing,
            leading: spacing,
            bottom: spacing,
            trailing: spacing
        )

        // GROUP (3 columns)
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(0.2)
        )
        
        let group = NSCollectionLayoutGroup.horizontal(
               layoutSize: groupSize,
               subitems: [item]
           )

        // SECTION
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .zero

        return UICollectionViewCompositionalLayout(section: section)    }



    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
