import UIKit

class OngoingActivitiesModalViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var activities: [Activity] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activities = Array(DataStore.shared.getOngoingActivities().prefix(3))
        setupCollectionView()
    }
    
    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.setCollectionViewLayout(createLayout(), animated: false)
        
        collectionView.register(UINib(nibName: "ActivityCollectionViewCell", bundle: nil),
                                forCellWithReuseIdentifier: "activity_cell")
        
        collectionView.register(UINib(nibName: "TitleCollectionResuableView", bundle: nil),
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: "title_cell")
        
        collectionView.isScrollEnabled = false
        
        // Only top spacing (for grabber)
        collectionView.contentInset = UIEdgeInsets(top: 24, left: 0, bottom: 0, right: 0)
    }
    
    // MARK: - COMPOSITIONAL LAYOUT
    
    private func createLayout() -> UICollectionViewLayout {
        
        // ITEM
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(115)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        // GROUP
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(115)
        )
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        // SECTION
        let section = NSCollectionLayoutSection(group: group)
        
        // spacing between cells
        section.interGroupSpacing = 12
        
        // side padding
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: 20,
            bottom: 0,
            trailing: 20
        )
        
        // HEADER
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(50)
        )
        
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        
        // 🔥 KEY FIX: SPACE BETWEEN HEADER AND FIRST CELL
        header.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: 0,
            bottom: 16,   // 👈 controls gap below header
            trailing: 0
        )
        
        section.boundarySupplementaryItems = [header]
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    // MARK: - DATASOURCE
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return activities.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "activity_cell", for: indexPath) as! ActivityCollectionViewCell
        cell.configureCells(activity: activities[indexPath.row])
        return cell
    }
    
    // HEADER
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: "title_cell",
                for: indexPath
            ) as! TitleCollectionResuableView
            
            header.configureTitle(title: "Ongoing Activity", subtitle: "")
            return header
        }
        
        return UICollectionReusableView()
    }
    
    // MARK: - DELEGATE
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedActivity = activities[indexPath.row]
        let storyboard = UIStoryboard(name: "Steps", bundle: nil)
        
        if let stepsVC = storyboard.instantiateViewController(withIdentifier: "StepsViewController") as? StepsViewController {
            stepsVC.activitytitle = selectedActivity.name
            stepsVC.activity = selectedActivity
            stepsVC.flowSource = .explore
            stepsVC.modalPresentationStyle = .fullScreen
            
            self.dismiss(animated: true) {
                if let rootVC = UIApplication.shared.connectedScenes
                    .compactMap({ ($0 as? UIWindowScene)?.keyWindow })
                    .first?.rootViewController {
                    rootVC.present(stepsVC, animated: true)
                }
            }
        }
    }
    
    // MARK: - HEIGHT CALCULATION
    
    func calculateContentHeight() -> CGFloat {
        
        // Ensure layout is calculated
        collectionView.layoutIfNeeded()
        
        // Get actual content height from compositional layout
        let contentHeight = collectionView.collectionViewLayout.collectionViewContentSize.height
        
        // Include top inset (because you added it manually)
        let topInset = collectionView.contentInset.top
        let bottomInset = collectionView.contentInset.bottom
        
        return contentHeight + topInset + bottomInset
    }

}
