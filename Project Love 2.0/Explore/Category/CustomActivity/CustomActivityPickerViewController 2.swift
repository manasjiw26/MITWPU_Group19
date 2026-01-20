//
//  CustomActivityPickerViewController.swift
//  Project Love 2.0
//
//  Created by SDC-USER on 20/01/26.
//

import UIKit

class CustomActivityPickerViewController: UIViewController {

    @IBOutlet weak var containerView: UIView!

    @IBOutlet weak var cancelButton: UIButton!
    
    private let dimmingView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Clear root background
        view.backgroundColor = .clear

        // Dimming background
        dimmingView.frame = view.bounds
        dimmingView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        dimmingView.alpha = 0
        view.insertSubview(dimmingView, belowSubview: containerView)
        cancelButton.configuration = .glass()
        cancelButton.setTitle("Cancel", for: .normal)
        

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissPopup))
        dimmingView.addGestureRecognizer(tap)

        // Popup styling
        containerView.layer.cornerRadius = 24
        containerView.clipsToBounds = true

        // Initial popover-like state
        containerView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        containerView.alpha = 0
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        UIView.animate(
            withDuration: 0.25,
            delay: 0,
            usingSpringWithDamping: 0.85,
            initialSpringVelocity: 0.6,
            options: []
        ) {
            self.containerView.transform = .identity
            self.containerView.alpha = 1
            self.dimmingView.alpha = 1
        }
    }

    @objc func dismissPopup() {
        UIView.animate(withDuration: 0.2, animations: {
            self.containerView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            self.containerView.alpha = 0
            self.dimmingView.alpha = 0
        }) { _ in
            self.dismiss(animated: false)
        }
    }

    // MARK: - Button Actions

    @IBAction func createQATapped(_ sender: UIButton) {
        dismiss(animated: false) {
               let vc = QnAViewController(
                   nibName: "QnAViewController",
                   bundle: nil
               )
               vc.modalPresentationStyle = .fullScreen
               UIApplication.shared.keyWindow?.rootViewController?
                   .present(vc, animated: true)
           }
        
    }

    @IBAction func writeActivityTapped(_ sender: UIButton) {
        dismiss(animated: false) {
               let vc = WriteActivityViewController(
                   nibName: "WriteActivityViewController",
                   bundle: nil
               )
               vc.modalPresentationStyle = .fullScreen
               UIApplication.shared.keyWindow?.rootViewController?
                   .present(vc, animated: true)
           }
        
    }

    @IBAction func cancelTapped(_ sender: UIButton) {
        dismissPopup()
    }
}

