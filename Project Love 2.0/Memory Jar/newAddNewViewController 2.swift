import UIKit
import PhotosUI
import MapKit

class NewAddNewViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet var textFieldView: [UIView]!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var memoryTitleTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var memoryImageView: UIImageView!
    
    // MARK: - Properties
    private let datePicker = UIDatePicker()
    private let placeholderText = "Type here..."
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupDelegates()
        setupInteractions()
        setupNotifications()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        applyCornerStyles()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Setup Logic
    private func setupUI() {
        // Remove text field borders to show custom container styling
        [dateTextField, memoryTitleTextField, locationTextField].forEach {
            $0?.borderStyle = .none
        }
        
        // Image View styling
        memoryImageView.layer.cornerRadius = 15
        memoryImageView.clipsToBounds = true
        memoryImageView.contentMode = .scaleAspectFill
        memoryImageView.isUserInteractionEnabled = true
        
        // Date Picker setup
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.maximumDate = Date()
        datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        dateTextField.inputView = datePicker
        updateDateTextField(date: Date())
        
        // Description TextView placeholder
        descriptionTextView.text = placeholderText
        descriptionTextView.textColor = .placeholderText
    }

    private func setupDelegates() {
        locationTextField.delegate = self
        descriptionTextView.delegate = self
        memoryTitleTextField.delegate = self
    }

    private func setupInteractions() {
        let imageTap = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        memoryImageView.addGestureRecognizer(imageTap)
        
        let dismissTap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        dismissTap.cancelsTouchesInView = false
        view.addGestureRecognizer(dismissTap)
    }

    private func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    private func applyCornerStyles() {
        textFieldView?.forEach { container in
            container.layer.cornerRadius = 12
            container.layer.masksToBounds = true
            container.layer.borderWidth = 1.0
            container.layer.borderColor = UIColor.systemGray6.cgColor
        }
    }

    // MARK: - Actions
    @objc private func datePickerValueChanged() {
        updateDateTextField(date: datePicker.date)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }

    @IBAction func saveButtonTapped(_ sender: Any) {
        let currentImage = memoryImageView.image
        let placeholderImage = UIImage(named: "Empty_Image1")
        
        // 1. Image Validation
        if currentImage == nil || currentImage?.pngData() == placeholderImage?.pngData() {
            showError(message: "Please select a photo to save this memory.")
            return
        }

        // 2. Data Preparation
        let title = memoryTitleTextField.text ?? ""
        let location = locationTextField.text ?? ""
        let description = (descriptionTextView.text == placeholderText) ? "" : descriptionTextView.text ?? ""
        
        // 3. Create Memory Object (Using all your fields)
        let newMemory = Memory(
            date: datePicker.date,
            imageName: "captured_memory",
            location: location,
            title: title,
            description: description,
            uiImage: currentImage!
        )
        
        // 4. Persistence
        dataStore.savedMemories.append(newMemory)
        
        // 5. Success Feedback
        let alert = UIAlertController(title: nil, message: "Memory Added Successfully!", preferredStyle: .alert)
        self.present(alert, animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            alert.dismiss(animated: true) {
                NotificationCenter.default.post(name: NSNotification.Name("MemoryAdded"), object: nil)
                self.dismiss(animated: true)
            }
        }
    }

    // MARK: - Helpers
    private func updateDateTextField(date: Date) {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        dateTextField.text = formatter.string(from: date)
    }

    private func showError(message: String) {
        let alert = UIAlertController(title: "Missing Info", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - Location Search
extension NewAddNewViewController: LocationSearchDelegate {
    func didSelectLocation(_ name: String) {
        locationTextField.text = name
    }
    
    private func presentLocationPicker() {
        performSegue(withIdentifier: "goToSearch", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToSearch",
           let destination = segue.destination as? LocationSearchViewController {
            destination.delegate = self
        }
    }
}

// MARK: - Image Picking
extension NewAddNewViewController: PHPickerViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @objc private func imageTapped() {
        let alert = UIAlertController(title: "Choose Memory Photo", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default) { _ in self.openCamera() })
        alert.addAction(UIAlertAction(title: "Gallery", style: .default) { _ in self.openGallery() })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        self.present(alert, animated: true)
    }
    
    private func openCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else { return }
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .camera
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    
    private func openGallery() {
        var config = PHPickerConfiguration()
        config.filter = .images
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        results.first?.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] img, _ in
            DispatchQueue.main.async {
                if let image = img as? UIImage {
                    self?.memoryImageView.image = image
                }
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        if let edited = info[.editedImage] as? UIImage {
            memoryImageView.image = edited
        } else if let original = info[.originalImage] as? UIImage {
            memoryImageView.image = original
        }
    }
}

// MARK: - Keyboard & Text Delegates
extension NewAddNewViewController: UITextFieldDelegate, UITextViewDelegate {
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        var shiftHeight: CGFloat = 0
        
        if locationTextField.isFirstResponder {
            shiftHeight = keyboardSize.height * 0.7
        } else if descriptionTextView.isFirstResponder {
            shiftHeight = keyboardSize.height * 1.0
        }

        if self.view.frame.origin.y == 0 {
            UIView.animate(withDuration: 0.3) {
                self.view.frame.origin.y -= shiftHeight
            }
        }
    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            UIView.animate(withDuration: 0.3) {
                self.view.frame.origin.y = 0
            }
        }
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == locationTextField {
            presentLocationPicker()
            return false
        }
        return true
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .placeholderText {
            textView.text = nil
            textView.textColor = .label
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = placeholderText
            textView.textColor = .placeholderText
        }
    }
}
