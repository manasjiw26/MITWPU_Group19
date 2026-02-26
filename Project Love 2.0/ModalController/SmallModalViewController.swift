//
//  SmallModalViewController.swift
//  Project Love 2.0
//
//  Created by SDC-USER on 09/12/25.
//

import UIKit
protocol SmallModalDelegate: AnyObject {
    func didStartActivity()
}

class SmallModalViewController: UIViewController, ScheduleCalendarDelegate {
    var modalData: SmallModalData?
    var flowSource: ActivityFlowSource?
    var selectedActivity: Activity?
    weak var delegate: SmallModalDelegate?
    var selectedActivityIndex: Int?
    var bondName: String?

    
    @IBOutlet weak var modalView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var mainImage: UIImageView!
    @IBOutlet weak var clockImage: UIImageView!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var DesciptionLabel: UILabel!
    @IBOutlet weak var beginButton: UIButton!
    @IBOutlet weak var scheduleButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.bringSubviewToFront(modalView)
        beginButton.configuration = .glass()
        beginButton.setTitle("Begin", for: .normal)
        scheduleButton.configuration = .glass()
        scheduleButton.setTitle("Schedule for later", for: .normal)
        closeButton.configuration = .glass()
        closeButton.setImage(
            UIImage(
                systemName: "xmark",
                withConfiguration: UIImage.SymbolConfiguration(weight: .medium)
            ),
            for: .normal
        )
        
        
        
        if let data = modalData {
            titleLabel.text = data.title
            DesciptionLabel.text = data.descriptionLabel
            timerLabel.text = data.timerLabel
            mainImage.image = UIImage(named: data.mainImageName)
            clockImage.image = UIImage(systemName: data.clockImageName)
            clockImage.tintColor = .black
            
        }
        else if let activity = selectedActivity {
            titleLabel.text = activity.name
            DesciptionLabel.text = activity.description
            timerLabel.text = activity.time
            mainImage.image = UIImage(named: activity.image)
            clockImage.image = UIImage(systemName: "clock")
            clockImage.tintColor = .black
        }

        //  Dim background
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        
        //  Modal actual container
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
    
    func didSchedule(activity: Activity, on date: Date) {
        DataStore.shared.updateScheduledDate(for: activity, date: date)

            delegate?.didStartActivity()
        
        UIView.animate(withDuration: 0.2, animations: {
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0)
            self.modalView.transform = CGAffineTransform(translationX: 0, y: 400)
        }) { _ in
            self.dismiss(animated: true)
        }
    }
    
    
    @IBAction func closeButton(_ sender: Any) {
      
        UIView.animate(withDuration: 0.25, animations: {
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0)
            self.modalView.transform = CGAffineTransform(translationX: 0, y: 400)
        }) { _ in
            self.dismiss(animated: true)
        }
    }
    
    
    @IBAction func beginButon(_ sender: Any) {

        guard let activity = selectedActivity else { return }

        DataStore.shared.startActivity(activity)

        delegate?.didStartActivity()

        let storyboard = UIStoryboard(name: "Steps", bundle: nil)
        let stepsVC = storyboard.instantiateViewController(
            withIdentifier: "StepsViewController"
        ) as! StepsViewController

        stepsVC.activity = activity
        stepsVC.flowSource = flowSource
        stepsVC.modalPresentationStyle = .fullScreen

        stepsVC.selectedActivityIndex = selectedActivityIndex
        stepsVC.bondName = bondName
        stepsVC.bondDelegate = presentingViewController as? BondActivityCompletionDelegate

        if let presenter = self.presentingViewController {
            UIView.animate(withDuration: 0.1) {
                self.view.backgroundColor = UIColor.black.withAlphaComponent(0)
                self.modalView.transform = CGAffineTransform(translationX: 0, y: 400)
            }
            self.dismiss(animated: true) {
                presenter.present(stepsVC, animated: true)
            }
        }
    }
    
    
    @IBAction func scheduleForLaterButton(_ sender: Any) {
        
        guard let activity = selectedActivity else { return }
        
        let calendarVC = CalendarModalViewController(
            nibName: "CalendarModalViewController",
            bundle: nil
        )
        
        calendarVC.activity = activity
        calendarVC.delegate = self
        
        calendarVC.modalPresentationStyle = .pageSheet
        if let sheet = calendarVC.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 40
            
            sheet.prefersEdgeAttachedInCompactHeight = true
            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
        }
        
        present(calendarVC, animated: true)
    }
}
