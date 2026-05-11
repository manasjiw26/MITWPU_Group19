
import UIKit
import Supabase

final class NotificationViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    private var channel: RealtimeChannelV2?
  
    private var notifications: [AppNotification] = []

     override func viewDidLoad() {
         super.viewDidLoad()
         setupCollectionView()
         loadNotifications()
         subscribeToNotifications()
     }

     deinit {
         if let channel = channel {
             Task { await SupabaseManager.shared.client.removeChannel(channel) }
         }
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

    private func subscribeToNotifications() {
        Task { @MainActor in
            do {
                let session = try await SupabaseManager.shared.client.auth.session
                let userId = session.user.id
                
                let ch = SupabaseManager.shared.client.channel("public:notifications:\(userId.uuidString)")
                self.channel = ch
                
                let insertions = ch.postgresChange(
                    InsertAction.self,
                    schema: "public",
                    table: "notifications",
                    filter: "receiver_user_id=eq.\(userId.uuidString)"
                )
                
                await ch.subscribe()
                
                for await change in insertions {
                    // Refresh the list when a new notification arrives
                    loadNotifications()
                }
            } catch {
                print("Realtime subscription error: \(error)")
            }
        }
    }

    private func loadNotifications() {
        Task { @MainActor in
            do {
                let session = try await SupabaseManager.shared.client.auth.session
                let userId = session.user.id

                notifications = try await NotificationService.shared.fetchNotifications(for: userId)
                collectionView.setCollectionViewLayout(generateLayout(), animated: false)
                collectionView.reloadData()
            } catch {
            }
        }
    }

     private func handleNotificationTap(_ notification: AppNotification) {
         switch notification.type {
         case .memoryAdded: openMemory(notification)
         case .activityStarted: openActivity(notification)
         case .loveNoteSent: openLoveNote(notification)
         case .moodUpdated: openMoodUpdate(notification)
         case .nudgeSent: openNudge(notification)
         case .loveTipCompleted: openLoveTipCompleted(notification)
         case .loveTipReacted: openLoveTipReacted(notification)
         case .feedbackCompleted: openFeedbackCompleted(notification)
         }
     }
    private func openNudge(_ notification: AppNotification) {
        let storyboard = UIStoryboard(name: "Notification", bundle: nil)
        if let rewardVC = storyboard.instantiateViewController(withIdentifier: "BadgePopupViewController") as? RewardNotificationViewController {
            rewardVC.notificationTitle = "Nudge Received!"
            rewardVC.notificationMessage = notification.message
            rewardVC.notificationEmoji = extractEmoji(from: notification.message)
            rewardVC.modalPresentationStyle = .overFullScreen
            rewardVC.modalTransitionStyle = .crossDissolve
            self.present(rewardVC, animated: true)
        } else {
            let alert = UIAlertController(title: "Nudge", message: notification.message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Close", style: .default))
            present(alert, animated: true)
        }
    }

    private func extractEmoji(from message: String) -> String? {
        // Message format: "Sent you a {nudgeType} {emoji}!"
        // Extract the last emoji character from the message
        let scalars = message.unicodeScalars
        for scalar in scalars.reversed() {
            if scalar.properties.isEmoji && scalar.value > 0x7E {
                return String(scalar)
            }
        }
        return nil
    }

    private func openLoveTipCompleted(_ notification: AppNotification) {
        let storyboard = UIStoryboard(name: "LoveNote", bundle: nil)
        guard let detailVC = storyboard.instantiateViewController(withIdentifier: "LoveNoteDetailVC") as? LoveNoteDetail2ViewController else { return }
        
        // Extract tip title
        var tipTitle = notification.message
        if let range = tipTitle.range(of: "Partner completed tip: ") {
            tipTitle = String(tipTitle[range.upperBound...])
        }

        // Mock a LoveNote to use the existing modal
        let mockNote = LoveNote(
            id: UUID(), // We don't have a real UUID
            relationshipId: UUID(),
            senderUserId: notification.id, // Using notification ID to differentiate senders if needed
            receiverUserId: UUID(),
            message: tipTitle,
            createdAt: notification.createdAt,
            scheduledDate: nil,
            reaction: nil,
            reactedAt: nil,
            isSent: false,
            status: .loveTipCompleted, 
            isSender: false
        )

        detailVC.note = mockNote
        detailVC.modalPresentationStyle = .pageSheet
        
        detailVC.onReact = { [weak self] _, emoji in
            self?.reactToTip(emoji: emoji, tipTitle: tipTitle)
        }
        
        present(detailVC, animated: true)
    }

    private func reactToTip(emoji: String, tipTitle: String) {
        Task {
            do {
                let session = try await SupabaseManager.shared.client.auth.session
                let currentUserId = session.user.id
                
                let relationships: [DBRelationship] = try await SupabaseManager.shared.client
                    .from("relationships")
                    .select()
                    .or("user1_id.eq.\(currentUserId),user2_id.eq.\(currentUserId)")
                    .limit(1)
                    .execute()
                    .value
                
                if let relationship = relationships.first {
                    try await NotificationService.shared.sendPartnerNotification(
                        relationshipId: relationship.relationship_id,
                        type: NotificationType.loveTipReacted.rawValue,
                        message: "\(emoji) to '\(tipTitle)'"
                    )
                }
            } catch {
            }
        }
    }

    private func openLoveTipReacted(_ notification: AppNotification) {
        let alert = UIAlertController(
            title: "Reaction Received",
            message: "Your partner reacted \(notification.message)",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Awesome!", style: .default))
        present(alert, animated: true)
    }
    
    private func openMemory(_ notification: AppNotification) {
        guard let memoryId = notification.entityId else {
            showMemoryAlert(for: notification)
            return
        }

        Task { @MainActor in
            do {
                let memory = try await NotificationService.shared.fetchMemory(id: memoryId)

                let storyboard = UIStoryboard(name: "MemoryJar", bundle: nil)
                if let displayVC = storyboard.instantiateViewController(
                    withIdentifier: "memoryDisplay"
                ) as? memoryDisplay {
                    displayVC.memory = memory
                    displayVC.modalPresentationStyle = .pageSheet
                    self.present(displayVC, animated: true)
                }
            } catch {
                showMemoryAlert(for: notification)
            }
        }
    }

    private func showMemoryAlert(for notification: AppNotification) {
        let alert = UIAlertController(
            title: "New Memory",
            message: notification.message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Close", style: .default))
        present(alert, animated: true)
    }

    private func openActivity(_ notification: AppNotification) {
        guard let activityName = extractActivityName(from: notification.message) else {
            return
        }

        let selectedActivity: Activity
        if let found = findActivity(named: activityName) {
            selectedActivity = found
        } else {
            // Fallback: build a minimal Activity so the modal still opens
            // (covers custom activities or activities not yet synced locally)
            selectedActivity = Activity(
                name: activityName,
                description: notification.message,
                image: "Activityimage",
                time: "",
                status: .ongoing,
                category: "Custom"
            )
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

        // Only strip the 💫 emoji and whitespace — do NOT strip punctuation,
        // as activity names may contain &, ', - etc.
        candidate = candidate.replacingOccurrences(of: "💫", with: "")
        candidate = candidate.trimmingCharacters(in: .whitespacesAndNewlines)

        return candidate.isEmpty ? nil : candidate
    }

    private func findActivity(named name: String) -> Activity? {
        let target = name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let store = DataStore.shared

        let knownActivities =
            store.getActivities() +
            store.getSuggestedActivities() +
            store.bondpage.flatMap { $0.activity } +
            store.customActivities

        return knownActivities.first {
            $0.name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == target
        }
    }


     private func openLoveNote(_ notification: AppNotification) {
         guard let noteId = notification.entityId else {
             showLoveNoteAlert(for: notification)
             return
         }

         Task { @MainActor in
             do {
                 let session = try await SupabaseManager.shared.client.auth.session
                 let currentUserId = session.user.id

                 // Fetch the complete LoveNote object
                 let loveNote = try await NotificationService.shared.fetchLoveNote(id: noteId, currentUserId: currentUserId)

                 // Instantiate and present the detail modal
                 let storyboard = UIStoryboard(name: "LoveNote", bundle: nil)
                 if let detailVC = storyboard.instantiateViewController(withIdentifier: "LoveNoteDetailVC") as? LoveNoteDetail2ViewController {
                     detailVC.note = loveNote
                     detailVC.modalPresentationStyle = .pageSheet
                     
                     // Handle reactions and reschedules if necessary
                     detailVC.onReact = { [weak self] noteId, emoji in
                         Task { await self?.updateReaction(noteId: noteId, emoji: emoji) }
                     }
                     detailVC.onReschedule = { [weak self] noteId, date in
                         Task { await self?.updateSchedule(noteId: noteId, date: date) }
                     }

                     self.present(detailVC, animated: true)
                 }

             } catch {
                 showLoveNoteAlert(for: notification)
             }
         }
     }

     private func showLoveNoteAlert(for notification: AppNotification) {
         let alert = UIAlertController(
             title: "Love Note from \(notification.senderName)",
             message: notification.message,
             preferredStyle: .alert
         )

         alert.addAction(UIAlertAction(title: "Close", style: .default))
         present(alert, animated: true)
     }

    private func updateReaction(noteId: UUID, emoji: String) async {
        do {
            try await SupabaseManager.shared.client
                .from("love_notes")
                .update(LoveNoteReactionUpdate(
                    reaction: emoji,
                    reacted_at: Date().ISO8601Format()
                ))
                .eq("love_note_id", value: noteId.uuidString)
                .execute()
        } catch {
        }
    }

    private func updateSchedule(noteId: UUID, date: Date) async {
        guard date > Date() else { return }
        do {
            try await SupabaseManager.shared.client
                .from("love_notes")
                .update(LoveNoteScheduleUpdate(
                    scheduled_for: date.ISO8601Format(),
                    is_sent: false
                ))
                .eq("love_note_id", value: noteId.uuidString)
                .execute()
        } catch {
        }
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

     private func openFeedbackCompleted(_ notification: AppNotification) {
         let alert = UIAlertController(
             title: "Feedback Complete",
             message: notification.message,
             preferredStyle: .alert
         )

         alert.addAction(UIAlertAction(title: "Awesome", style: .default))
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
             }
         }

         handleNotificationTap(notification)
     }

 }
