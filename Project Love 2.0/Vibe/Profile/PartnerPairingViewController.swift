//
//  PartnerPairingViewController.swift
//  Project Love 2.0
//
//  Created by SDC-USER on 17/02/26.
//

import UIKit

class PartnerPairingViewController: UIViewController {

    @IBOutlet var sharedCodeCollectionView: UICollectionView!
    @IBOutlet var enterCodeCollectionView: UICollectionView!
    @IBOutlet var shareInviteButton: UIButton!
    @IBOutlet var pairNowButton: UIButton!
    @IBOutlet var hiddenTextField: UITextField!
    let shareCodeArray: [String] = ["D","K","1","T","D","8"]
       var enteredCode: String = ""
       let maxDigits = 6
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Partner Pairing"
        view.backgroundColor = .systemGroupedBackground
        shareInviteButton.configuration = .glass()
        shareInviteButton.setTitle("Share your invite", for: .normal)
        pairNowButton.configuration = .glass()
        pairNowButton.setTitle("Pair now", for: .normal)
        
        setupButtons()
        setupCollectionViews()
        setupTextField()
        setupTapToFocus()
        addSeparator()
        
    }
    func setupButtons() {
           shareInviteButton.configuration = .glass()
           shareInviteButton.setTitle("Share my code", for: .normal)

           pairNowButton.configuration = .glass()
           pairNowButton.setTitle("Pair now", for: .normal)
       }

       func setupCollectionViews() {

           // Invite code cells
           sharedCodeCollectionView.register(
               UINib(nibName: "ShareCodeCollectionViewCell", bundle: nil),
               forCellWithReuseIdentifier: "CodeCell"
           )

           // Enter code cells
           enterCodeCollectionView.register(
               UINib(nibName: "EnterCodeCollectionViewCell", bundle: nil),
               forCellWithReuseIdentifier: "EnterCodeCell"
           )

           sharedCodeCollectionView.delegate = self
           sharedCodeCollectionView.dataSource = self

           enterCodeCollectionView.delegate = self
           enterCodeCollectionView.dataSource = self
       }

       func setupTextField() {
           hiddenTextField.delegate = self
           hiddenTextField.keyboardType = .asciiCapable
           //hiddenTextField.textContentType = .oneTimeCode
           hiddenTextField.autocorrectionType = .no
           hiddenTextField.alpha = 0.01

           hiddenTextField.addTarget(self,
                                     action: #selector(textDidChange),
                                     for: .editingChanged)
       }

       func setupTapToFocus() {
           let tap = UITapGestureRecognizer(target: self,
                                            action: #selector(focusInput))
           tap.cancelsTouchesInView = false
           view.addGestureRecognizer(tap)
       }
    func addSeparator() {
        let sep = UIView()
        sep.translatesAutoresizingMaskIntoConstraints = false
        sep.backgroundColor = .separator

        view.addSubview(sep)

        NSLayoutConstraint.activate([
            sep.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            sep.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            sep.heightAnchor.constraint(equalToConstant: 1),
            sep.centerYAnchor.constraint(equalTo: view.centerYAnchor) // adjust anchor
        ])
    }

       @objc func focusInput() {
           hiddenTextField.becomeFirstResponder()
       }

       // MARK: - Text Handling

       @objc func textDidChange(_ textField: UITextField) {

           let text = textField.text?.uppercased() ?? ""
           enteredCode = String(text.prefix(maxDigits))
           textField.text = enteredCode

           enterCodeCollectionView.reloadData()

           if enteredCode.count == maxDigits {
               codeCompleted(enteredCode)
           }
       }

       func codeCompleted(_ code: String) {
       }

       // MARK: - Actions

       @IBAction func shareInviteTapped(_ sender: UIButton) {
           let code = shareCodeArray.joined()

           let activityVC = UIActivityViewController(
               activityItems: ["My partner code: \(code)"],
               applicationActivities: nil)

           present(activityVC, animated: true)
       }

       @IBAction func pairNow(_ sender: UIButton) {
           guard enteredCode.count == maxDigits else { return }
           codeCompleted(enteredCode)
       }
    
    
}
extension PartnerPairingViewController:
UICollectionViewDelegate,
UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout {

    func collectionView(_ cv: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {

        return cv == sharedCodeCollectionView
        ? shareCodeArray.count
        : maxDigits
    }

    func collectionView(_ cv: UICollectionView,
                        cellForItemAt indexPath: IndexPath)
    -> UICollectionViewCell {

        if cv == sharedCodeCollectionView {

            let cell = cv.dequeueReusableCell(
                withReuseIdentifier: "CodeCell",
                for: indexPath) as! ShareCodeCollectionViewCell

            cell.CodeLabel.text = String(shareCodeArray[indexPath.item])
            return cell

        } else {

            let cell = cv.dequeueReusableCell(
                withReuseIdentifier: "EnterCodeCell",
                for: indexPath) as! EnterCodeCollectionViewCell

            let chars = Array(enteredCode)
            cell.enterCodeLabel.text =
                indexPath.item < chars.count ? String(chars[indexPath.item]) : ""

            return cell
        }
    }

    func collectionView(_ cv: UICollectionView,
                        layout: UICollectionViewLayout,
                        sizeForItemAt: IndexPath) -> CGSize {
        return CGSize(width: 52, height: 60)
    }

    func collectionView(_ cv: UICollectionView,
                        layout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt: Int) -> CGFloat {
        return 5
    }
}
extension PartnerPairingViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
