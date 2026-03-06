import UIKit
import Supabase

class EnterCodeViewController: UIViewController {

    @IBOutlet weak var hiddenTextField: UITextField!
    @IBOutlet weak var codeCollectionView: UICollectionView!
    
    var enteredCode: String = ""
    let maxDigits = 6
    let supabase = SupabaseManager.shared.client
    let spinner = UIActivityIndicatorView(style: .large)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupTextField()
        
        spinner.center = view.center
        spinner.hidesWhenStopped = true
        view.addSubview(spinner)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
        
    }
    
    func codeCompleted(_ code: String) {
        hiddenTextField.resignFirstResponder()
        Task {
            await pairWithCode(code)
        }
    }
    func pairWithCode(_ code: String) async {
        do {
            let response = try await supabase
                .rpc("pair_with_code", params: ["p_code": code.uppercased()])
                .execute()

            // if function returns uuid:
            let relationshipId = try JSONDecoder().decode(UUID.self, from: response.data)
            print("Paired relationship:", relationshipId)

            showSuccess()
        } catch {
            showError("Pairing failed: \(error.localizedDescription)")
        }
    }

    func showError(_ message: String) {
        self.spinner.stopAnimating()
        self.view.isUserInteractionEnabled = true
                
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    func showSuccess() {
        UserDefaults.standard.set(true, forKey: "hasCompletedPairing")
        DispatchQueue.main.async {
            self.spinner.stopAnimating()
            self.view.isUserInteractionEnabled = true

            let alert = UIAlertController(
                title: "Paired ❤️",
                message: "You are now connected!",
                preferredStyle: .alert
            )

            alert.addAction(UIAlertAction(title: "Continue", style: .default) { _ in
                
                let storyboard = UIStoryboard(name: "Onboarding", bundle: nil)
                
                guard let vc = storyboard.instantiateViewController(withIdentifier: "infoPageViewController") as? infoPageViewController else {
                    print("❌ Could not instantiate infoPageViewController")
                    return
                }
                
                if let nav = self.navigationController {
                    nav.pushViewController(vc, animated: true)
                } else {
                    self.present(vc, animated: true)
                }
            })

            self.present(alert, animated: true)
        }
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
            spinner.startAnimating()
                codeCompleted(enteredCode)
            } else {
                showError("Enter full 6-digit code")
            }
    }
    
    @IBAction func skipTapped(_ sender: Any) {
        print("Skip tapped")
        UserDefaults.standard.set(true, forKey: "hasCompletedPairing")
        spinner.stopAnimating()
        view.isUserInteractionEnabled = true
            
            // Optional: Save skip state
        UserDefaults.standard.set(true, forKey: "didSkipPairing")
            
        let storyboard = UIStoryboard(name: "Onboarding", bundle: nil)
            
        guard let vc = storyboard.instantiateViewController(
                withIdentifier: "infoPageViewController"
            ) as? infoPageViewController else {
                print("❌ Could not instantiate infoPageViewController")
                return
            }
            
            if let nav = navigationController {
                nav.pushViewController(vc, animated: true)
            } else {
                present(vc, animated: true)
            }
        
    }
    
}

extension EnterCodeViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Handles the "Done" button tap on keyboard
        textField.resignFirstResponder()
        return true
    }
}

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

extension EnterCodeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Keeping your original sizes
        return CGSize(width: 52, height: 60)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 12
    }
}
