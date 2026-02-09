//
//  signUpWithEmailViewController.swift
//  Project Love 2.0
//
//  Created by SDC-USER on 04/02/26.
//

import UIKit

// MARK: - Custom Rounded TextField
// Including this here fixes the "Cannot find VibeTextField in scope" error
class VibeTextField: UITextField {
    private let padding = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)

    init(placeholder: String, isSecure: Bool) {
        super.init(frame: .zero)
        self.placeholder = placeholder
        self.isSecureTextEntry = isSecure
        self.backgroundColor = .white
        self.layer.cornerRadius = 20
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.systemGray6.cgColor
        self.textColor = .vibeDarkText
        self.autocapitalizationType = .none
        self.translatesAutoresizingMaskIntoConstraints = false
        
        // Add subtle shadow
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowRadius = 4
        self.layer.shadowOpacity = 0.05
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func textRect(forBounds bounds: CGRect) -> CGRect { return bounds.inset(by: padding) }
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect { return bounds.inset(by: padding) }
    override func editingRect(forBounds bounds: CGRect) -> CGRect { return bounds.inset(by: padding) }
}

// MARK: - Color Extensions
// Including this here fixes the "Type 'UIColor' has no member..." errors
extension UIColor {
    static let vibeLightBackground = UIColor(red: 248/255, green: 248/255, blue: 252/255, alpha: 1.0)
    static let vibePurpleAccent = UIColor(red: 160/255, green: 135/255, blue: 215/255, alpha: 1.0)
    static let vibeDarkText = UIColor(red: 30/255, green: 30/255, blue: 40/255, alpha: 1.0)
}

// MARK: - View Controller
class signUpWithEmailViewController: UIViewController {

    // MARK: - UI Components
    
    private let backButton: UIButton = {
        let btn = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .bold)
        btn.setImage(UIImage(systemName: "arrow.left", withConfiguration: config), for: .normal)
        btn.tintColor = .vibeDarkText
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private let headerLabel: UILabel = {
        let label = UILabel()
        label.text = "Create Account"
        if let descriptor = UIFont.systemFont(ofSize: 32, weight: .bold).fontDescriptor.withDesign(.rounded) {
            label.font = UIFont(descriptor: descriptor, size: 32)
        }
        label.textColor = .vibeDarkText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let subheaderLabel: UILabel = {
        let label = UILabel()
        label.text = "Join Project Love and start connecting."
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let nameField = VibeTextField(placeholder: "Full Name", isSecure: false)
    private let emailField = VibeTextField(placeholder: "Email", isSecure: false)
    private let passwordField = VibeTextField(placeholder: "Password", isSecure: true)

    private let signUpButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.backgroundColor = .vibePurpleAccent
        btn.setTitle("Create Account", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        if let descriptor = UIFont.systemFont(ofSize: 18, weight: .bold).fontDescriptor.withDesign(.rounded) {
            btn.titleLabel?.font = UIFont(descriptor: descriptor, size: 18)
        }
        btn.layer.cornerRadius = 25
        btn.translatesAutoresizingMaskIntoConstraints = false
        
        // Shadow for the button
        btn.layer.shadowColor = UIColor.vibePurpleAccent.cgColor
        btn.layer.shadowOffset = CGSize(width: 0, height: 4)
        btn.layer.shadowRadius = 8
        btn.layer.shadowOpacity = 0.3
        return btn
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .vibeLightBackground
        setupLayout()
        setupActions()
    }

    private func setupLayout() {
        view.addSubview(backButton)
        view.addSubview(headerLabel)
        view.addSubview(subheaderLabel)
        view.addSubview(nameField)
        view.addSubview(emailField)
        view.addSubview(passwordField)
        view.addSubview(signUpButton)

        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            headerLabel.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 20),
            headerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),

            subheaderLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 8),
            subheaderLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),

            nameField.topAnchor.constraint(equalTo: subheaderLabel.bottomAnchor, constant: 40),
            nameField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            nameField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            nameField.heightAnchor.constraint(equalToConstant: 60),

            emailField.topAnchor.constraint(equalTo: nameField.bottomAnchor, constant: 16),
            emailField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            emailField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            emailField.heightAnchor.constraint(equalToConstant: 60),

            passwordField.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 16),
            passwordField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            passwordField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            passwordField.heightAnchor.constraint(equalToConstant: 60),

            signUpButton.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 40),
            signUpButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            signUpButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            signUpButton.heightAnchor.constraint(equalToConstant: 55)
        ])
    }

    private func setupActions() {
        backButton.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
        signUpButton.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
    }

    @objc private func handleBack() {
        dismiss(animated: true)
    }

    @objc private func handleSignUp() {
        guard let name = nameField.text, !name.isEmpty,
              let email = emailField.text, !email.isEmpty,
              let password = passwordField.text, !password.isEmpty else {
            alertUser(message: "Please fill in all fields")
            return
        }

        // --- Mock Database Logic ---
        UserDefaults.standard.set(name, forKey: "userName")
        UserDefaults.standard.set(email, forKey: "userEmail")
        UserDefaults.standard.set(password, forKey: "userPassword")
        UserDefaults.standard.set(true, forKey: "isLoggedIn")
        
        // Transition to Main App
        guard let window = view.window else { return }
        // Note: Ensure your main screen is named 'ViewController' or change it here
        let mainVC = ViewController()
        
        UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: {
            window.rootViewController = UINavigationController(rootViewController: mainVC)
        })
    }
    
    private func alertUser(message: String) {
        let alert = UIAlertController(title: "Oops!", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
