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
        
        MemoryJarView.allowsTransparency = true
        MemoryJarView.backgroundColor = .clear
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleNewMemory), name: NSNotification.Name("MemoryAdded"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showMemoryDisplay(_:)), name: NSNotification.Name("OpenMemory"), object: nil)
        memoryLaneCollectionView.alwaysBounceVertical = false
        memoryLaneCollectionView.showsVerticalScrollIndicator = false
        memoryLaneCollectionView.contentInsetAdjustmentBehavior = .never

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        MemoryJarView.isPaused = false
        memoryLaneCollectionView.reloadData()
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
        let currentHearts = scene.children.filter { $0.name?.hasPrefix("heart_") == true }
        let actualDataCount = dataStore.savedMemories.count
        
        if currentHearts.count != actualDataCount {
            scene.children
                .filter { $0.name?.hasPrefix("heart_") == true }
                .forEach { $0.removeFromParent() }
            
            for (index, memory) in dataStore.savedMemories.enumerated() {
                scene.addHeart(index: index, memoryID: memory.id, animate: false)
            }
        }
    }

    @objc func handleNewMemory() {
        //UI work must be done on the main thread to Prevents crashes and visual glitches
        DispatchQueue.main.async {
            self.memoryLaneCollectionView.reloadData()
            
            if let scene = self.MemoryJarView.scene as? MemoryJarScene {
                let newIndex = dataStore.savedMemories.count - 1
                let memory = dataStore.savedMemories[newIndex]
                scene.addHeart(index: newIndex, memoryID: memory.id, animate: true)
                // To scroll to last index where memory is added
                let indexPath = IndexPath(item: newIndex, section: 0)
                self.memoryLaneCollectionView.scrollToItem(at: indexPath, at: .right, animated: true)
            }
        }
    }
    
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
        
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .estimated(110),
            heightDimension: .absolute(110)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 2   // space between cells
        section.orthogonalScrollingBehavior = .continuous
        
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12) // left-right spacing
        
        return UICollectionViewCompositionalLayout(section: section)
    }

    @objc func showMemoryDisplay(_ notification: Notification) {
        
        guard let index = notification.object as? Int else { return }
        
        guard index >= 0 && index < dataStore.savedMemories.count else { return }
        
        if let displayVC = storyboard?.instantiateViewController(withIdentifier: "memoryDisplay") as? memoryDisplay {
            displayVC.memory = dataStore.savedMemories[index]
            displayVC.modalPresentationStyle = .pageSheet
            self.present(displayVC, animated: true)
        }
    }
}
