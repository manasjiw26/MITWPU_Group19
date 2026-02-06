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
    
    private func setupCollectionView() {
        let nib = UINib(nibName: "EnterCodeCollectionViewCell", bundle: nil)
        codeCollectionView.register(nib, forCellWithReuseIdentifier: "EnterCodeCell")
        
        codeCollectionView.delegate = self
        codeCollectionView.dataSource = self
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(focusTextField))
        view.addGestureRecognizer(tap)
    }
    
    private func setupTextField() {
        hiddenTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        hiddenTextField.keyboardType = .asciiCapable
        hiddenTextField.textContentType = .oneTimeCode
    }

    @objc func textDidChange(_ textField: UITextField) {
        let text = textField.text?.uppercased() ?? ""
        
        if text.count > maxDigits {
            textField.text = String(text.prefix(maxDigits))
            return
        }
        
        enteredCode = text
        codeCollectionView.reloadData()
        
        // Auto-action when full
        if enteredCode.count == maxDigits {
            codeCompleted(enteredCode)
        }
    }
    
    func codeCompleted(_ code: String) {
        // No alert here!
        // This is where you call your server or navigate to the next screen.
        print("Final Code ready for pairing: \(code)")
    }
    
    @objc func focusTextField() {
        hiddenTextField.becomeFirstResponder()
    }
    
    @IBAction func pairWithPartnerButton(_ sender: Any) {
        // This button can now just call codeCompleted as well
        if enteredCode.count == maxDigits {
            codeCompleted(enteredCode)
        }
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
        return CGSize(width: 52, height: 60)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 12
    }
}
