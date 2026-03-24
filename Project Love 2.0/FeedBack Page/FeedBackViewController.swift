//
//  FeedBackViewController.swift
//  Project Love 2.0
//
//  Created by SDC-USER on 15/12/25.
//

import UIKit


class FeedBackViewController: UIViewController, UITextViewDelegate {
    
    var feedbackItem: FeedBackGiven?
    var flowSource: ActivityFlowSource?
    var activity: Activity?
    var bondName: String?
    var selectedActivityIndex: Int?
    weak var bondDelegate: BondActivityCompletionDelegate?
    private var selectedFeedbackTags = Set<String>()

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var moodButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet var optionButtons: [UIButton]!
    @IBOutlet var question1: UILabel!
    @IBOutlet var question2: UILabel!
    @IBOutlet var messageView: UIView!
    @IBOutlet var backgroundView: UIView!
    
    private let placeholderText = "Type here..."
    
    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        let image = UIImage(
            systemName: "chevron.left",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 17, weight: .medium)
        )
        button.setImage(image, for: .normal)
        button.tintColor = .black
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        optionButtons.forEach { button in
            button.layer.cornerRadius = 17
        }
        
        backgroundView.layer.cornerRadius = 14
        
        messageTextView.layer.cornerRadius = 12
        messageTextView.layer.masksToBounds = true
        messageTextView.delegate = self
        messageTextView.text = placeholderText
        messageTextView.textColor = .placeholderText
        messageTextView.backgroundColor = .clear
        
        messageView.layer.cornerRadius = 14
        messageView.layer.borderWidth = 1
        messageView.layer.borderColor = UIColor.systemGray4.cgColor
        messageView.layer.masksToBounds = true
        
        doneButton.configuration = .glass()
        doneButton.setTitle("Done", for: .normal)
        
        setupBackButton()
        backButton.configuration = .glass()
        
        titleLabel.text = feedbackItem?.title
        subtitleLabel.text = feedbackItem?.subTitle
        
        let tapGesture = UITapGestureRecognizer(
                target: self,
                action: #selector(dismissKeyboard)
            )
            tapGesture.cancelsTouchesInView = false
            view.addGestureRecognizer(tapGesture)
        
        if let mood = feedbackItem?.selectedMood {
            moodButton.setTitle("Mood updated: \(mood)", for: .normal)
        } else {
            moodButton.setTitle("Update Mood", for: .normal)
        }
        
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text != placeholderText {
            feedbackItem?.userMessage = textView.text
        }
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == placeholderText {
            textView.text = ""
            textView.textColor = .label
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text = placeholderText
            textView.textColor = .placeholderText
        }
    }
    
    private func setupBackButton() {
        view.addSubview(backButton)
        
        backButton.addTarget(
            self,
            action: #selector(backTapped),
            for: .touchUpInside
        )
        
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 0
            ),
            backButton.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                constant: 16
            ),
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    @objc private func backTapped() {
        dismiss(animated: true)
    }
    @IBAction func doneTapped(_ sender: UIButton) {
        
        if let activity = activity {
               DataStore.shared.markActivityCompleted(activity: activity)

               // Submit feedback to Supabase (dual-user sync)
               if let coupleActivityId = activity.coupleActivityId,
                  let userId = DataStore.shared.currentUserId {
                   let mood = feedbackItem?.selectedMood ?? "None"
                   let message = feedbackItem?.userMessage
                   let tags = Array(selectedFeedbackTags)
                   let score = scoreFromTags(selectedFeedbackTags)

                   Task {
                       do {
                           try await SupabaseManager.shared.submitFeedback(
                               coupleActivityId: coupleActivityId,
                               userId: userId,
                               mood: mood,
                               message: message,
                               feedbackTags: tags,
                               feedbackScore: score
                           )
                           _ = await DataStore.shared.refreshSuggestionsAfterFeedback(
                                      coupleActivityId: coupleActivityId
                                  )
                           print(" Feedback saved for user:", userId)
                       } catch {
                           print(" Failed to save feedback:", error)
                       }
                   }
               }
           }
      
           guard
               let bondName = bondName,
               let completedIndex = selectedActivityIndex,
               let page = DataStore.shared.getBuildYourBondPages(name: bondName)
           else {
               dismissAll()
               return
           }

           DataStore.shared.unlockNextBondActivity(
               bondName: bondName,
               completedIndex: completedIndex
           )

           let isLastActivity = completedIndex == page.activity.count - 1

           if isLastActivity {
               dismissAndShowBadge()
           } else {
               dismissAll()
           }
        
        // Ongoing count
        let ongoingCount = UserDefaults.standard.integer(
            forKey: "ongoingActivityCount"
        )
        let newOngoing = max(0, ongoingCount - 1)
        UserDefaults.standard.set(newOngoing, forKey: "ongoingActivityCount")
        
        // Completed count
        let completedCount = UserDefaults.standard.integer(
            forKey: "completedActivityCount"
        )
        UserDefaults.standard.set(
            completedCount + 1,
            forKey: "completedActivityCount"
        )
        
        // Dismiss screens
        var topVC: UIViewController? = self
        while let presenter = topVC?.presentingViewController {
            topVC = presenter
        }
        topVC?.dismiss(animated: true)
        
    }
    
    @IBAction func updateMoodButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "tell_Mood", bundle: nil)
        let vc = storyboard.instantiateViewController(
            withIdentifier: "TellMoodSelectionViewController"
        ) as! TellMoodSelectionViewController
        
        vc.delegate = self
        vc.selectedIndexPath = nil
        vc.modalPresentationStyle = .pageSheet
        
        present(vc, animated: true)
        
    }
    
    @IBAction func optionTapped(_ sender: UIButton) {
        guard let title = sender.title(for: .normal) else { return }

            sender.isSelected.toggle()
            if sender.isSelected {
                selectedFeedbackTags.insert(title)
            } else {
                selectedFeedbackTags.remove(title)
            }

            let normalBG = UIColor(red: 118/255, green: 118/255, blue: 128/255, alpha: 0.12)
            let selectedBG = UIColor(red: 218/255, green: 214/255, blue: 251/255, alpha: 1.0)
            let purpleText = UIColor(red: 128/255, green: 99/255, blue: 181/255, alpha: 1)
            let blackText = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.70)

            if sender.isSelected {
                sender.backgroundColor = selectedBG
                sender.setTitleColor(blackText, for: .normal)
                sender.setTitleColor(blackText, for: .selected)
            } else {
                sender.backgroundColor = normalBG
                sender.setTitleColor(purpleText, for: .normal)
                sender.setTitleColor(purpleText, for: .selected)
            }
    }
    private func scoreFromTags(_ tags: Set<String>) -> Int {
        var score = 0
        for t in tags {
            switch t {
            case "Loved it": score += 2
            case "Relaxing", "Connecting", "Fun": score += 1
            case "Boring": score -= 1
            case "Not my thing": score -= 2
            default: break
            }
        }
        return score
    }

    
    private func showBadgePopup(from page: BuildYourBondpage) {

        let storyboard = UIStoryboard(name: "BuildYourBond", bundle: nil)

        let vc = storyboard.instantiateViewController(
            withIdentifier: "BadgePopupViewController"
        ) as! BadgePopUPViewController

        vc.data = BadgePopupData(
            title: page.badge,
            subtitle: page.badgesubHeading,
            imageName: page.badgeImageName
        )

        vc.modalPresentationStyle = .overFullScreen

        UIApplication.shared
            .connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
            .first?
            .rootViewController?
            .present(vc, animated: true)
    }
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func dismissAndShowBadge() {
        var rootVC: UIViewController? = self

        while let presenter = rootVC?.presentingViewController {
            rootVC = presenter
        }

        // Dismiss everything first
        rootVC?.dismiss(animated: true) {
            //  Present badge popup after dismissal
            let storyboard = UIStoryboard(
                name: "BuildYourBond",
                bundle: nil
            )

            let badgeVC = storyboard.instantiateViewController(
                withIdentifier: "BadgePopupViewController"
            ) as! BadgePopUPViewController
            
            badgeVC.bondName = self.bondName
            
            badgeVC.modalPresentationStyle = .overFullScreen
            rootVC?.present(badgeVC, animated: false)
        }
    }
    
    private func dismissAll() {
        var topVC: UIViewController? = self
        while let presenter = topVC?.presentingViewController {
            topVC = presenter
        }
        topVC?.dismiss(animated: true)
    }

}
extension FeedBackViewController: TellMoodSelectionDelegate {
    func didSelectMood(_ mood: MoodCheckIn, at indexPath: IndexPath) {
        feedbackItem?.selectedMood = mood.label
        moodButton.setTitle("Mood updated: \(mood.label)", for: .normal)
        
        Task {
            do {
                try await SupabaseManager.shared.updateUserMood(moodTitle: mood.moodLabel)
            } catch {
            }
        }
    }
}
    
protocol BondActivityCompletionDelegate: AnyObject {
    func didCompleteBondActivity()
}






