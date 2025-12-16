// // StepsViewController.swift
// Project Love 2.0 //
// Created by SDC-USER on 11/12/25. //


import UIKit

class StepsViewController: UIViewController {
    
    var steps: [StepsToFollow] = []
    var activitytitle: String = ""
    
    @IBOutlet weak var activityTitle: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var stepsTable: UITableView!
    @IBOutlet weak var tableHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var tableBackgroundCell: UIView!
    @IBOutlet weak var combinedLabel: UILabel!
    //back button
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
        steps = DataStore.shared.loadSteps(for: activitytitle)
        stepsTable.reloadData()
        setupBackButton()
        backButton.configuration = .glass()
        stepsTable.allowsSelection = false
        stepsTable.tableFooterView = UIView()
        continueButton.configuration = .glass()
        continueButton.setTitle("Continue", for: .normal)
        
        tableBackgroundCell.layer.cornerRadius = 20
        stepsTable.dataSource = self
        stepsTable.delegate = self
        stepsTable.isScrollEnabled = false
        stepsTable.rowHeight = UITableView.automaticDimension
        stepsTable.estimatedRowHeight = 200
        
        activityTitle.text = activitytitle
        subtitle.text = "Set the Scene with these steps"
        
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        stepsTable.layoutIfNeeded()
        tableHeightConstraint.constant = stepsTable.contentSize.height
    }
    
    @IBAction func continueButton(_ sender: Any) {
        //self.dismiss(animated: true, completion: nil)
        let storyboard = UIStoryboard(name: "feedBack", bundle: nil)
        let feedbackVC = storyboard.instantiateViewController(
            withIdentifier: "FeedBackViewController"
        ) as! FeedBackViewController
        
       
        let feedbackItem = FeedBackGiven(
            title: activitytitle,   
            subTitle: "How did that activity make you feel?",
            imageName: "camera",
            userMessage: nil,
            selectedMood: nil
        )

       
        feedbackVC.feedbackItem = feedbackItem
        
        feedbackVC.modalPresentationStyle = .fullScreen
        present(feedbackVC, animated: true)
    }
}


    extension StepsViewController: UITableViewDataSource, UITableViewDelegate {
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return steps.count
        }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

            let cell = tableView.dequeueReusableCell(withIdentifier: "StepCell", for: indexPath) as! StepsTableViewCell
            let step = steps[indexPath.row]

            let fullText = NSMutableAttributedString()

            // 1. Number
            let numberText = NSAttributedString(
                string: "\(step.number). ",
                attributes: [
                    .font: UIFont.systemFont(ofSize: 16, weight: .semibold)
                ]
            )

            // 2. Bold Title
            let titleText = NSAttributedString(
                string: "\(step.title): ",
                attributes: [
                    .font: UIFont.systemFont(ofSize: 16, weight: .semibold)
                ]
            )

            // 3. Description (regular)
            let descText = NSAttributedString(
                string: step.descriptionLabel,
                attributes: [
                    .font: UIFont.systemFont(ofSize: 16, weight: .regular),
                    .foregroundColor: UIColor.darkGray
                ]
            )

            // Combine them
            fullText.append(numberText)
            fullText.append(titleText)
            fullText.append(descText)

            // Set final text
            cell.stepLabel.attributedText = fullText
            cell.stepLabel.numberOfLines = 0
            
            let isLastRow = indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1

            if isLastRow {
                cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
            } else {
                cell.separatorInset = .zero   // or whatever inset you want
            }


            return cell
        }
       

    }

    


