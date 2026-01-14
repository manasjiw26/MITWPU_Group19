import UIKit
import PhotosUI

class memoryDisplay: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var locationView: UIView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var datePickerLabel: UIButton!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var whiteimgView: UIView!
    
    @IBOutlet weak var memoryTitle: UITextField!
    // MARK: - Data Property
    // This will hold the memory passed from your previous screen
    var memory: Memory?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        displayMemoryData()
    }

    private func setupUI() {
        // Visual Styling
        whiteimgView.layer.cornerRadius = 12
        whiteimgView.clipsToBounds = true
        
        image.layer.cornerRadius = 12
        image.clipsToBounds = true
        image.contentMode = .scaleAspectFill
        
        // MAKE NON-EDITABLE: Disable interactions
        image.isUserInteractionEnabled = false
        locationView.isUserInteractionEnabled = false
        datePickerLabel.isUserInteractionEnabled = false
        
        descriptionTextView.isEditable = false // User cannot type
        descriptionTextView.isSelectable = true
        descriptionTextView.text = memory?.subtitle
        // User can still copy text if they want
        descriptionTextView.isScrollEnabled = true
    }

    private func displayMemoryData() {
        guard let memory = memory else { return }
        
        // Fill the UI with the memory data
        if memory.location == nil || memory.location == "" || memory.location == "Add Location...." {
                locationView.isHidden = true
            } else {
                locationView.isHidden = false
            }
        locationLabel.text = memory.location
        image.image = memory.uiImage
        datePickerLabel.setTitle(memory.subtitle, for: .normal)
        descriptionTextView.text = memory.title // Or use description if you added that field
        memoryTitle.text = memory.title
        memoryTitle.textColor = .secondaryLabel
        // If the description is empty, hide the text view or show a default message
        if memory.title.isEmpty {
            descriptionTextView.text = "No description added for this memory."
            descriptionTextView.textColor = .secondaryLabel
        } else {
            descriptionTextView.textColor = .label
        }
    }

    @IBAction func closeButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func doneButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
