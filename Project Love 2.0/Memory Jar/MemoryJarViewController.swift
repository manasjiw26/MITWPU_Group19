import UIKit
import SpriteKit

class MemoryJarViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var memoryLaneCollectionView: UICollectionView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var MemoryJarView: SKView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        memoryLaneCollectionView.dataSource = self
        memoryLaneCollectionView.collectionViewLayout = generateLayout()
        
        // Critical: Fixes the black box and ensures the SpriteKit jar is visible
        MemoryJarView.allowsTransparency = true
        MemoryJarView.backgroundColor = .clear
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleNewMemory), name: NSNotification.Name("MemoryAdded"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showMemoryDisplay(_:)), name: NSNotification.Name("OpenMemory"), object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        MemoryJarView.isPaused = false
        memoryLaneCollectionView.reloadData()
        
        // Sync hearts to fix the "doubling" issue
        syncJarHearts()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        MemoryJarView.isPaused = true
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if MemoryJarView.scene == nil {
            let scene = MemoryJarScene(size: MemoryJarView.bounds.size)
            scene.scaleMode = .aspectFill
            MemoryJarView.presentScene(scene)
            syncJarHearts()
        }
    }

    private func syncJarHearts() {
        guard let scene = MemoryJarView.scene as? MemoryJarScene else { return }
        
        // Filter nodes by name to target ONLY hearts
        let currentHearts = scene.children.filter { $0.name == "heart_node" }
        let actualDataCount = dataStore.savedMemories.count
        
        // Only refresh if the count is incorrect (prevents doubling hearts)
        if currentHearts.count != actualDataCount {
            // "Surgical" removal: Jar body and Cap stay because their names are different
            scene.enumerateChildNodes(withName: "heart_node") { node, _ in
                node.removeFromParent()
            }
            
            for (index, _) in dataStore.savedMemories.enumerated() {
                scene.addHeart(index: index, animate: false)
            }
        }
    }

    @objc func handleNewMemory() {
        DispatchQueue.main.async {
            self.memoryLaneCollectionView.reloadData()
            
            if let scene = self.MemoryJarView.scene as? MemoryJarScene {
                let newIndex = dataStore.savedMemories.count - 1
                // Add ONE heart with the "Cap opening" animation
                scene.addHeart(index: newIndex, animate: true)
                
                let indexPath = IndexPath(item: newIndex, section: 0)
                self.memoryLaneCollectionView.scrollToItem(at: indexPath, at: .right, animated: true)
            }
        }
    }

    // MARK: - CollectionView Methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataStore.savedMemories.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MemoryLaneCell", for: indexPath) as! MemoryLaneCell
        let memory = dataStore.savedMemories[indexPath.item]
        cell.ImageView.image = memory.uiImage ?? UIImage(named: memory.imageName)
        return cell
    }

    private func generateLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalHeight(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .estimated(110), heightDimension: .absolute(110))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 1
        section.orthogonalScrollingBehavior = .continuous
        return UICollectionViewCompositionalLayout(section: section)
    }

    @objc func showMemoryDisplay(_ notification: Notification) {
        guard let index = notification.object as? Int else { return }
        if let displayVC = storyboard?.instantiateViewController(withIdentifier: "memoryDisplay") as? memoryDisplay {
            displayVC.memory = dataStore.savedMemories[index]
            displayVC.modalPresentationStyle = .pageSheet
            self.present(displayVC, animated: true)
        }
    }
}
