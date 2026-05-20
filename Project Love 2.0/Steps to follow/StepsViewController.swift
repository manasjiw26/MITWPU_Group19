// // StepsViewController.swift
// Project Love 2.0 //
// Created by SDC-USER on 11/12/25. //


import UIKit

class StepsViewController: UIViewController {
    
    var steps: [StepsToFollow] = []
    var activitytitle: String = ""
    var flowSource: ActivityFlowSource?
    var activity: Activity?
    var selectedActivityIndex: Int?
    var bondName: String?
    var expandedIndex: Int? = nil
    
    weak var bondDelegate: BondActivityCompletionDelegate?

    @IBOutlet weak var activityTitle: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var stepsTable: UITableView!
    @IBOutlet weak var tableHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableBackgroundCell: UIView!

    @IBOutlet var subtitle1: UILabel!
    
    @IBOutlet weak var combinedLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.hidesBottomBarWhenPushed = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let activity = activity else {
            return
        }

        activitytitle = activity.name
        activityTitle.text = activitytitle
        subtitle.text = "Set the Scene with these steps"

        steps = DataStore.shared.getSteps(for: activity)


        stepsTable.dataSource = self
        stepsTable.delegate = self
        stepsTable.reloadData()

        stepsTable.allowsSelection = true
        stepsTable.separatorStyle = .none
        stepsTable.backgroundColor = .clear
        stepsTable.tableFooterView = UIView()
        stepsTable.isScrollEnabled = false
        stepsTable.rowHeight = UITableView.automaticDimension
        stepsTable.estimatedRowHeight = 200

        continueButton.configuration = .glass()

        // For Build Your Bond: only the final step (4th, index 3) shows "Continue" → feedback
        // Steps 1-3 show "Done" → just dismiss
        if bondName != nil && selectedActivityIndex != nil && selectedActivityIndex! < 3 {
            continueButton.setTitle("Done", for: .normal)
        } else {
            continueButton.setTitle("Continue", for: .normal)
        }

        tableBackgroundCell.layer.cornerRadius = 20
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        stepsTable.layoutIfNeeded()
        tableHeightConstraint.constant = stepsTable.contentSize.height
    }
    
    @IBAction func continueButton(_ sender: Any) {

        // For Build Your Bond intermediate steps (1-3): mark complete and dismiss
        if bondName != nil, let index = selectedActivityIndex, index < 3 {
            if let activity = activity {
                DataStore.shared.markActivityCompleted(activity: activity)
                bondDelegate?.didCompleteBondActivity()
            }
            if let nav = navigationController {
                nav.popViewController(animated: true)
            } else {
                dismiss(animated: true)
            }
            return
        }

        // Final step or regular activity: open feedback
        // For BYB final step, use bondName as the title
        let feedbackTitle = bondName ?? activitytitle

        let storyboard = UIStoryboard(name: "feedBack", bundle: nil)
        let feedbackVC = storyboard.instantiateViewController(
            withIdentifier: "FeedBackViewController"
        ) as! FeedBackViewController

        let feedbackItem = FeedBackGiven(
            title: feedbackTitle,   
            subTitle: "Tell us how this activity made you feel",
            imageName: "camera",
            userMessage: nil,
            selectedMood: nil
        )

        feedbackVC.feedbackItem = feedbackItem
        feedbackVC.activity = activity
        feedbackVC.flowSource = flowSource
        
        feedbackVC.bondName = bondName
        feedbackVC.selectedActivityIndex = selectedActivityIndex
        feedbackVC.bondDelegate = bondDelegate
        
        navigationController?.pushViewController(feedbackVC, animated: true)
    }
}


extension StepsViewController: UITableViewDataSource, UITableViewDelegate {
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return steps.count
        }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "StepCell", for: indexPath) as! StepsTableViewCell
        let step = steps[indexPath.row]
        let isExpanded = (expandedIndex == indexPath.row)

        cell.configure(with: step, isExpanded: isExpanded)
        cell.selectionStyle = .none

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let previous = expandedIndex

        if expandedIndex == indexPath.row {
            expandedIndex = nil
        } else {
            expandedIndex = indexPath.row
        }

        var rowsToReload: [IndexPath] = [indexPath]

        if let previous = previous, previous != indexPath.row {
            rowsToReload.append(IndexPath(row: previous, section: 0))
        }

        tableView.reloadRows(at: rowsToReload, with: .automatic)

        tableView.beginUpdates()
        tableView.endUpdates()

        view.layoutIfNeeded()
        tableView.layoutIfNeeded()

        tableHeightConstraint.constant = tableView.contentSize.height

        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
       

}

    


