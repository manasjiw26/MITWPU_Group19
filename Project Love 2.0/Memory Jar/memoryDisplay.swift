import UIKit

class memoryDisplay: UIViewController {

    @IBOutlet weak var locationView: UIView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var datePickerLabel: UIButton!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var whiteimgView: UIView!
    @IBOutlet weak var memoryTitle: UITextField!
    
    var memory: Memory?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        displayMemoryData()

        // Refresh if the partner edits this memory while the sheet is open
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleMemoryUpdated(_:)),
            name: NSNotification.Name("MemoryUpdated"),
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func handleMemoryUpdated(_ notification: Notification) {
        guard let updatedId = notification.object as? UUID,
              let current = memory, current.id == updatedId else { return }
        // Re-read the latest data from the shared dataStore
        if let fresh = dataStore.savedMemories.first(where: { $0.id == updatedId }) {
            self.memory = fresh
            displayMemoryData()
        }
    }

    private func setupUI() {
        whiteimgView.layer.cornerRadius = 12
        
        image.layer.cornerRadius = 12
        image.clipsToBounds = true
        image.contentMode = .scaleAspectFill
        
        // Disable interactions for viewing
        memoryTitle.isEnabled = false
        descriptionTextView.isEditable = false
        descriptionTextView.isSelectable = true
        
        // Allow the text view to scroll if the description is long
        descriptionTextView.isScrollEnabled = true
        descriptionTextView.backgroundColor = .clear
    }

    private func displayMemoryData() {
        guard let data = memory else { return }
        
        // Map Title
        memoryTitle.text = data.title
        
        //  Map Description
        if data.description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            descriptionTextView.text = "No additional notes for this memory."
            descriptionTextView.textColor = .label
        } else {
            descriptionTextView.text = data.description
            descriptionTextView.textColor = .label
        }
        
        //  Map Image
        image.image = MemoryFileManager.loadImage(fileName: data.imageName)
                   ?? data.uiImage
                   ?? UIImage(named: data.imageName)
        
        //  Map Location
        let hasNoLocation = data.location.isEmpty || data.location == "Add Location...."
        // hasLocation contains boolean value
        locationView.isHidden = hasNoLocation
        locationLabel.text = data.location
        
        // Map Date
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        datePickerLabel.setTitle(formatter.string(from: data.date), for: .normal)
        
        descriptionTextView.invalidateIntrinsicContentSize()
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
    }

    @IBAction func closeButtonTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
}
