//
//  SmallModalViewController.swift
//  Project Love 2.0
//
//  Created by SDC-USER on 09/12/25.
//

import UIKit

class SmallModalViewController: UIViewController {
    var selectedActivity: SmallModalData?
    
    
    @IBOutlet weak var modalView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var mainImage: UIImageView!
    @IBOutlet weak var clockImage: UIImageView!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var DesciptionLabel: UILabel!
    @IBOutlet weak var PointsLabel: UILabel!
    @IBOutlet weak var PointsImage: UIImageView!
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

        
        
        if let data = selectedActivity {
            titleLabel.text = data.title
            DesciptionLabel.text = data.descriptionLabel
            timerLabel.text = data.timerLabel
            PointsLabel.text = data.pointsLabel
            
            mainImage.image = UIImage(named: data.mainImageName)
            PointsImage.image = UIImage(systemName: data.pointsymbol)
            clockImage.image = UIImage(systemName: data.clockImageName)
            clockImage.tintColor = .black
            PointsImage.tintColor = UIColor(red: 255/255, green: 204/255, blue: 0/255, alpha: 1)
        }
        
        //  Dim background
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        
        
        
        
        //  Modal actual container
        modalView.backgroundColor = .white
        modalView.layer.cornerRadius = 40
        modalView.layer.masksToBounds = true
//        modalView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(modalView)
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Start with hidden dim background
        //self.view.backgroundColor = UIColor.black.withAlphaComponent(0)
        view.backgroundColor = .clear
        
        // Start modalView off-screen
        modalView.transform = CGAffineTransform(translationX: 0, y: 400)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 0.3, animations: {
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
            self.modalView.transform = .identity
        })
    }
    
    
    @IBAction func closeButton(_ sender: Any) {
        //self.dismiss(animated: true, completion: nil)
        UIView.animate(withDuration: 0.25, animations: {
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0)
            self.modalView.transform = CGAffineTransform(translationX: 0, y: 400)
        }) { _ in
            self.dismiss(animated: true)
        }
    }
    
    
    @IBAction func beginButon(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Steps", bundle: nil)
        let stepsVC = storyboard.instantiateViewController(withIdentifier: "StepsViewController") as! StepsViewController
        
        //stepsVC.steps = dataStore.loadSteps()
        stepsVC.activitytitle = selectedActivity?.title ?? ""
        stepsVC.modalPresentationStyle = .fullScreen
        
        if let presenter = self.presentingViewController {
            UIView.animate(withDuration: 0.1, animations: {
                self.view.backgroundColor = UIColor.black.withAlphaComponent(0)
                self.modalView.transform = CGAffineTransform(translationX: 0, y: 400)
            })
            self.dismiss(animated: true) {
                
                presenter.present(stepsVC, animated: true)
            }
        }
        
        
    }
}
