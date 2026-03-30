//
//  InfoModalViewController.swift
//  Project Love 2.0
//
//  Created by SDC-USER on 26/03/26.
//

import UIKit
import Supabase

protocol InfoModalDelegate: AnyObject {
    func didTapLetsDoThis(for activity: Activity)
}

class InfoModalViewController: UIViewController {

    var activity: Activity?
    weak var delegate: InfoModalDelegate?
    
    @IBOutlet weak var modalView: UIView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var mainImage: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var letsDoThisButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.bringSubviewToFront(modalView)
        
        // Configure close button
        closeButton.configuration = .glass()
        closeButton.setImage(
            UIImage(
                systemName: "xmark",
                withConfiguration: UIImage.SymbolConfiguration(weight: .medium)
            ),
            for: .normal
        )

        // Configure action button
        letsDoThisButton.configuration = .glass()
        letsDoThisButton.setTitle("Let's do this", for: .normal)

        // Populate data
        if let activity = activity {
            mainImage.image = UIImage(named: activity.image)
            // Simplify title: strip everything after colon (e.g., "Love Note: Quick Send" → "Love Note")
            let fullName = activity.name
            if let colonRange = fullName.range(of: ":") {
                titleLabel.text = String(fullName[fullName.startIndex..<colonRange.lowerBound]).trimmingCharacters(in: .whitespaces)
            } else {
                titleLabel.text = fullName
            }
            descriptionLabel.text = activity.modalDescription ?? activity.description
            locationLabel.text = activity.location ?? "Explore"
        }

        // Dim background
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)

        // Modal container styling
        modalView.backgroundColor = .white
        modalView.layer.cornerRadius = 40
        modalView.layer.masksToBounds = true

        view.addSubview(modalView)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = .clear
        modalView.transform = CGAffineTransform(translationX: 0, y: 400)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.3, animations: {
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
            self.modalView.transform = .identity
        })
    }

    @IBAction func closeButtonTapped(_ sender: Any) {
        UIView.animate(withDuration: 0.25, animations: {
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0)
            self.modalView.transform = CGAffineTransform(translationX: 0, y: 400)
        }) { _ in
            self.dismiss(animated: true)
        }
    }

    @IBAction func letsDoThisButtonTapped(_ sender: Any) {
        let activityToRemove = activity
        let presentingVC = self.presentingViewController
        let delegateToNotify = self.delegate
        
        UIView.animate(withDuration: 0.25, animations: {
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0)
            self.modalView.transform = CGAffineTransform(translationX: 0, y: 400)
        }) { _ in
            self.dismiss(animated: true) {
                if let activity = activityToRemove {
                    
                    let completeActivity = {
                        DispatchQueue.main.async {
                            delegateToNotify?.didTapLetsDoThis(for: activity)
                        }
                    }
                    
                    if activity.name.lowercased().hasPrefix("love note") {
                        let storyboard = UIStoryboard(name: "LoveNote", bundle: nil)
                        let vc = storyboard.instantiateViewController(
                            withIdentifier: "LoveNoteViewController"
                        ) as! LoveNoteViewController
                        vc.modalPresentationStyle = .overFullScreen
                        vc.modalTransitionStyle = .crossDissolve
                        
                        vc.onSave = { message, scheduledDate in
                            guard let relationshipId = DataStore.shared.currentRelationshipId,
                                  let partnerId = DataStore.shared.partnerUserId,
                                  let userId = DataStore.shared.currentUserId else { return }
                            
                            Task {
                                do {
                                    let payload = LoveNoteInsert(
                                        relationship_id: relationshipId,
                                        user_id: userId,
                                        partner_user_id: partnerId,
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
                                    
                                    if scheduledDate == nil {
                                        do {
                                            let loveNoteIdString = insertedNotes.first?.love_note_id.uuidString
                                            try await NotificationService.shared.sendPartnerNotification(
                                                relationshipId: relationshipId,
                                                type: "love_note_sent",
                                                message: "Your partner sent you a love note 💌",
                                                entityType: "love_note",
                                                entityId: loveNoteIdString
                                            )
                                        } catch {}
                                    }
                                    
                                    completeActivity()
                                } catch {
                                    print("Failed to save love note from InfoModalViewController: \(error)")
                                }
                            }
                        }
                        
                        presentingVC?.present(vc, animated: true)
                    } else if activity.name.lowercased().hasPrefix("memory jar") {
                        let storyboard = UIStoryboard(name: "MemoryJar", bundle: nil)
                        let vc = storyboard.instantiateViewController(
                            withIdentifier: "AddMemoryViewController"
                        ) as! NewAddNewViewController
                        vc.modalPresentationStyle = .fullScreen
                        vc.onMemorySaved = {
                            completeActivity()
                        }
                        presentingVC?.present(vc, animated: true)
                    } else if activity.name.lowercased().hasPrefix("love tips") {
                        let storyboard = UIStoryboard(name: "LoveTips", bundle: nil)
                        let vc = storyboard.instantiateViewController(
                            withIdentifier: "LoveTipsVC"
                        ) as! LoveTipsViewController
                        vc.delegate = self.delegate as? LoveTipsSelectionDelegate
                        vc.onTipsSaved = {
                            completeActivity()
                        }
                        if let sheet = vc.sheetPresentationController {
                            sheet.detents = [.medium(), .large()]
                            sheet.prefersGrabberVisible = true
                            sheet.selectedDetentIdentifier = .medium
                        }
                        presentingVC?.present(vc, animated: true)
                    } else if activity.name.lowercased().hasPrefix("nudge") {
                        let storyboard = UIStoryboard(name: "NudgesModal", bundle: nil)
                        let vc = storyboard.instantiateViewController(
                            withIdentifier: "NudgesModalVC"
                        ) as! NudgesModalViewController
                        vc.rewards = DataStore.shared.rewards
                        vc.onNudgeSent = {
                            completeActivity()
                        }
                        if let sheet = vc.sheetPresentationController {
                            sheet.detents = [.custom { _ in return 180 }]
                            sheet.prefersGrabberVisible = true
                        }
                        presentingVC?.present(vc, animated: true)
                    } else {
                        // Note: non-special activities are completed immediately
                        completeActivity()
                    }
                }
            }
        }
    }
}
