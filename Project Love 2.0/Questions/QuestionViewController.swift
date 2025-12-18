//
//  QuestionViewController.swift
//  Project Love 2.0
//
//  Created by SDC-USER on 26/11/25.
//

import UIKit
protocol DailyCheckInCompletionDelegate: AnyObject {
    func didCompleteDailyCheckIn()
}

class QuestionViewController: UIViewController, UITableViewDelegate,UITableViewDataSource {
    weak var completionDelegate: DailyCheckInCompletionDelegate?
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questions[currentIndex].options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OptionCell", for: indexPath) as! OptionTableViewCell

           let optionText = questions[currentIndex].options[indexPath.row]
           let isSelected = (selectedIndex == indexPath.row)

           cell.configure(option: optionText, isSelected: isSelected)
        
        cell.contentView.backgroundColor = .white
    
        cell.backgroundColor = .clear

        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOpacity = 0.05
        cell.layer.shadowOffset = CGSize(width: 0, height: 2)
        cell.layer.shadowRadius = 4


           return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        tableView.reloadData()
    }
    
    
    @IBOutlet weak var questionLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    
    @IBOutlet weak var tableHeightConstraints: NSLayoutConstraint!
    
    @IBOutlet weak var nextButton: UIButton!
    
    
    var questions = dataStore.questions
    var currentIndex = 0
    var selectedIndex: Int? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.sectionHeaderHeight = 0
        tableView.sectionFooterHeight = 0
        
        nextButton.configuration = .glass()
        nextButton.setTitle("Next", for: .normal)
        
        updateUI()
    }

    
    func updateUI() {
        let q = questions[currentIndex]
        questionLabel.text = q.title
        selectedIndex = nil
        tableView.reloadData()

        DispatchQueue.main.async {
            self.tableHeightConstraints.constant = self.tableView.contentSize.height
        }

        tableView.layer.cornerRadius = 20
        tableView.layer.masksToBounds = true
        tableView.backgroundColor = .white
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        tableView.layoutIfNeeded()
        tableHeightConstraints.constant = tableView.contentSize.height
    }



    @IBAction func NextPressed(_ sender: Any) {
//        if currentIndex < questions.count - 1 {
//                currentIndex += 1
//                updateUI()
//            }
        guard selectedIndex != nil else { return }

           if currentIndex < questions.count - 1 {
               currentIndex += 1
               updateUI()
           } else {
               // 🔴 THIS IS THE KEY LINE
               completionDelegate?.didCompleteDailyCheckIn()
               dismiss(animated: true)
           }
    }
    
    @IBAction func backButton(_ sender: Any) {
        if currentIndex > 0 {
               currentIndex -= 1
               updateUI()
           } else {
               dismiss(animated: true)
           }
    }
    
}
