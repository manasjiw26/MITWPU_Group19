
import UIKit

final class NotificationViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    var activities = dataStore.getSuggestedActivities()
    private var notifications: [AppNotification] = []

     override func viewDidLoad() {
         super.viewDidLoad()
         setupCollectionView()
         loadNotifications()
     }

     private func setupCollectionView() {
         collectionView.register(
             UINib(nibName: "Notification1CollectionViewCell", bundle: nil),
             forCellWithReuseIdentifier: "Notification"
         )

         collectionView.delegate = self
         collectionView.dataSource = self

         if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
             layout.minimumLineSpacing = 16
             layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
             layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
         }
     }

     private func loadNotifications() {
         notifications = DataStore.shared.getNotifications()
         collectionView.reloadData()
     }
    
    //tap handling
    
     private func handleNotificationTap(_ notification: AppNotification) {
         switch notification.type {

         case .memory:
             openMemory(notification)

         case .activity:
             openActivity(notification)

         case .loveNote:
             openLoveNote(notification)

         case .mood:
             openMoodUpdate(notification)
         }
     }

    private func openMemory(_ notification: AppNotification) {
        NotificationCenter.default.post(name: NSNotification.Name("OpenMemory"), object: 0)
     }

     private func openActivity(_ notification: AppNotification) {
         let destinationVC = SmallModalViewController(nibName: "SmallModalViewController", bundle: nil)

         let selectedActivity = activities[0]
         destinationVC.selectedActivity = selectedActivity
         if let modalData = dataStore.smallmodal.first(where: { $0.title == selectedActivity.name }) {
             destinationVC.modalData = modalData
         }
         destinationVC.flowSource = .activitiesForHer
         destinationVC.modalPresentationStyle = .overFullScreen
         present(destinationVC, animated: false)
     }

     private func openLoveNote(_ notification: AppNotification) {
         let alert = UIAlertController(
             title: "Love Note from \(notification.senderName)",
             message: notification.message,
             preferredStyle: .alert
         )

         alert.addAction(UIAlertAction(title: "Close", style: .default))
         present(alert, animated: true)
     }

     private func openMoodUpdate(_ notification: AppNotification) {
         let alert = UIAlertController(
             title: "Mood Update",
             message: notification.message,
             preferredStyle: .alert
         )

         alert.addAction(UIAlertAction(title: "Got it", style: .default))
         present(alert, animated: true)
     }
 }

 extension NotificationViewController: UICollectionViewDataSource, UICollectionViewDelegate {

     func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
         return notifications.count
     }

     func collectionView(
         _ collectionView: UICollectionView,
         cellForItemAt indexPath: IndexPath
     ) -> UICollectionViewCell {

         let cell = collectionView.dequeueReusableCell(
             withReuseIdentifier: "Notification",
             for: indexPath
         ) as! Notification1CollectionViewCell

         cell.configure(with: notifications[indexPath.item])
         return cell
     }

     func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

         let notification = notifications[indexPath.item]

         // Visual feedback
         collectionView.deselectItem(at: indexPath, animated: true)

         // marked as read
         DataStore.shared.markNotificationAsRead(id: notification.id)

         // Handle tap
         handleNotificationTap(notification)
     }
 }
