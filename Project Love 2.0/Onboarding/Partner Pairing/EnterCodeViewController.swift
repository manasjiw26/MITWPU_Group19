import UIKit

class EnterCodeViewController: UIViewController {

    @IBOutlet weak var hiddenTextField: UITextField!
    @IBOutlet weak var codeCollectionView: UICollectionView!
    
    var enteredCode: String = ""
    let maxDigits = 6
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupTextField()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // CRITICAL: Call this here so the view is in the window hierarchy
        hiddenTextField.becomeFirstResponder()
    }
    
    private func setupCollectionView() {
        let nib = UINib(nibName: "EnterCodeCollectionViewCell", bundle: nil)
        codeCollectionView.register(nib, forCellWithReuseIdentifier: "EnterCodeCell")
        
        codeCollectionView.delegate = self
        codeCollectionView.dataSource = self
        
        // Background tap to toggle keyboard
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleScreenTap))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    private func setupTextField() {
        hiddenTextField.delegate = self
        hiddenTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        
        // Configuration
        hiddenTextField.keyboardType = .asciiCapable
        hiddenTextField.textContentType = .oneTimeCode
        hiddenTextField.returnKeyType = .done
        hiddenTextField.autocorrectionType = .no
        
        // Ensure alpha is 0.01 (Invisible to user, visible to iOS focus system)
        hiddenTextField.alpha = 0.01
    }

    @objc func textDidChange(_ textField: UITextField) {
        let text = textField.text?.uppercased() ?? ""
        
        if text.count > maxDigits {
            textField.text = String(text.prefix(maxDigits))
            return
        }
        
        enteredCode = text
        codeCollectionView.reloadData()
        
        if enteredCode.count == maxDigits {
            codeCompleted(enteredCode)
        }
    }
    
    func codeCompleted(_ code: String) {
        print("Final Code ready for pairing: \(code)")
        // You could dismiss keyboard here if the process is finished
        // hiddenTextField.resignFirstResponder()
    }
    
    @objc func handleScreenTap() {
        if hiddenTextField.isFirstResponder {
            hiddenTextField.resignFirstResponder()
        } else {
            hiddenTextField.becomeFirstResponder()
        }
    }
    
    @IBAction func pairWithPartnerButton(_ sender: Any) {
        if enteredCode.count == maxDigits {
            codeCompleted(enteredCode)
        }
    }
}

// MARK: - TextField Delegate
extension EnterCodeViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Handles the "Done" button tap on keyboard
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - CollectionView Data Source
extension EnterCodeViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return maxDigits
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EnterCodeCell", for: indexPath) as! EnterCodeCollectionViewCell
        
        let chars = Array(enteredCode)
        cell.enterCodeLabel.text = indexPath.item < chars.count ? String(chars[indexPath.item]) : ""
        
        return cell
    }
}

// MARK: - CollectionView Layout
extension EnterCodeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Keeping your original sizes
        return CGSize(width: 52, height: 60)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 12
    }
}
