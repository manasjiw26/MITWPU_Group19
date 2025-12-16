//
//  FeedBackViewController.swift
//  Project Love 2.0
//
//  Created by SDC-USER on 15/12/25.
//

import UIKit

class FeedBackViewController: UIViewController {
    var feedbackItem: FeedBackGiven!

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
        feedbackItem.selectedMood ?? "Calm",
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
        guard
               let message = feedbackItem.userMessage, !message.isEmpty,
               let mood = feedbackItem.selectedMood
           else {
               return
           }

           DataStore.shared.saveFeedback(feedbackItem)

           if let nav = navigationController {
               nav.popViewController(animated: true)
           } else {
               dismiss(animated: true)
           }

    }


   
}
