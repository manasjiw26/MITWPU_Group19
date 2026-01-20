//
//  BadgePopUPViewController.swift
//  Project Love 2.0
//
//  Created by shivangi mishra on 14/01/26.
//

import UIKit

class BadgePopUPViewController: UIViewController {
    
    
    @IBOutlet weak var popupView: UIView!
    
    @IBOutlet weak var badgeImageView: UIImageView!
    
    @IBOutlet weak var dismissButton: UIButton!
   
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var subtitleLabel: UILabel!
    
    var data: BadgePopupData?
    var bondName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // Dim background
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)

        // Popup styling
        popupView.layer.cornerRadius = 28
        popupView.layer.masksToBounds = true
        popupView.backgroundColor = .white
        
        //Shadow styling
        popupView.layer.shadowColor = UIColor.black.cgColor
        popupView.layer.shadowOpacity = 0.15
        popupView.layer.shadowOffset = CGSize(width: 0, height: 8)
        popupView.layer.shadowRadius = 20
        popupView.layer.masksToBounds = false
        
        dismissButton.tintColor = .white
        dismissButton.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        dismissButton.layer.cornerRadius = 16

        

           dismissButton.addTarget(
               self,
               action: #selector(dismissTapped),
               for: .touchUpInside,
                          )
        
        if let bondName = bondName,
           let popupData = DataStore.shared.getBadgePopupData(for: bondName) {

            self.data = popupData
        }

        
        configureUI()

    }
    
    
    @objc func dismissTapped() {
        UIView.animate(withDuration: 0.25, animations: {
            self.popupView.transform = CGAffineTransform(translationX: 0, y: 400)
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0)
        }) { _ in
            self.dismiss(animated: false)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        popupView.transform = CGAffineTransform(translationX: 0, y: 400)
        popupView.alpha = 0
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        UIView.animate(
            withDuration: 0.35,
            delay: 0,
            usingSpringWithDamping: 0.85,
            initialSpringVelocity: 0.6,
            options: []
        ) {
            self.popupView.transform = .identity
            self.popupView.alpha = 1
        }
    }

    
    private func configureUI() {
        guard let data = data else { return }

        titleLabel.text = data.title
        subtitleLabel.text = data.subtitle
        badgeImageView.image = UIImage(named: data.imageName)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
