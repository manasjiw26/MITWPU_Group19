//
//  MemoryJarViewController.swift
//  Project Love 2.0
//
//  Created by SDC-USER on 25/11/25.
//

import UIKit
import SpriteKit

class MemoryJarViewController: UIViewController,
UICollectionViewDataSource,
UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var memoryLaneCollectionView: UICollectionView!
    
    
    @IBOutlet weak var addButton: UIButton!
    
    @IBOutlet weak var MemoryJarView: SKView!
    
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MemoryLaneCell", for: indexPath) as! MemoryLaneCell
             
       
        
        cell.ImageView.image = UIImage(named: "memjar\(indexPath.item + 1)")
        
        return cell
        
    }
    @objc func handleNewMemory() {
            // 2. Ab direct MemoryJarView se scene access karein, subviews ki zaroorat nahi
            if let scene = MemoryJarView.scene as? MemoryJarScene {
                scene.addHeart()
                
                // Lag fix karne ke liye debugging hamesha false rakhein
                MemoryJarView.showsPhysics = false
                MemoryJarView.showsFPS = false
                MemoryJarView.showsNodeCount = false
                MemoryJarView.isAccessibilityElement = false
                
            }
        }
    

    

    
    override func viewDidLoad() {
            super.viewDidLoad()

            addButton.configuration = .glass()
            addButton.setTitle("Add", for: .normal)
            
            memoryLaneCollectionView.dataSource = self
            memoryLaneCollectionView.delegate = self
            memoryLaneCollectionView.collectionViewLayout = generateLayout()

            NotificationCenter.default.addObserver(self, selector: #selector(handleNewMemory), name: NSNotification.Name("MemoryAdded"), object: nil)
        }

        // 3. View sizes calculate hone ke baad scene present karna best hota hai
        override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            
            if MemoryJarView.scene == nil {
                MemoryJarView.backgroundColor = .clear
                MemoryJarView.showsPhysics = true
                
                
                // Scene creation with direct bounds
                let scene = MemoryJarScene(size: MemoryJarView.bounds.size)
                scene.scaleMode = .aspectFill
                MemoryJarView.presentScene(scene)
            }
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
