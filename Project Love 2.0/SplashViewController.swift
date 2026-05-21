//
//  SplashViewController.swift
//  Project Love 2.0
//
//  Animated splash screen: two doodle blobs slide in from
//  top-right and bottom-left corners, then the "TwoOfUs"
//  title zooms in — matching the app icon composition.
//

import UIKit

class SplashViewController: UIViewController {

    // MARK: – UI Elements

    private let doodleTop = UIImageView()      // winking doodle → enters from top-right
    private let doodleBottom = UIImageView()    // happy doodle   → enters from bottom-left
    private let titleLabel = UILabel()          // "TwoOfUs"

    // MARK: – Design Constants
    private let doodleSize: CGFloat = 220       // Size of the doodles (reverted to original size)
    private let offScreenAmount: CGFloat = 0     // 0pt off-screen, bringing them fully onto the screen

    // MARK: – Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupDoodles()
        setupTitle()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateEntrance()
    }

    // MARK: – Setup

    private func setupDoodles() {
        // ── Top-right doodle (winking) ──
        doodleTop.image = UIImage(named: "doodle_winking")
        doodleTop.contentMode = .scaleAspectFit
        doodleTop.frame = CGRect(x: 0, y: 0, width: doodleSize, height: doodleSize)
        // Start off-screen: far to the right and above the top
        doodleTop.center = CGPoint(x: view.bounds.width + doodleSize,
                                   y: -doodleSize)
        doodleTop.alpha = 0
        view.addSubview(doodleTop)

        // ── Bottom-left doodle (happy) ──
        doodleBottom.image = UIImage(named: "doodle_happy")
        doodleBottom.contentMode = .scaleAspectFit
        doodleBottom.frame = CGRect(x: 0, y: 0, width: doodleSize, height: doodleSize)
        // Start off-screen: far to the left and below the bottom
        doodleBottom.center = CGPoint(x: -doodleSize,
                                      y: view.bounds.height + doodleSize)
        doodleBottom.alpha = 0
        view.addSubview(doodleBottom)
    }

    private func setupTitle() {
        titleLabel.text = "TwoOfUs"
        titleLabel.font = UIFont.systemFont(ofSize: 42, weight: .heavy)
        titleLabel.textColor = UIColor(red: 0.45, green: 0.25, blue: 0.70, alpha: 1.0) // deep purple
        titleLabel.textAlignment = .center
        titleLabel.alpha = 0
        titleLabel.transform = CGAffineTransform(scaleX: 0.15, y: 0.15) // start very small
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    // MARK: – Animations

    private func animateEntrance() {
        let screenW = view.bounds.width
        let screenH = view.bounds.height
        let half = doodleSize / 2

        // Landing positions:
        // winking doodle → top-right corner
        let topLandingCenter = CGPoint(x: screenW - half + offScreenAmount, y: half - offScreenAmount)
        // happy doodle → bottom-left corner
        let bottomLandingCenter = CGPoint(x: half - offScreenAmount, y: screenH - half + offScreenAmount)

        // ── Step 1: Slide doodles in with a spring bounce ──
        UIView.animate(
            withDuration: 0.6,
            delay: 0.15,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0.9,
            options: .curveEaseOut,
            animations: {
                self.doodleTop.center = topLandingCenter
                self.doodleTop.alpha = 1
            }
        )

        UIView.animate(
            withDuration: 0.6,
            delay: 0.3,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0.9,
            options: .curveEaseOut,
            animations: {
                self.doodleBottom.center = bottomLandingCenter
                self.doodleBottom.alpha = 1
            }
        )

        // ── Step 2: Title zooms in ──
        UIView.animate(
            withDuration: 0.5,
            delay: 0.9,
            usingSpringWithDamping: 0.6,
            initialSpringVelocity: 0.7,
            options: .curveEaseOut,
            animations: {
                self.titleLabel.alpha = 1
                self.titleLabel.transform = .identity
            }
        )

        // ── Step 3: Transition out ──
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.7) {
            self.transitionToApp()
        }
    }


    // MARK: – Transition

    private func transitionToApp() {
        // Instant cut — no transition animation, pure native iOS splash behaviour
        guard let sceneDelegate = self.view.window?.windowScene?.delegate as? SceneDelegate else { return }
        sceneDelegate.showMainApp()
    }
}
