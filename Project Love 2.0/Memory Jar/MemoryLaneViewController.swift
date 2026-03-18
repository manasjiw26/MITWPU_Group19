import UIKit

class MemoryLaneViewController: UIViewController,
                                UICollectionViewDataSource,
                                UICollectionViewDelegate {

    @IBOutlet weak var memoryLaneItemCollectionView: UICollectionView!
    var autoOpenIndex: Int?
    private var hasAutoOpened = false
    override func viewDidLoad() {
        super.viewDidLoad()

        memoryLaneItemCollectionView.dataSource = self
        memoryLaneItemCollectionView.delegate = self

        memoryLaneItemCollectionView.register(
            UINib(nibName: "memoryEmptyStateCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "emptyMemoryState"
        )

        refreshUI()

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshUI()
    }
    private var isEmptyState: Bool {
        dataStore.savedMemories.isEmpty
    }

    private func refreshUI() {
        memoryLaneItemCollectionView.setCollectionViewLayout(generateLayout(), animated: false)
        memoryLaneItemCollectionView.collectionViewLayout.invalidateLayout()
        memoryLaneItemCollectionView.reloadData()
    }

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return dataStore.savedMemories.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "MemoryGridCell",
            for: indexPath
        ) as! MemoryGridCell

        guard indexPath.item < dataStore.savedMemories.count else { return cell }
        let memory = dataStore.savedMemories[indexPath.item]

        // Clear immediately so recycled cells don't flash stale images
        cell.ImageView.image = nil
        // Tag the cell with the current item index to detect stale reuse
        cell.tag = indexPath.item

        MemoryFileManager.loadImageAsync(fileName: memory.imageName) { [weak cell] image in
            // Only apply if this cell still represents the same item
            guard let cell = cell, cell.tag == indexPath.item else { return }
            cell.ImageView.image = image ?? memory.uiImage
        }

        return cell
    }
    
    // Memory clicked open full image
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {

        guard indexPath.item < dataStore.savedMemories.count else { return }

        let storyboard = UIStoryboard(name: "MemoryJar", bundle: nil)
        let vc = storyboard.instantiateViewController(
            withIdentifier: "photoView"
        ) as! memoryPhotoViewController

        vc.currentIndex = indexPath.item
        navigationController?.pushViewController(vc, animated: true)
    }

    private func generateLayout() -> UICollectionViewLayout {

        let spacing: CGFloat = 2
        let columns: CGFloat = 3
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: spacing/2,
                                                     leading: spacing/2,
                                                     bottom: spacing/2,
                                                     trailing: spacing/2)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalWidth(1.0 / columns)
        )
        
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitem: item,
            count: Int(columns)
        )
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: spacing,
                                                        leading: spacing,
                                                        bottom: spacing,
                                                        trailing: spacing)

        return UICollectionViewCompositionalLayout(section: section)
    }
}
