//
//  MemoryJarViewController.swift
//  Project Love 2.0
//
//  Created by SDC-USER on 25/11/25.
//

import UIKit

class MemoryJarViewController: UIViewController,
UICollectionViewDataSource,
UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var memoryLaneCollectionView: UICollectionView!
    
    
    @IBOutlet weak var addButton: UIButton!
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MemoryLaneCell", for: indexPath) as! MemoryLaneCell
             
       
        
        cell.ImageView.image = UIImage(named: "memjar\(indexPath.item + 1)")
        
        return cell
        
    }
    

    

    
    override func viewDidLoad() {
        super.viewDidLoad()

        addButton.configuration = .glass()
        addButton.setTitle("Add", for: .normal)
        
        
        
        memoryLaneCollectionView.dataSource = self
        memoryLaneCollectionView.delegate = self

        memoryLaneCollectionView.collectionViewLayout = generateLayout()
    }
    private func generateLayout() -> UICollectionViewLayout {

        let itemSize = NSCollectionLayoutSize(
            widthDimension: .absolute(100),
            heightDimension: .absolute(100)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .absolute(100),
            heightDimension: .absolute(100)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )
//        group.interItemSpacing = .fixed(10)

        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.interGroupSpacing = 12

        // THIS centers the cells vertically in 90pt height
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: 10,
            bottom: 0,
            trailing: 10
        )

        return UICollectionViewCompositionalLayout(section: section)
    }
}
