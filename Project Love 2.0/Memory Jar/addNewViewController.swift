//
//  addNewViewController.swift
//  Project Love 2.0
//
//  Created by SDC-USER on 10/01/26.
//

import UIKit
import PhotosUI

class addNewViewController: UIViewController,UITextViewDelegate, PHPickerViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var datePickerLabel: UIButton!
    
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var whiteimgView: UIView!
    let placeholderText = "What made this unforgettable?"
    
    
    @IBAction func dateButtonTapped(_ sender: UIButton) {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .inline
        picker.maximumDate = Date()
        
        // Update the picker to the last selected date
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        if let currentTitle = datePickerLabel.title(for: .normal),
           let currentDate = formatter.date(from: currentTitle) {
            picker.date = currentDate
        }

        picker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)

        let vc = UIViewController()
        vc.view.backgroundColor = .systemBackground
        vc.view.addSubview(picker)
        
        picker.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            picker.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 10),
            picker.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 10),
            picker.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -10)
        ])

        if let sheet = vc.sheetPresentationController {
            // Custom detent for exact height
            let customDetent = UISheetPresentationController.Detent.custom { context in
                return 450 // Adjust this height to match your needs
            }
            sheet.detents = [customDetent]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 30
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.largestUndimmedDetentIdentifier = customDetent.identifier
        }

        self.present(vc, animated: true)
    }
        // MARK: - Lifecycle
        override func viewDidLoad() {
            super.viewDidLoad()
            
            setupUI()
            setupPlaceholder()
            setupDismissKeyboardGesture()
            datePickerLabel.isUserInteractionEnabled = true
            updateButtonDate(date: Date())
            
            
        }

        // MARK: - Setup Methods
        
        private func setupUI() {
            // Round corners for the white background card
            whiteimgView.layer.cornerRadius = 16
            whiteimgView.clipsToBounds = true
            
            // Round corners for the actual image
            image.layer.cornerRadius = 16
            image.clipsToBounds = true
            image.contentMode = .scaleAspectFill
            image.isUserInteractionEnabled = true
            
                let tap = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
                image.addGestureRecognizer(tap)
            
        }
        
        private func setupPlaceholder() {
            descriptionTextView.delegate = self
            descriptionTextView.text = placeholderText
            descriptionTextView.textColor = .placeholderText
            
            // Crucial for growing inside a Stack View
            descriptionTextView.isScrollEnabled = false
        }
        
        private func setupDismissKeyboardGesture() {
            let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
            // Allows buttons and other controls to keep working
            tap.cancelsTouchesInView = false
            view.addGestureRecognizer(tap)
        }

        @objc func dismissKeyboard() {
            view.endEditing(true)
        }

        // MARK: - UITextViewDelegate

        func textViewDidBeginEditing(_ textView: UITextView) {
            if textView.textColor == .placeholderText {
                textView.text = nil
                textView.textColor = .label
            }
        }
    
        func textViewDidEndEditing(_ textView: UITextView) {
            // If user clears the text or types only spaces, restore placeholder
            if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                textView.text = placeholderText
                textView.textColor = .placeholderText
            }
        }
        
        // This ensures the Stack View updates as you type
        func textViewDidChange(_ textView: UITextView) {
            // Trigger layout update so the Stack View 'pushes' elements
            self.view.layoutIfNeeded()
        }
    
    private func updateButtonDate(date: Date) {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium // This gives you "Jan 10, 2026"
        let dateString = formatter.string(from: date)
        
        // Updates the text on your button
        datePickerLabel.setTitle(dateString, for: .normal)
    }
    @objc func dateChanged(_ sender: UIDatePicker) {
        // Updates the main button text immediately when a date is tapped
        updateButtonDate(date: sender.date)
    }
    
    @objc func imageTapped() {
        let alert = UIAlertController(title: "Select Image", message: nil, preferredStyle: .actionSheet)
        
        // Camera Action
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { _ in
            // The 'dismiss' happens automatically, but we call the picker
            // after a tiny delay to let the UI settle.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.openCamera()
            }
        }
        
        // Gallery Action
        let galleryAction = UIAlertAction(title: "Gallery", style: .default) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.openGallery()
            }
        }
        
        alert.addAction(cameraAction)
        alert.addAction(galleryAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        // This is required to prevent crashes on iPad
        alert.popoverPresentationController?.sourceView = self.image
        
        self.present(alert, animated: true)
    }
        // MARK: - Camera Logic
        private func openCamera() {
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                let picker = UIImagePickerController()
                picker.delegate = self
                picker.sourceType = .camera
                picker.allowsEditing = true
                present(picker, animated: true)
            } else {
                print("Camera not available")
            }
        }

        // MARK: - Gallery Logic (PHPicker)
    private func openGallery() {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.filter = .images
        config.selectionLimit = 1
        // Use .current to avoid slow image processing/transcoding
        config.preferredAssetRepresentationMode = .current
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }

        // MARK: - Picker Delegates
        
        // Gallery Result
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        guard let provider = results.first?.itemProvider, provider.canLoadObject(ofClass: UIImage.self) else { return }
        
        provider.loadObject(ofClass: UIImage.self) { [weak self] (img, error) in
            DispatchQueue.main.async {
                if let selectedImage = img as? UIImage {
                    // ADD THIS ANIMATION BLOCK for a smooth fade-in:
                    UIView.transition(with: self!.image, duration: 0.3, options: .transitionCrossDissolve, animations: {
                        self?.image.image = selectedImage
                    }, completion: nil)
                }
            }
        }
    
    }

        // Camera Result
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            picker.dismiss(animated: true)
            if let selectedImage = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage {
                self.image.image = selectedImage
            }
        }

}
