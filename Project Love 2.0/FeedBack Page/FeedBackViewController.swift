//
//  FeedBackViewController.swift
//  Project Love 2.0
//
//  Created by SDC-USER on 15/12/25.
//

import UIKit


class FeedBackViewController: UIViewController {
    var feedbackItem: FeedBackGiven!
    var flowSource: ActivityFlowSource?

    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var moodButton: UIButton!
    @IBOutlet weak var moodLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    
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
        
        messageTextField.addTarget(
            self,
            action: #selector(textDidChange),
            for: .editingChanged
        )
        messageTextField.layer.cornerRadius = 12
        messageTextField.layer.masksToBounds = true
        moodLabel.layer.cornerRadius = 8
        moodLabel.layer.masksToBounds = true
        doneButton.configuration = .glass()
        doneButton.setTitle("Done", for: .normal)
        setupBackButton()
        backButton.configuration = .glass()
        titleLabel.text = feedbackItem.title
        subtitleLabel.text = feedbackItem.subTitle
        moodButton.setTitle(
            feedbackItem.selectedMood ?? "Update Mood",
            for: .normal
        )
        
    }
    @objc private func textDidChange() {
        feedbackItem.userMessage = messageTextField.text
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
        // Save feedback
            DataStore.shared.saveFeedback(feedbackItem)

            // Mark activity completed
            DataStore.shared.markActivityCompleted(
                activityName: feedbackItem.title
            )

            // 🔽 Ongoing count
            let ongoingCount = UserDefaults.standard.integer(
                forKey: "ongoingActivityCount"
            )
            let newOngoing = max(0, ongoingCount - 1)
            UserDefaults.standard.set(newOngoing, forKey: "ongoingActivityCount")

            // 🔼 Completed count
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
        
//        vc.screenTitle1 = "Update your mood"
        vc.delegate = self
        vc.selectedIndexPath = nil
        vc.modalPresentationStyle = .fullScreen
        
        present(vc, animated: true)
        
    }
}
extension FeedBackViewController: TellMoodSelectionDelegate {
    func didSelectMood(_ mood: MoodCheckIn, at indexPath: IndexPath) {
        feedbackItem.selectedMood = mood.label
        moodButton.setTitle(mood.label, for: .normal)
    }
    }
    





