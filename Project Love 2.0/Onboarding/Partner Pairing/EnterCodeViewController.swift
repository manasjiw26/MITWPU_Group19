//
//  EnterCodeViewController.swift
//  Project Love 2.0
//
//  Created by SDC-USER on 27/11/25.
//

import UIKit

class EnterCodeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    var codeDigits = ["", "", "", "", "", ""]
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return codeDigits.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EnterCodeCell", for: indexPath) as! EnterCodeCollectionViewCell
        
        cell.enterCodeLabel.text = codeDigits[indexPath.item]
        
        return cell
    }
    

    @IBOutlet weak var hiddenTextField: UITextField!
    
    
    @IBOutlet weak var codeCollectionView: UICollectionView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let nib = UINib(nibName: "EnterCodeCollectionViewCell", bundle: nil)
        codeCollectionView.register(nib, forCellWithReuseIdentifier: "EnterCodeCell")
        
        codeCollectionView.delegate = self
        codeCollectionView.dataSource = self
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(focusTextField))
        view.addGestureRecognizer(tap)

        
        // Do any additional setup after loading the view.
        
//        hiddenTextField.becomeFirstResponder()
//        hiddenTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        
        
        //confirming the outlet is correctly connected
        print("hiddenTextField:", hiddenTextField as Any)

        
    }
    
    @objc func textDidChange(_ textField: UITextField) {
        let text = textField.text ?? ""
        
        // Limit to 6 characters
        if text.count > 6 {
            textField.text = String(text.prefix(6))
        }
        
        // Update array
        for i in 0..<6 {
            if i < text.count {
                let index = text.index(text.startIndex, offsetBy: i)
                codeDigits[i] = String(text[index])
            } else {
                codeDigits[i] = ""
            }
        }
        
        codeCollectionView.reloadData()
        
        // When user types all digits → call validation
        if text.count == 6 {
            codeCompleted(String(text.prefix(6)))
        }
    }
    
    func codeCompleted(_ code: String) {
        print("Entered Code:", code)
        
        // For now just show an alert
        let alert = UIAlertController(title: "Code Entered", message: code, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    
    @objc func focusTextField() {
        hiddenTextField.becomeFirstResponder()
    }

    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}

extension EnterCodeViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 52, height: 60)   // Figma-perfect size
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 12   // space between boxes
    }
}
