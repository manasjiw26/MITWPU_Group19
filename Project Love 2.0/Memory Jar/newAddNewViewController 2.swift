import UIKit
import PhotosUI
import MapKit
import Supabase

class NewAddNewViewController: UIViewController {

    @IBOutlet var textFieldView: [UIView]!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var memoryTitleTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var memoryImageView: UIImageView!
    
    let supabase = SupabaseManager.shared.client

    private let datePicker = UIDatePicker()
    private let placeholderText = "Type here..."

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

    private func setupUI() {
        [dateTextField, memoryTitleTextField, locationTextField].forEach {
            $0?.borderStyle = .none
        }

        memoryImageView.layer.cornerRadius = 15
        memoryImageView.clipsToBounds = true
        memoryImageView.contentMode = .scaleAspectFill
        memoryImageView.isUserInteractionEnabled = true

        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.maximumDate = Date()
        datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        dateTextField.inputView = datePicker
        updateDateTextField(date: Date())

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
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    private func applyCornerStyles() {
        textFieldView.forEach {
            $0.layer.cornerRadius = 12
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.systemGray6.cgColor
        }
    }

    @objc private func datePickerValueChanged() {
        updateDateTextField(date: datePicker.date)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    @IBAction func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true)
    }

    @IBAction func saveButtonTapped(_ sender: Any) {

        Task {
                await saveMemoryToSupabase()
            }
    }

    @MainActor
    private func saveMemoryToSupabase() async {
        guard let image = memoryImageView.image,
              let imageData = image.jpegData(compressionQuality: 0.8) else {
            showError(message: "Please select a photo.")
            return
        }
        
        guard let userId = supabase.auth.currentUser?.id else {
            showError(message: "User not logged in")
            return
        }

        do {
            // Get relationship_id
            let response = try await supabase
                .from("users")
                .select("relationship_id")
                .eq("user_id", value: userId.uuidString)
                .single()
                .execute()

            struct UserRelation: Decodable {
                let relationship_id: UUID?
            }

            let decoded = try JSONDecoder().decode(UserRelation.self, from: response.data)

            guard let relationshipId = decoded.relationship_id else {
                showError(message: "No relationship found")
                return
            }

            // 1. Prepare Data for Background Upload
            let date = datePicker.date
            let isoDate = ISO8601DateFormatter().string(from: date)
            let title = memoryTitleTextField.text ?? ""
            let description = descriptionTextView.text == placeholderText ? "" : descriptionTextView.text ?? ""
            
            // Generate a random ID for instant local display
            let tempID = UUID() 
            let newLocalMemory = Memory(
                id: tempID,
                date: date,
                imageName: "", // Will be assigned remotely
                location: "", 
                title: title,
                description: description,
                uiImage: image
            )

            // 2. Start the background upload
            MemoryUploadManager.shared.uploadMemory(
                userId: userId.uuidString,
                relationshipId: relationshipId,
                imageData: imageData,
                title: title,
                description: description,
                isoDate: isoDate
            )
            
            let alert = UIAlertController(
                title: "",
                message: "Memory added successfully!",
                preferredStyle: .alert
            )
            self.present(alert, animated: true)

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                alert.dismiss(animated: true) {
                    self.dismiss(animated: true) {
                        // 3. Notify Jar & Show Alert
                        NotificationCenter.default.post(
                            name: NSNotification.Name("MemoryAdded"),
                            object: newLocalMemory
                        )
                    }
                }
            }

        } catch {
            showError(message: error.localizedDescription)
            print("Failed to get relationship ID:", error)
        }
    }
    
    private func updateDateTextField(date: Date) {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        dateTextField.text = formatter.string(from: date)
    }

    private func showError(message: String) {
        let alert = UIAlertController(title: "Missing Info",
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

//  Location Search
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

//Image Picking
extension NewAddNewViewController: PHPickerViewControllerDelegate,
                                   UIImagePickerControllerDelegate,
                                   UINavigationControllerDelegate {

    @objc private func imageTapped() {
        let alert = UIAlertController(title: "Choose Memory Photo",
                                      message: nil,
                                      preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default) { _ in self.openCamera() })
        alert.addAction(UIAlertAction(title: "Gallery", style: .default) { _ in self.openGallery() })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
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

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        if let edited = info[.editedImage] as? UIImage {
            memoryImageView.image = edited
        } else if let original = info[.originalImage] as? UIImage {
            memoryImageView.image = original
        }
    }
}

// Keyboard & Text Delegates
extension NewAddNewViewController: UITextFieldDelegate, UITextViewDelegate {
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize =
            (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        else { return }

        var shiftHeight: CGFloat = 0

        if locationTextField.isFirstResponder {
            shiftHeight = keyboardSize.height * 0.7
        } else if descriptionTextView.isFirstResponder {
            shiftHeight = keyboardSize.height
        }

        if view.frame.origin.y == 0 {
            UIView.animate(withDuration: 0.3) {
                self.view.frame.origin.y -= shiftHeight
            }
        }
    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        if view.frame.origin.y != 0 {
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
