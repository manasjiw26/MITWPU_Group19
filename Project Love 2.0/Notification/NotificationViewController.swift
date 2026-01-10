import UIKit

final class NotificationViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        <#code#>
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        <#code#>
    }
    

    @IBOutlet weak var collectionView: UICollectionView!

    private var notifications: [AppNotification] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        loadNotifications()
    }

    private func setupCollectionView() {
        collectionView.register(
            UINib(nibName: "NotificationCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "NotificationCollectionViewCell"
        )

        collectionView.delegate = self
        collectionView.dataSource = self

        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.minimumLineSpacing = 12
            layout.sectionInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        }
    }

    private func loadNotifications() {
        notifications = DataStore.shared.notifications
        collectionView.reloadData()
    }
}

