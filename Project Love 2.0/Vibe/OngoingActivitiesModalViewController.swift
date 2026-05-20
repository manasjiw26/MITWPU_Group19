import UIKit

class OngoingActivitiesModalViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    // Built programmatically – no storyboard required
    private var collectionView: UICollectionView!
    var activities: [Activity] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activities = Array(DataStore.shared.getOngoingActivities(forVibePage: true).prefix(3))
        setupCollectionView()
    }
    
    private func setupCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(UINib(nibName: "ActivityCollectionViewCell", bundle: nil),
                                forCellWithReuseIdentifier: "activity_cell")
        
        collectionView.register(UINib(nibName: "TitleCollectionResuableView", bundle: nil),
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: "title_cell")
        
        collectionView.isScrollEnabled = false
        collectionView.contentInset = UIEdgeInsets(top: 24, left: 0, bottom: 0, right: 0)
        
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func createLayout() -> UICollectionViewLayout {
     
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(115)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(115)
        )
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        
        section.interGroupSpacing = 12
        
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: 20,
            bottom: 0,
            trailing: 20
        )
        
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(50)
        )
        
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        
        header.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: 0,
            bottom: 16,
            trailing: 0
        )
        
        section.boundarySupplementaryItems = [header]
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return activities.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "activity_cell", for: indexPath) as! ActivityCollectionViewCell
        cell.configureCells(activity: activities[indexPath.row])
        return cell
    }
    
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedActivity = activities[indexPath.row]
        let storyboard = UIStoryboard(name: "Steps", bundle: nil)
        
        if let stepsVC = storyboard.instantiateViewController(withIdentifier: "StepsViewController") as? StepsViewController {
            stepsVC.activitytitle = selectedActivity.name
            stepsVC.activity = selectedActivity
            stepsVC.flowSource = .explore
            self.navigationController?.pushViewController(stepsVC, animated: true)
        }
    }

    func calculateContentHeight() -> CGFloat {
        collectionView.layoutIfNeeded()
        let contentHeight = collectionView.collectionViewLayout.collectionViewContentSize.height
        let topInset = collectionView.contentInset.top
        let bottomInset = collectionView.contentInset.bottom
        return contentHeight + topInset + bottomInset
    }

}
