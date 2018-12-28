//
//  EmailTextFieldBulletinItem.swift
//  Contacts
//
//  Created by Johnny Perdomo on 12/26/18.
//  Copyright © 2018 Johnny Perdomo. All rights reserved.
//

import UIKit
import BLTNBoard

class EmailTextFieldBulletinItem: BLTNPageItem {
    
    @objc public var textField: UITextField!
    
    @objc public var textInputHandler: ((BLTNActionItem, String?) -> Void)? = nil
    
    override func makeViewsUnderDescription(with interfaceBuilder: BLTNInterfaceBuilder) -> [UIView]? {
        textField = interfaceBuilder.makeTextField(placeholder: "eleven@strangerthings.com", returnKey: .done, delegate: self)
        textField.keyboardType = UIKeyboardType.emailAddress
        return [textField]
    }
    
    override func tearDown() {
        super.tearDown()
        textField?.delegate = nil
    }
    
    override func actionButtonTapped(sender: UIButton) {
        textField.resignFirstResponder()
        super.actionButtonTapped(sender: sender)
        print("tapped")
    }
    
}

// MARK: - UITextFieldDelegate
extension EmailTextFieldBulletinItem: UITextFieldDelegate {
    
    @objc open func isInputValid(text: String?) -> Bool {
        
        if text == nil || text!.isEmpty {
            return false
        }
        
        return true
        
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if isInputValid(text: textField.text) {
            textInputHandler?(self, textField.text)
        } else {
            descriptionLabel!.textColor = .red
            descriptionLabel!.text = "You must enter some text to continue."
            textField.backgroundColor = UIColor.red.withAlphaComponent(0.3)
        }
    }
}
