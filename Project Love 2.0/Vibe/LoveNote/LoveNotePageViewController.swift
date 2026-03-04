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
    }


    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        print("Segment changed to:", sender.selectedSegmentIndex)
        applyFilter()
    }
    private func fetchLoveNotes() async {
        guard let currentRelationshipId, let currentUserId else { return }
        do {
            await markDueScheduledNotesAsSent(relationshipId: currentRelationshipId)

            let rows: [DBLoveNote] = try await SupabaseManager.shared.client
                .from("love_notes")
                .select()
                .eq("relationship_id", value: currentRelationshipId.uuidString)
                .or("is_sent.eq.true,and(is_sent.eq.false,sender_user_id.eq.\(currentUserId.uuidString))")
                .order("created_at", ascending: false)
                .execute()
                .value

            let visibleRows = rows.filter { $0.is_sent || $0.sender_user_id == currentUserId }
            allNotes = visibleRows.map { LoveNote.fromDB($0, currentUserId: currentUserId) }
            applyFilter()
        } catch {
            print("fetchLoveNotes error:", error)
        }
    }

    private func markDueScheduledNotesAsSent(relationshipId: UUID) async {
        do {
            try await SupabaseManager.shared.client
                .from("love_notes")
                .update(["is_sent": true])
                .eq("relationship_id", value: relationshipId.uuidString)
                .eq("is_sent", value: false)
                .lte("scheduled_for", value: Date().ISO8601Format())
                .execute()
        } catch {
            print("markDueScheduledNotesAsSent error:", error)
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
            print("❌ relationship or partner missing")
            return
        }

        do {
            let session = try await SupabaseManager.shared.client.auth.session
            let authUserId = session.user.id

            print("Current user ID:", authUserId)
            print("Relationship ID:", currentRelationshipId)
            print("Receiver ID:", partnerUserId)

            let payload = LoveNoteInsert(
                relationship_id: currentRelationshipId,
                sender_user_id: authUserId,
                receiver_user_id: partnerUserId,
                message: message,
                scheduled_for: scheduledDate,
                is_sent: (scheduledDate == nil)
            )

            print("🚀 Attempting insert...")

            try await SupabaseManager.shared.client
                .from("love_notes")
                .insert(payload)
                .execute()

            print("✅ Insert success")

            if scheduledDate == nil { // send notification only for immediate send
                do {
                    try await NotificationService.shared.sendPartnerNotification(
                        relationshipId: currentRelationshipId,
                        type: "love_note_sent",
                        message: "Your partner sent you a love note 💌",
                        entityType: "love_note",
                        entityId: nil
                    )
                } catch {
                    print("Notification insert failed: \(error)")
                }
            }

            await fetchLoveNotes()


        } catch {
            print("🔥 createLoveNote error:", error)
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
            print("loadLoveNoteContext error:", error)
            return false
        }
    }

    
    private func generateLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 8, left: 12, bottom: 12, right: 12)
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        return layout
    }
}

extension LoveNotePageViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        filteredNotes.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "LoveNoteCardCell",
            for: indexPath
        ) as! LoveNoteCardCell

        cell.configure(with: filteredNotes[indexPath.item])
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        
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
            await fetchLoveNotes()
        } catch {
            print("updateReaction error:", error)
        }
    }

    private func updateSchedule(noteId: UUID, date: Date) async {
        guard date > Date() else {
            print("Cannot schedule in the past")
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
            print("updateSchedule error:", error)
        }
    }

}


  








