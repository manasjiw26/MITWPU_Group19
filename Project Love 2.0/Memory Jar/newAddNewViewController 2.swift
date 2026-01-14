import UIKit
import PhotosUI
import MapKit

class NewAddNewViewController: UIViewController, LocationSearchDelegate {
    
    
    func didSelectLocation(_ name: String) {
        locationTextField.text = name
    }
    
    
    // MARK: - Outlets
    @IBOutlet var textFieldView: [UIView]! // Ensure ALL container views are in this collection
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var memoryTitleTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var memoryImageView: UIImageView!
    
    // MARK: - Properties
    let datePicker = UIDatePicker()
    private let placeholderText = "Type here..."
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupDatePicker()
        setupTextView()
        setupImagePicker()
        setupDismissKeyboardGesture()
        applyCornerStyles()
        locationTextField.delegate = self
        
        // Keyboard Observers
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        applyCornerStyles()
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        // Remove borders from text fields to show the rounded container view instead
        dateTextField.borderStyle = .none
        memoryTitleTextField.borderStyle = .none
        locationTextField.borderStyle = .none
        
        // Setup Image View
        memoryImageView.layer.cornerRadius = 15
        memoryImageView.clipsToBounds = true
        memoryImageView.contentMode = .scaleAspectFill
        memoryImageView.isUserInteractionEnabled = true
    }
    
    private func applyCornerStyles() {
        guard let containers = textFieldView else { return }
        for container in containers {
            container.layer.cornerRadius = 12
            container.layer.masksToBounds = true // Crucial for corner radius
            container.clipsToBounds = true
            container.layer.borderWidth = 1.0
            container.layer.borderColor = UIColor.systemGray6.cgColor
        }
    }
    
    private func setupTextView() {
        descriptionTextView.delegate = self
        descriptionTextView.text = placeholderText
        descriptionTextView.textColor = .placeholderText
    }
    
    // MARK: - Date Picker
    private func setupDatePicker() {
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.maximumDate = Date()
        
        datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        
        dateTextField.inputView = datePicker
        updateDateTextField(date: Date())
    }

    @objc func datePickerValueChanged() {
        updateDateTextField(date: datePicker.date)
    }
    

    
    private func updateDateTextField(date: Date) {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        dateTextField.text = formatter.string(from: date)
    }

    // MARK: - Saving Logic with Validation
    // MARK: - Saving Logic with Validation
    @IBAction func saveButtonTapped(_ sender: Any) {
        // 1. Check if image is nil OR if it's still the placeholder image
        let currentImage = memoryImageView.image
        let placeholderImage = UIImage(named: "Empty_Image1")
        
        // Validation: Ensure photo is selected and isn't the placeholder
        if currentImage == nil || currentImage?.pngData() == placeholderImage?.pngData() {
            showError(message: "Please select a photo to save this memory.")
            return
        }

        let title = memoryTitleTextField.text ?? ""
        let location = locationTextField.text ?? ""
        let dateStr = dateTextField.text ?? ""
        let description = (descriptionTextView.text == placeholderText) ? "" : descriptionTextView.text ?? ""
        
        // Create and save
        let newMemory = Memory(
            imageName: "captured_memory",
            date : dateStr ,
            location: location,
            title: title,
            subtitle: dateStr,
            uiImage: currentImage!
        )
        
        dataStore.savedMemories.append(newMemory)
        
        let alert = UIAlertController(title: nil, message: "Memory Added Successfully!", preferredStyle: .alert)
        self.present(alert, animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            alert.dismiss(animated: true) {
                NotificationCenter.default.post(name: NSNotification.Name("MemoryAdded"), object: nil)
                self.dismiss(animated: true)
            }
        }
    }
    
    private func showError(message: String) {
        let alert = UIAlertController(title: "Missing Info", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // MARK: - Keyboard Management
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }

        var shiftHeight: CGFloat = 0
        
        if locationTextField.isFirstResponder {
            shiftHeight = keyboardSize.height * 0.7 // Moves it a little
        } else if descriptionTextView.isFirstResponder {
            shiftHeight = keyboardSize.height * 1 // Moves it a little more
        }

        if self.view.frame.origin.y == 0 {
            UIView.animate(withDuration: 0.3) {
                self.view.frame.origin.y -= shiftHeight
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
}

// MARK: - Image Picking
extension NewAddNewViewController: PHPickerViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private func setupImagePicker() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        memoryImageView.addGestureRecognizer(tap)
    }
    
    @objc func imageTapped() {
        let alert = UIAlertController(title: "Choose Memory Photo", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default) { _ in self.openCamera() })
        alert.addAction(UIAlertAction(title: "Gallery", style: .default) { _ in self.openGallery() })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        self.present(alert, animated: true)
    }
    
    private func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .camera
            picker.allowsEditing = true
            present(picker, animated: true)
        }
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
}

// MARK: - TextView Delegate
extension NewAddNewViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .placeholderText {
            textView.text = nil
            textView.textColor = .secondaryLabel
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = placeholderText
            textView.textColor = .placeholderText
        }
    }
    
    private func setupDismissKeyboardGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension NewAddNewViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == locationTextField {
            presentLocationPicker()
            return false
        }
        return true
    }
    
    // Triggered when location field is tapped
    func presentLocationPicker() {
        performSegue(withIdentifier: "goToSearch", sender: self)
    }

    // Passes the delegate so the main screen gets the data back
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToSearch",
           let destination = segue.destination as? LocationSearchViewController {
            destination.delegate = self
        }
    }
}
