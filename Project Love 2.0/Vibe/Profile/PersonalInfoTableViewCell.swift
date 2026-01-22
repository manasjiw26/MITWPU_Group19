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
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
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

