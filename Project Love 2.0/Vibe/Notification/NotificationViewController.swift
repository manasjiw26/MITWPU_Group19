
import UIKit
import Supabase

final class NotificationViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
  
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
         collectionView.register(
             UINib(nibName: "EmptyStateLoveNoteCollectionViewCell", bundle: nil),
             forCellWithReuseIdentifier: "lovenote_empty_cell"
         )

         collectionView.delegate = self
         collectionView.dataSource = self
         collectionView.setCollectionViewLayout(generateLayout(), animated: false)
     }

     private func generateLayout() -> UICollectionViewLayout {
         let layout = UICollectionViewCompositionalLayout { [weak self] section, env in
             guard let self = self else { return nil }

             if self.notifications.isEmpty {
                 let itemSize = NSCollectionLayoutSize(
                     widthDimension: .fractionalWidth(1.0),
                     heightDimension: .absolute(400)
                 )
                 let item = NSCollectionLayoutItem(layoutSize: itemSize)
                 let groupSize = NSCollectionLayoutSize(
                     widthDimension: .fractionalWidth(1.0),
                     heightDimension: .absolute(400)
                 )
                 let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
                 let section = NSCollectionLayoutSection(group: group)
                 section.contentInsets = NSDirectionalEdgeInsets(top: 40, leading: 16, bottom: 40, trailing: 16)
                 return section
             }

             let itemSize = NSCollectionLayoutSize(
                 widthDimension: .fractionalWidth(1.0),
                 heightDimension: .estimated(100)
             )
             let item = NSCollectionLayoutItem(layoutSize: itemSize)
             let groupSize = NSCollectionLayoutSize(
                 widthDimension: .fractionalWidth(1.0),
                 heightDimension: .estimated(100)
             )
             let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
             let section = NSCollectionLayoutSection(group: group)
             section.interGroupSpacing = 16
             return section
         }
         return layout
     }

    private func loadNotifications() {
        Task { @MainActor in
            do {
                let session = try await SupabaseManager.shared.client.auth.session
                let userId = session.user.id
                print("📥 Loading notifications for user: \(userId)")

                notifications = try await NotificationService.shared.fetchNotifications(for: userId)
                print("📥 Loaded \(notifications.count) notifications")
                collectionView.setCollectionViewLayout(generateLayout(), animated: false)
                collectionView.reloadData()
            } catch {
                print("❌ Failed to load notifications: \(error)")
                print("❌ Error details: \(String(describing: error))")
            }
        }
    }

     private func handleNotificationTap(_ notification: AppNotification) {
         switch notification.type {
         case .memoryAdded: openMemory(notification)
         case .activityStarted: openActivity(notification)
         case .loveNoteSent: openLoveNote(notification)
         case .moodUpdated: openMoodUpdate(notification)
         }

     }

    private func openMemory(_ notification: AppNotification) {
        NotificationCenter.default.post(name: NSNotification.Name("OpenMemory"), object: 0)
     }

    private func openActivity(_ notification: AppNotification) {
        guard
            let activityName = extractActivityName(from: notification.message),
            let selectedActivity = findActivity(named: activityName)
        else {
            print("Could not resolve activity from notification: \(notification.message)")
            return
        }

        let destinationVC = SmallModalViewController(nibName: "SmallModalViewController", bundle: nil)
        destinationVC.selectedActivity = selectedActivity
        destinationVC.modalData = DataStore.shared.getSmallModalData(for: selectedActivity)
        destinationVC.flowSource = .explore
        destinationVC.modalPresentationStyle = .overFullScreen
        present(destinationVC, animated: false)
    }
    private func extractActivityName(from message: String) -> String? {
        let prefix = "Your partner started an activity:"
        var candidate = message

        if let range = candidate.range(of: prefix) {
            candidate = String(candidate[range.upperBound...])
        } else if let colonIndex = candidate.firstIndex(of: ":") {
            candidate = String(candidate[candidate.index(after: colonIndex)...])
        }

        candidate = candidate.replacingOccurrences(of: "💫", with: "")
        candidate = candidate.trimmingCharacters(
            in: CharacterSet.whitespacesAndNewlines.union(.punctuationCharacters)
        )

        return candidate.isEmpty ? nil : candidate
    }

    private func findActivity(named name: String) -> Activity? {
        let target = name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let store = DataStore.shared

        let knownActivities =
            store.getActivities() +
            store.getSuggestedActivities() +
            store.allSuggestedPool +
            store.bondpage.flatMap { $0.activity }

        return knownActivities.first {
            $0.name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == target
        }
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
         return notifications.isEmpty ? 1 : notifications.count
     }

     func collectionView(
         _ collectionView: UICollectionView,
         cellForItemAt indexPath: IndexPath
     ) -> UICollectionViewCell {

         if notifications.isEmpty {
             let cell = collectionView.dequeueReusableCell(
                 withReuseIdentifier: "lovenote_empty_cell",
                 for: indexPath
             ) as! EmptyStateLoveNoteCollectionViewCell
             cell.configure(
                 title: "You’re all caught up!",
                 subtitle: "Recent activities from your partner will appear here",
                 imageName: "empty_notification"
             )
             return cell
         }

         let cell = collectionView.dequeueReusableCell(
             withReuseIdentifier: "Notification",
             for: indexPath
         ) as! Notification1CollectionViewCell

         cell.configure(with: notifications[indexPath.item])
         return cell
     }
     func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
         guard !notifications.isEmpty else { return }
         var notification = notifications[indexPath.item]
         collectionView.deselectItem(at: indexPath, animated: true)

         Task { @MainActor in
             do {
                 try await NotificationService.shared.markAsRead(notificationId: notification.id)
                 notification.isRead = true
                 notifications[indexPath.item] = notification
                 collectionView.reloadItems(at: [indexPath])
             } catch {
                 print("Failed to mark notification as read: \(error)")
             }
         }

         handleNotificationTap(notification)
     }

 }
