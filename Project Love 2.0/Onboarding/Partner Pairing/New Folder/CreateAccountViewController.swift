import UIKit
import Supabase

class CreateAccountViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var TFView: [UIView]!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var confirmPasswordTF: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    
    let spinner = UIActivityIndicatorView(style: .large)
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        spinner.center = view.center
        spinner.hidesWhenStopped = true
        view.addSubview(spinner)
        
        passwordTF.isSecureTextEntry = true
        confirmPasswordTF.isSecureTextEntry = true
        signUpButton.layer.cornerRadius = 14
        
        setupPasswordToggle(for: passwordTF)
        setupPasswordToggle(for: confirmPasswordTF)
        
        // Delegates
        emailTF.delegate = self
        passwordTF.delegate = self
        confirmPasswordTF.delegate = self

        // Return key styles
        emailTF.returnKeyType = .next
        passwordTF.returnKeyType = .next
        confirmPasswordTF.returnKeyType = .done

        // Tap anywhere to dismiss keyboard
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)

    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
      
        TFView.forEach {
                    $0.layer.cornerRadius = $0.frame.height / 2
                    $0.layer.borderWidth = 1
                    $0.layer.borderColor = UIColor.systemGray6.cgColor
                }
    }
    
    
    @IBAction func signInTapped(_ sender: Any) {
        let vc = UIStoryboard(
                name: "Onboarding",
                bundle: nil
            ).instantiateViewController(
                withIdentifier: "SignInViewController"
            ) as! SignInViewController
            
            navigationController?.pushViewController(vc, animated: true)
    }
    

    @IBAction func signUpTapped(_ sender: UIButton) {
        guard let email = emailTF.text,
                   let password = passwordTF.text,
                   let confirm = confirmPasswordTF.text else { return }

             guard password == confirm else {
                 showAlert("Passwords do not match")
                 return
             }
        spinner.startAnimating()
             Task { await signUpUser(email: email, password: password) }
    }

    func signUpUser(email: String, password: String) async {
        do {
            let response = try await SupabaseManager.shared.client.auth.signUp(
                email: email,
                password: password
            )

            if response.user.identities?.isEmpty == true {
                DispatchQueue.main.async {
                    self.spinner.stopAnimating()

                    self.showAlert("Account already exists.\nPlease sign in instead.")
                }
                return
            }

            let user = response.user

            DispatchQueue.main.async {
                self.spinner.stopAnimating()
                let vc = UIStoryboard(name: "Onboarding", bundle: nil)
                    .instantiateViewController(withIdentifier: "tellUsAboutYourselfViewController") as! tellUsAboutYourselfViewController

                vc.userId = user.id
                self.navigationController?.pushViewController(vc, animated: true)
            }

        } catch {
            DispatchQueue.main.async {
                self.spinner.stopAnimating()
                self.showAlert("Signup failed.\n\(error.localizedDescription)")
            }
        }
    }
    func setupPasswordToggle(for textField: UITextField) {
        let button = UIButton(type: .custom)
        let configuration = UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)
        let image = UIImage(systemName: "eye.slash", withConfiguration: configuration)
        
        button.setImage(image, for: .normal)
        button.setImage(UIImage(systemName: "eye", withConfiguration: configuration), for: .selected)
        button.tintColor = .placeholderText
        
        // Adjust frame/padding
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        
        // Add action
        button.addTarget(self, action: #selector(togglePasswordVisibility(_:)), for: .touchUpInside)
        
        textField.rightView = button
        textField.rightViewMode = .always
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTF {
            passwordTF.becomeFirstResponder()
        }
        else if textField == passwordTF {
            confirmPasswordTF.becomeFirstResponder()
        }
        else if textField == confirmPasswordTF {
            textField.resignFirstResponder()
            signUpTapped(signUpButton) // auto trigger signup
        }
        return true
    }
    @objc func togglePasswordVisibility(_ sender: UIButton) {
        sender.isSelected.toggle()
        
        // Find which textfield this button belongs to
        if let textField = [passwordTF, confirmPasswordTF].first(where: { $0?.rightView == sender }) {
            textField?.isSecureTextEntry.toggle()
            
            // Hack to prevent cursor jump or font glitches in some iOS versions
            if let existingText = textField?.text {
                textField?.text = nil
                textField?.text = existingText
            }
        }
    }
    
    
    func showAlert(_ message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Error",
                                          message: message,
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }
}
