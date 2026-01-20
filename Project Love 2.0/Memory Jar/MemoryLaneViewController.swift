import UIKit

class MemoryLaneViewController: UIViewController,
                                UICollectionViewDataSource,
                                UICollectionViewDelegate {

    @IBOutlet weak var memoryLaneItemCollectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()

        memoryLaneItemCollectionView.dataSource = self
        memoryLaneItemCollectionView.delegate = self
        memoryLaneItemCollectionView.collectionViewLayout = generateLayout()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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

        if indexPath.item < dataStore.savedMemories.count {
            let memory = dataStore.savedMemories[indexPath.item]
            cell.ImageView.image = memory.uiImage ?? UIImage(named: memory.imageName)
        }

        return cell
    }

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
        
        // ITEM
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: spacing/2,
                                                     leading: spacing/2,
                                                     bottom: spacing/2,
                                                     trailing: spacing/2)

        // GROUP (Row with 3 items)
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalWidth(1.0 / columns)
        )
        
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitem: item,
            count: Int(columns)
        )

        // SECTION
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: spacing,
                                                        leading: spacing,
                                                        bottom: spacing,
                                                        trailing: spacing)

        return UICollectionViewCompositionalLayout(section: section)
    }
}
