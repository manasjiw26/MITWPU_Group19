//import UIKit
//import PhotosUI
//
//class newAddNewViewController: UIViewController {
//    
//    // MARK: - Outlets
//    @IBOutlet var textFieldView: [UIView]! // Ensure ALL container views are in this collection
//    @IBOutlet weak var dateTextField: UITextField!
//    @IBOutlet weak var memoryTitleTextField: UITextField!
//    @IBOutlet weak var locationTextField: UITextField!
//    @IBOutlet weak var descriptionTextView: UITextView!
//    @IBOutlet weak var memoryImageView: UIImageView!
//    
//    // MARK: - Properties
//    let datePicker = UIDatePicker()
//    private let placeholderText = "What made this unforgettable?"
//    
//    // MARK: - Lifecycle
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupUI()
//        setupDatePicker()
//        setupTextView()
//        setupImagePicker()
//        setupDismissKeyboardGesture()
//        applyCornerStyles()
//        
//        // Keyboard Observers
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
//    }
//    
//    // This is the "magic" spot where corner radius actually works with Auto Layout
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        applyCornerStyles()
//    }
//    
//    // MARK: - Setup UI
//    private func setupUI() {
//        // Remove borders from text fields to show the rounded container view instead
//        dateTextField.borderStyle = .none
//        memoryTitleTextField.borderStyle = .none
//        locationTextField.borderStyle = .none
//        
//        // Setup Image View
//        memoryImageView.layer.cornerRadius = 15
//        memoryImageView.clipsToBounds = true
//        memoryImageView.contentMode = .scaleAspectFill
//        memoryImageView.isUserInteractionEnabled = true
//    }
//    
//    private func applyCornerStyles() {
//        guard let containers = textFieldView else { return }
//        for container in containers {
//            container.layer.cornerRadius = 12
//            container.layer.masksToBounds = true // Crucial for corner radius
//            container.clipsToBounds = true       // Ensures subviews don't spill out
//            
//            // Optional: Adds a very subtle border so the radius is visible on white backgrounds
//            container.layer.borderWidth = 1.0
//            container.layer.borderColor = UIColor.systemGray6.cgColor
//        }
//    }
//    
//    private func setupTextView() {
//        descriptionTextView.delegate = self
//        descriptionTextView.text = placeholderText
//        descriptionTextView.textColor = .placeholderText
//    }
//    
//    // MARK: - Date Picker
//    private func setupDatePicker() {
//        datePicker.datePickerMode = .date
//        datePicker.preferredDatePickerStyle = .wheels
//        datePicker.maximumDate = Date()
//        dateTextField.inputView = datePicker
//        
//        let toolbar = UIToolbar()
//        toolbar.sizeToFit()
//        let doneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dateDonePressed))
//        toolbar.setItems([UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), doneBtn], animated: true)
//        dateTextField.inputAccessoryView = toolbar
//        
//        updateDateTextField(date: Date())
//    }
//    
//    @objc func dateDonePressed() {
//        updateDateTextField(date: datePicker.date)
//        self.view.endEditing(true)
//    }
//    
//    private func updateDateTextField(date: Date) {
//        let formatter = DateFormatter()
//        formatter.dateStyle = .medium
//        dateTextField.text = formatter.string(from: date)
//    }
//
//    // MARK: - Saving Logic with Validation
//    @IBAction func saveButtonTapped(_ sender: Any) {
//        // Validation: Ensure photo is selected (not nil)
//        guard let selectedImage = memoryImageView.image else {
//            showError(message: "Please select a photo to save this memory.")
//            return
//        }
//
//        let title = memoryTitleTextField.text ?? ""
//        let location = locationTextField.text ?? ""
//        let dateStr = dateTextField.text ?? ""
//        let description = (descriptionTextView.text == placeholderText) ? "" : descriptionTextView.text ?? ""
//        
//        // Create and save
//        let newMemory = Memory(
//            imageName: "captured_memory",
//            location: location,
//            title: title,
//            description: description,
//            uiImage: selectedImage
//        )
//        
//        dataStore.savedMemories.append(newMemory)
//        
//        let alert = UIAlertController(title: nil, message: "Memory Added Successfully!", preferredStyle: .alert)
//        self.present(alert, animated: true)
//        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
//            alert.dismiss(animated: true) {
//                NotificationCenter.default.post(name: NSNotification.Name("MemoryAdded"), object: nil)
//                self.dismiss(animated: true)
//            }
//        }
//    }
//    
//    private func showError(message: String) {
//        let alert = UIAlertController(title: "Missing Info", message: message, preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "OK", style: .default))
//        present(alert, animated: true)
//    }
//
//    // MARK: - Keyboard Management
//    @objc func keyboardWillShow(notification: NSNotification) {
//        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
//            if locationTextField.isFirstResponder || descriptionTextView.isFirstResponder {
//                if self.view.frame.origin.y == 0 {
//                    self.view.frame.origin.y -= (keyboardSize.height - 80)
//                }
//            }
//        }
//    }
//
//    @objc func keyboardWillHide(notification: NSNotification) {
//        if self.view.frame.origin.y != 0 {
//            self.view.frame.origin.y = 0
//        }
//    }
//
//    deinit {
//        NotificationCenter.default.removeObserver(self)
//    }
//
//    @IBAction func cancelButtonTapped(_ sender: Any) {
//        self.dismiss(animated: true)
//    }
//}
//
//// MARK: - Image Picking
//extension newAddNewViewController: PHPickerViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
//    
//    private func setupImagePicker() {
//        let tap = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
//        memoryImageView.addGestureRecognizer(tap)
//    }
//    
//    @objc func imageTapped() {
//        let alert = UIAlertController(title: "Choose Memory Photo", message: nil, preferredStyle: .actionSheet)
//        alert.addAction(UIAlertAction(title: "Camera", style: .default) { _ in self.openCamera() })
//        alert.addAction(UIAlertAction(title: "Gallery", style: .default) { _ in self.openGallery() })
//        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
//        self.present(alert, animated: true)
//    }
//    
//    private func openCamera() {
//        if UIImagePickerController.isSourceTypeAvailable(.camera) {
//            let picker = UIImagePickerController()
//            picker.delegate = self
//            picker.sourceType = .camera
//            picker.allowsEditing = true
//            present(picker, animated: true)
//        }
//    }
//    
//    private func openGallery() {
//        var config = PHPickerConfiguration()
//        config.filter = .images
//        let picker = PHPickerViewController(configuration: config)
//        picker.delegate = self
//        present(picker, animated: true)
//    }
//    
//    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
//        picker.dismiss(animated: true)
//        results.first?.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] img, _ in
//            DispatchQueue.main.async {
//                if let image = img as? UIImage {
//                    self?.memoryImageView.image = image
//                }
//            }
//        }
//    }
//}
//
//// MARK: - TextView Delegate
//extension newAddNewViewController: UITextViewDelegate {
//    func textViewDidBeginEditing(_ textView: UITextView) {
//        if textView.textColor == .placeholderText {
//            textView.text = nil
//            textView.textColor = .label
//        }
//    }
//    
//    func textViewDidEndEditing(_ textView: UITextView) {
//        if textView.text.isEmpty {
//            textView.text = placeholderText
//            textView.textColor = .placeholderText
//        }
//    }
//    
//    private func setupDismissKeyboardGesture() {
//        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
//        tap.cancelsTouchesInView = false
//        view.addGestureRecognizer(tap)
//    }
//    
//    @objc func dismissKeyboard() {
//        view.endEditing(true)
//    }
//}
