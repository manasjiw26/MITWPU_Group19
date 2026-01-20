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
    
    @IBOutlet weak var descriptionActivity: UITextField!
    
    @IBOutlet weak var dateText: UITextField!
    
    @IBOutlet weak var calenderImage: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        backtapped.configuration = .glass()
        saveTapped.configuration = .glass()
        saveTapped.setTitle("Save", for: .normal)
        let chevronImage = UIImage(
               systemName: "chevron.left"
           )?.withRenderingMode(.alwaysTemplate)

           backtapped.setImage(chevronImage, for: .normal)
           backtapped.setTitle("", for: .normal)   // No text, icon only
           backtapped.tintColor = .label
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
}
