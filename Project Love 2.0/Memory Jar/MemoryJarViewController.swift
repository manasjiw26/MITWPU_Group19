import UIKit
import SpriteKit

class MemoryJarViewController: UIViewController,
UICollectionViewDataSource,
UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var memoryLaneCollectionView: UICollectionView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var MemoryJarView: SKView!
    
    // MARK: - CollectionView DataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // Return dynamic count from DataStore
        return dataStore.savedMemories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MemoryLaneCell", for: indexPath) as! MemoryLaneCell
        
        let memory = dataStore.savedMemories[indexPath.item]
        
        // Prioritize showing the real picked photo; fallback to asset name
        if let realPhoto = memory.uiImage {
            cell.ImageView.image = realPhoto
        } else {
            cell.ImageView.image = UIImage(named: memory.imageName)
        }
        
        return cell
    }
    
    // MARK: - Notification Handling
    
    @objc func handleNewMemory() {
        if let scene = MemoryJarView.scene as? MemoryJarScene {
            // Trigger SpriteKit animation
            scene.addHeart()
            
            DispatchQueue.main.async {
                // 1. Reload the collection view data
                self.memoryLaneCollectionView.reloadData()
                
                // 2. Automatically scroll to the newly added memory at the end
                let lastItem = dataStore.savedMemories.count - 1
                if lastItem >= 0 {
                    let indexPath = IndexPath(item: lastItem, section: 0)
                    self.memoryLaneCollectionView.scrollToItem(at: indexPath, at: .right, animated: true)
                }
            }
            
            // Performance settings
            MemoryJarView.showsPhysics = false
            MemoryJarView.showsFPS = false
            MemoryJarView.showsNodeCount = false
            MemoryJarView.isAccessibilityElement = false
        }
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addButton.configuration = .glass()
        addButton.setTitle("Add", for: .normal)
        
        memoryLaneCollectionView.dataSource = self
        memoryLaneCollectionView.delegate = self
        memoryLaneCollectionView.collectionViewLayout = generateLayout()
        
        // Observe the custom notification from addNewViewController
        NotificationCenter.default.addObserver(self, selector: #selector(handleNewMemory), name: NSNotification.Name("MemoryAdded"), object: nil)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if MemoryJarView.scene == nil {
            MemoryJarView.backgroundColor = .clear
            MemoryJarView.showsPhysics = false
            
            // Present the SpriteKit scene using view bounds
            let scene = MemoryJarScene(size: MemoryJarView.bounds.size)
            scene.scaleMode = .aspectFill
            MemoryJarView.presentScene(scene)
        }
    }
    
    // MARK: - Layout Generation
    
    private func generateLayout() -> UICollectionViewLayout {
        // 1. Spacing between photos
        let spacing: CGFloat = 1

        // 2. ITEM: Since height is fixed, we set height to 100% of the group
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalHeight(1.0), // Makes width match height (Square)
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(
            top: spacing,
            leading: spacing,
            bottom: spacing,
            trailing: spacing
        )

        // 3. GROUP: Lock the height to 110
        // The width is .estimated(110) so it can repeat horizontally
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .estimated(110),
            heightDimension: .absolute(110)
        )
        
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )

        // 4. SECTION: Horizontal scrolling
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)

        return UICollectionViewCompositionalLayout(section: section)
    }
}
