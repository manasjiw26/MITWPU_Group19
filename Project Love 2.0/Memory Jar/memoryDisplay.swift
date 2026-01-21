import UIKit

class memoryDisplay: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var locationView: UIView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var datePickerLabel: UIButton!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var whiteimgView: UIView!
    @IBOutlet weak var memoryTitle: UITextField!
    
    // MARK: - Properties
    var memory: Memory?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        displayMemoryData()
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
        
        // Prevent background color issues
        descriptionTextView.backgroundColor = .clear
    }

    private func displayMemoryData() {
        guard let data = memory else { return }
        
        // 1. Map Title
        memoryTitle.text = data.title
        
        // 2. Map Description (The content that was collapsing)
        if data.description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            descriptionTextView.text = "No additional notes for this memory."
            descriptionTextView.textColor = .secondaryLabel
        } else {
            descriptionTextView.text = data.description
            descriptionTextView.textColor = .label
        }
        
        // 3. Map Image
        image.image = data.uiImage
        
        // 4. Map Location & Handling "Dissolve"
        let hasNoLocation = data.location.isEmpty || data.location == "Add Location...."
        locationView.isHidden = hasNoLocation
        locationLabel.text = data.location
        
        // 5. Map Date (Formatting from Date object)
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        datePickerLabel.setTitle(formatter.string(from: data.date), for: .normal)
        
        // 6. Force Layout - Tells the system to calculate the text height immediately
        descriptionTextView.invalidateIntrinsicContentSize()
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
    }

    // MARK: - Actions
    @IBAction func closeButtonTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
//    @IBAction func doneButton(_ sender: Any) {
//        self.dismiss(animated: true)
//    }
}
