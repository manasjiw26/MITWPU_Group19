//
//  tellUsAboutYourselfViewController.swift
//  Project Love 2.0
//
//  Created by SDC-USER on 01/12/25.
//

import UIKit
import Supabase

class tellUsAboutYourselfViewController: UIViewController {
    
    @IBOutlet weak var firstNameTF: UITextField!
    @IBOutlet weak var birthDateTF: UITextField!
    @IBOutlet weak var firstNameContainerView: UIView!
    @IBOutlet weak var birthDateContainerView: UIView!
    @IBOutlet weak var getStartedButton: UIButton!
    
    var userId: UUID?
    let spinner = UIActivityIndicatorView(style: .large)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textboxUi()
        
        let datePicker = UIDatePicker()
        
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(dateChanged(datePicker:)), for: UIControl.Event.valueChanged)
        datePicker.frame.size = CGSize(width: 0, height: 300)
        datePicker.preferredDatePickerStyle = .wheels
        
        birthDateTF.inputView = datePicker
  
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        spinner.center = view.center
        spinner.hidesWhenStopped = true
        view.addSubview(spinner)
        
        
    }
    
    @IBAction func getStartedTapped(_ sender: Any) {
        guard let name = firstNameTF.text, !name.isEmpty,
                  let dobString = birthDateTF.text, !dobString.isEmpty else {
                showAlert("All fields are required")
                return
            }

            guard let userId = userId else { return }

            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yyyy"

            guard let dobDate = formatter.date(from: dobString) else {
                showAlert("Invalid date")
                return
            }

            if Calendar.current.isDateInToday(dobDate) {
                showAlert("Date of birth cannot be today")
                return
            }

            let age = Calendar.current.dateComponents([.year], from: dobDate, to: Date()).year ?? 0

            if age < 18 {
                showAlert("You must be at least 18 years old")
                return
            }

            spinner.startAnimating()
        Task { await saveProfile(userId: userId, name: name, dob: dobDate) }
    }
        
    func saveProfile(userId: UUID, name: String, dob: Date) async {
        do {
            let user = DBUser(
                user_id: userId,
                name: name,
                profile_image: nil,
                created_at: Date(),
                birth_date: dob,
                partner_id: nil,
                relationship_id: nil
            )
            
            try await SupabaseManager.shared.client
                .from("users")
                .insert(user)
                .execute()
            
            DispatchQueue.main.async {
                self.spinner.stopAnimating()
                let vc = UIStoryboard(name: "Onboarding", bundle: nil)
                    .instantiateViewController(withIdentifier: "assesmentBeginViewController") as! assesmentBeginViewController
                
                vc.userId = userId
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
        } catch {
            DispatchQueue.main.async {
                self.spinner.stopAnimating()
                print("INSERT ERROR:", error)
                self.showAlert("Failed to save profile")
            }
        }
    }
        
        @objc func dismissKeyboard() {
            view.endEditing(true)
        }
        
        @objc func dateChanged(datePicker: UIDatePicker ) {
            
            birthDateTF.text = formatDate(datePicker.date)
        }
        
        func formatDate(_ date: Date) -> String {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yyyy"
            return formatter.string(from: date)
        }
        
        
        func textboxUi(){
            
            firstNameContainerView.layer.cornerRadius = 25
            firstNameContainerView.layer.masksToBounds = true
            
            firstNameContainerView.backgroundColor = UIColor.white
            birthDateContainerView.layer.cornerRadius = birthDateContainerView.frame.height / 2
            birthDateContainerView.layer.masksToBounds = false
            
            birthDateContainerView.backgroundColor = UIColor.white
        }
    func showAlert(_ message: String) {
        let alert = UIAlertController(title: "Error",
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
        
}
