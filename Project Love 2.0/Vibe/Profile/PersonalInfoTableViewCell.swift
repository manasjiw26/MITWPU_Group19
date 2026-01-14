//
//  PersonalInfoTableViewCell.swift
//  Project Love 2.0
//
//  Created by SDC-USER on 10/01/26.
//

import UIKit

class PersonalInfoTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        valueTextField.textAlignment = .right
        valueTextField.textColor = .secondaryLabel
        valueTextField.delegate = self

    }
    @IBOutlet weak var titleLabel: UILabel!
       @IBOutlet weak var valueTextField: UITextField!

//    func configure(title: String, value: String, isEditing: Bool) {
//        titleLabel.text = title
//        valueTextField.text = value
//
//        valueTextField.isUserInteractionEnabled = isEditing
//
//        valueTextField.borderStyle = .none
//        valueTextField.layer.cornerRadius = 10
//        valueTextField.layer.borderWidth = isEditing ? 1 : 0
//        valueTextField.layer.borderColor = UIColor.systemGray4.cgColor
//        valueTextField.backgroundColor = isEditing ? .systemBackground : .clear
//    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func configure(title: String,
                   value: String?,
                   isEditing: Bool,
                   showsChevron: Bool) {

        titleLabel.text = title

        if showsChevron {
            valueTextField.isHidden = true
            accessoryType = .disclosureIndicator
            selectionStyle = .default
            return
        }
       
        valueTextField.isHidden = false
        valueTextField.text = value
        valueTextField.textAlignment = .right
        valueTextField.isUserInteractionEnabled = isEditing
        valueTextField.textColor = isEditing ? .systemBlue : .secondaryLabel
        valueTextField.layer.borderWidth = 0
        valueTextField.backgroundColor = .clear
        accessoryType = .none
        selectionStyle = .none

        valueTextField.borderStyle = .none
        valueTextField.layer.borderWidth = 0
        valueTextField.backgroundColor = .clear

        
        if isEditing {
            valueTextField.becomeFirstResponder()
        }
    }


}
extension PersonalInfoTableViewCell: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.textColor = .secondaryLabel
        if isEditing {
            valueTextField.becomeFirstResponder()
        }

    }
}

