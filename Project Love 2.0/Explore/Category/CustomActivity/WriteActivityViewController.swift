//
//  WriteActivityViewController.swift
//  Project Love 2.0
//
//  Created by SDC-USER on 20/01/26.
//

import UIKit

class WriteActivityViewController: UIViewController {

    @IBOutlet weak var backtapped: UIButton!
    
    @IBOutlet weak var saveTapped: UIButton!
    
    @IBOutlet weak var activityTitle: UITextField!
    
  
    @IBOutlet weak var descriptionActivity: UITextView!
    
    @IBOutlet weak var dateText: UITextField!
    
    @IBOutlet weak var calenderImage: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        backtapped.configuration = .glass()
        saveTapped.configuration = .glass()
        saveTapped.setTitle("Save", for: .normal)
        backtapped.setImage(UIImage(systemName: "chevron.left", withConfiguration: UIImage.SymbolConfiguration(weight: .medium)), for: .normal)
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
@IBAction func backTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func saveTapped(_ sender: Any) {
        // Capture the text from your descriptionActivity text field
            guard let title = activityTitle.text, !title.isEmpty,
                  let desc = descriptionActivity.text, // This is your 'Description' input
                  let date = dateText.text else { return }
                    
            // 1. Save to DataStore: Ensure 'desc' is passed to the description parameter
            DataStore.shared.addCustomActivity(name: title, description: desc, date: date)
                    
            // 2. Dismiss back to Explore
            self.dismiss(animated: true, completion: nil)
        
    }
}
