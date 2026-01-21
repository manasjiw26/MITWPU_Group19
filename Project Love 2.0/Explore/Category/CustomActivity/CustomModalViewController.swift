//  CustomModalViewController.swift
import UIKit

class CustomModalViewController: UIViewController {

    @IBOutlet weak var customImage: UIImageView!
    @IBOutlet weak var customTitle: UILabel!
    @IBOutlet weak var customDesc: UILabel!
    @IBOutlet weak var doneCustom: UIButton!
    @IBOutlet weak var backTapped: UIButton!
    
    // Properties to hold passed data
    var activityName: String?
    var activityDescription: String?
    var imageName: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        // This line ensures the description from WriteActivityVC finally appears on screen
            customDesc.text = activityDescription
            
            customTitle.text = activityName
            if let img = imageName {
                customImage.image = UIImage(named: img)
            }
        // Configure Buttons
        backTapped.configuration = .glass()
        doneCustom.configuration = .glass()
        doneCustom.setTitle("Done", for: .normal)
        backTapped.setImage(UIImage(systemName: "chevron.left", withConfiguration: UIImage.SymbolConfiguration(weight: .medium)), for: .normal)
        
        // Load passed data into UI
        customTitle.text = activityName
        customDesc.text = activityDescription
        if let img = imageName {
            customImage.image = UIImage(named: img)
        }
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func doneAction(_ sender: Any) {
        self.dismiss(animated: true)
    }
}
