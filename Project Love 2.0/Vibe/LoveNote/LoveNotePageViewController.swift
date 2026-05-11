//
//  LoveNotePageViewController.swift
//  Project Love 2.0
//

import UIKit
import Supabase

class LoveNotePageViewController: UIViewController {

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var sectionTitleLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!

    @IBOutlet weak var addButton: UIBarButtonItem!
    private var didSetLayout = false
    private var allNotes: [LoveNote] = []
    private var filteredNotes: [LoveNote] = []
    private var refreshTimer: Timer?
    private var currentUserId: UUID?
    private var currentRelationshipId: UUID?
    private var partnerUserId: UUID?

    override func viewDidLoad() {
        super.viewDidLoad()
      
        setupCollectionView()

        segmentedControl.selectedSegmentIndex = 0
        sectionTitleLabel.text = "Sent"

        applyFilter()
        
        Task {
            guard await loadLoveNoteContext() else { return }
            await fetchLoveNotes()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if !didSetLayout {
            collectionView.collectionViewLayout = generateLayout()
            didSetLayout = true
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startAutoRefresh()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopAutoRefresh()
    }
    private func startAutoRefresh() {
        stopAutoRefresh()
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            Task { await self?.fetchLoveNotes() }
        }
        if let refreshTimer {
            RunLoop.main.add(refreshTimer, forMode: .common)
        }
    }

    private func stopAutoRefresh() {
        refreshTimer?.invalidate()
        refreshTimer = nil
    }

    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self

        let nib = UINib(nibName: "LoveNoteCardCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "LoveNoteCardCell")
        
        let nib1 = UINib(nibName: "EmptyStateLoveNoteCollectionViewCell", bundle: nil)
        collectionView.register(nib1, forCellWithReuseIdentifier: "lovenote_empty_cell")
    }


    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        applyFilter()
    }

    private func isEmptyState() -> Bool {
        return filteredNotes.isEmpty
    }
    private func fetchLoveNotes() async {
            guard let currentRelationshipId, let currentUserId else { return }
            do {
                await markDueScheduledNotesAsSent(relationshipId: currentRelationshipId, currentUserId: currentUserId)

                let nowISO = Date().ISO8601Format()
                // Fetch notes that are:
                // 1. Already sent (is_sent=true) — visible to both
                // 2. Still scheduled (is_sent=false) AND I am the sender — sender sees their own pending notes
                // 3. Overdue (scheduled_for <= now, is_sent=false) — partner sees them immediately even
                //    if the flag hasn't been flipped yet
                let rows: [DBLoveNote] = try await SupabaseManager.shared.client
                    .from("love_notes")
                    .select()
                    .eq("relationship_id", value: currentRelationshipId.uuidString)
                    .or("is_sent.eq.true,and(is_sent.eq.false,user_id.eq.\(currentUserId.uuidString)),and(is_sent.eq.false,scheduled_for.lte.\(nowISO))")
                    .order("created_at", ascending: false)
                    .execute()
                    .value

                allNotes = rows.map { LoveNote.fromDB($0, currentUserId: currentUserId) }
                applyFilter()
            } catch {
            }
        }

        private func markDueScheduledNotesAsSent(relationshipId: UUID, currentUserId: UUID) async {
            do {
                // Either device can flip is_sent = true for overdue notes.
                // sendDirectNotification uses note.user_id → note.partner_user_id
                // so the notification always goes to the correct receiver.
                let updatedNotes: [DBLoveNote] = try await SupabaseManager.shared.client
                    .from("love_notes")
                    .update(["is_sent": true])
                    .eq("relationship_id", value: relationshipId.uuidString)
                    .eq("is_sent", value: false)
                    .lte("scheduled_for", value: Date().ISO8601Format())
                    .not("scheduled_for", operator: .is, value: "null")
                    .select()
                    .execute()
                    .value

                for note in updatedNotes {
                    do {
                        // Use sendDirectNotification with known sender/receiver from the note
                        try await NotificationService.shared.sendDirectNotification(
                            relationshipId: relationshipId,
                            senderUserId: note.user_id,
                            receiverUserId: note.partner_user_id,
                            type: "love_note_sent",
                            message: "Your partner sent you a love note 💌",
                            entityType: "love_note",
                            entityId: note.love_note_id.uuidString
                        )
                    } catch {
                        print("DEBUG markDueScheduled notification error: \(error)")
                    }
                }
    } catch {
    }
    }
    private func applyFilter() {
            let notes = allNotes

            switch segmentedControl.selectedSegmentIndex {
            case 0:
                filteredNotes = notes.filter { $0.status == .sent }
                sectionTitleLabel.text = "Sent"

            case 1:
                filteredNotes = notes.filter { $0.status == .received }
                sectionTitleLabel.text = "Received"

            case 2:
                filteredNotes = notes.filter { $0.status == .scheduled }
                sectionTitleLabel.text = "Scheduled"

            default:
                filteredNotes = []
            }

            collectionView.setCollectionViewLayout(generateLayout(), animated: false)
            collectionView.reloadData()
        }

    override func viewWillAppear(_ animated: Bool) {
        collectionView.reloadData()
        Task {
            guard await loadLoveNoteContext() else { return }
            await fetchLoveNotes()
        }
    }
    
    @IBAction func addButtonTapped(_ sender: Any) {
        presentLoveNotePopup()
    }

    private func presentLoveNotePopup() {
        let storyboard = UIStoryboard(name: "LoveNote", bundle: nil)

        let vc = storyboard.instantiateViewController(
            withIdentifier: "LoveNoteViewController"
        ) as! LoveNoteViewController

 
        vc.onSave = { [weak self] message, scheduledDate in
            Task { await self?.createLoveNote(message: message, scheduledDate: scheduledDate) }
        }

        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve

        present(vc, animated: true)
    }
    
    private func createLoveNote(message: String, scheduledDate: Date?) async {

            guard let currentRelationshipId,
                  let partnerUserId else {
                return
            }

            do {
                let session = try await SupabaseManager.shared.client.auth.session
                let authUserId = session.user.id


                let payload = LoveNoteInsert(
                    relationship_id: currentRelationshipId,
                    user_id: authUserId,
                    partner_user_id: partnerUserId,
                    message: message,
                    scheduled_for: scheduledDate,
                    is_sent: (scheduledDate == nil)
                )


                let insertedNotes: [DBLoveNote] = try await SupabaseManager.shared.client
                    .from("love_notes")
                    .insert(payload)
                    .select()
                    .execute()
                    .value


                if scheduledDate == nil { // send notification only for immediate send
                    do {
                        let loveNoteIdString = insertedNotes.first?.love_note_id.uuidString
                        // Use sendDirectNotification with explicit sender/receiver
                        try await NotificationService.shared.sendDirectNotification(
                            relationshipId: currentRelationshipId,
                            senderUserId: authUserId,
                            receiverUserId: partnerUserId,
                            type: "love_note_sent",
                            message: "Your partner sent you a love note 💌",
                            entityType: "love_note",
                            entityId: loveNoteIdString
                        )
                    } catch {
                        print("DEBUG createLoveNote notification error: \(error)")
                    }
                }

                await fetchLoveNotes()


            } catch {
            }
        }
    
    private func loadLoveNoteContext() async -> Bool {
        do {
            let session = try await SupabaseManager.shared.client.auth.session
            let authUserId = session.user.id

            // Get the relationship where logged-in user is either user1 or user2
            let rows: [DBRelationship] = try await SupabaseManager.shared.client
                .from("relationships")
                .select()
                .or("user1_id.eq.\(authUserId.uuidString),user2_id.eq.\(authUserId.uuidString)")
                .eq("status", value: "active") // remove if you don't use status filtering
                .limit(1)
                .execute()
                .value

            guard let relationship = rows.first else { return false }

            currentUserId = authUserId
            currentRelationshipId = relationship.relationship_id
            partnerUserId = (relationship.user1_id == authUserId) ? relationship.user2_id : relationship.user1_id
            return true
        } catch {
            return false
        }
    }

    
    private func generateLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] section, env in
            guard let self = self else { return nil }

            if self.isEmptyState() {
                // Large centered empty state cell
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

            // Normal love note card layout
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(120)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(120)
            )
            let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])

            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 12, bottom: 12, trailing: 12)
            section.interGroupSpacing = 16
            return section
        }
        return layout
    }
}

extension LoveNotePageViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredNotes.isEmpty ? 1 : filteredNotes.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {

        if filteredNotes.isEmpty {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "lovenote_empty_cell",
                for: indexPath
            ) as! EmptyStateLoveNoteCollectionViewCell
            switch segmentedControl.selectedSegmentIndex {
            case 0:
                cell.configure(
                    title: "No love notes sent yet",
                    subtitle: "Send your partner a sweet note to make their day.",
                    imageName: "empty_lovenote_send"
                )
            case 1:
                cell.configure(
                    title: "Nothing received yet",
                    subtitle: "When your partner sends a love note, it will appear here.",
                    imageName: "empty_lovenote_receive"
                )
            case 2:
                cell.configure(
                    title: "No scheduled notes",
                    subtitle: "Plan a surprise love note for the future.",
                    imageName: "empty_lovenote_schedule"
                )
            default:
                break
            }
            return cell
        }

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "LoveNoteCardCell",
            for: indexPath
        ) as! LoveNoteCardCell

        cell.configure(with: filteredNotes[indexPath.item])
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        guard !filteredNotes.isEmpty else { return }
        let selectedNote = filteredNotes[indexPath.item]
        
        let storyboard = UIStoryboard(name: "LoveNote", bundle: nil)
        let vc = storyboard.instantiateViewController(
            withIdentifier: "LoveNoteDetailVC"
        ) as! LoveNoteDetail2ViewController
        
        
        vc.note = selectedNote
        vc.onDismiss = { [weak self] in
                self?.applyFilter()
            }
        
        vc.modalPresentationStyle = .pageSheet
        vc.onReact = { [weak self] noteId, emoji in
            Task { await self?.updateReaction(noteId: noteId, emoji: emoji) }
        }
        vc.onReschedule = { [weak self] noteId, date in
            Task { await self?.updateSchedule(noteId: noteId, date: date) }
        }
        present(vc, animated: true)
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

            // Send a notification to the original sender that their note got a reaction
            if let currentRelationshipId = currentRelationshipId {
                try await NotificationService.shared.sendPartnerNotification(
                    relationshipId: currentRelationshipId,
                    type: "love_tip_reacted",
                    message: "Your partner reacted \(emoji) to your love note 💌",
                    entityType: "love_note",
                    entityId: noteId.uuidString
                )
            }

            await fetchLoveNotes()
        } catch {
        }
    }

    private func updateSchedule(noteId: UUID, date: Date) async {
        guard date > Date() else {
            return
        }

        do {
            try await SupabaseManager.shared.client
                .from("love_notes")
                .update(LoveNoteScheduleUpdate(
                    scheduled_for: date.ISO8601Format(),
                    is_sent: false
                ))
                .eq("love_note_id", value: noteId.uuidString)
                .execute()
            await fetchLoveNotes()
        } catch {
        }
    }

}


  








