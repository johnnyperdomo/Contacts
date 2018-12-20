//
//  CreateContactVC.swift
//  Contacts
//
//  Created by Johnny Perdomo on 12/19/18.
//  Copyright © 2018 Johnny Perdomo. All rights reserved.
//

import UIKit
import CoreData

class CreateProfileVC: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {

    override func viewDidLoad() {
        super.viewDidLoad()

        firstNameTxtField.delegate = self
        lastNameTxtField.delegate = self
        dateOfBirthTextField.delegate = self
        
        createProfileTableView.delegate = self
        createProfileTableView.dataSource = self
        
    }
    
    var valueArrays: [Int : [String]] = [0: [], 1: [], 2: []]
    
    
    @IBOutlet weak var createProfileTableView: UITableView!
    
    @IBOutlet weak var firstNameTxtField: UITextField!
    @IBOutlet weak var lastNameTxtField: UITextField!
    @IBOutlet weak var dateOfBirthTextField: UITextField!
    
    @IBAction func saveBtnPressed(_ sender: Any) {
        
        if firstNameTxtField.text != "" && lastNameTxtField.text != "" && dateOfBirthTextField.text != "" && (valueArrays[0]?.count)! >= 1 && (valueArrays[1]?.count)! >= 1 {
//            print(firstNameTxtField.text)
//            print(lastNameTxtField.text)
//            print(dateOfBirthTextField.text)
//            print(valueArrays)
//
            saveProfile(firstName: (firstNameTxtField.text?.capitalized)!, lastName: (lastNameTxtField.text?.capitalized)!, dateOfBirth: dateOfBirthTextField.text!, phoneNumbers: valueArrays[0]!, emails: valueArrays[1]!, addresses: valueArrays[2]!) { (complete) in
                
                if complete {
                    guard let contactsVC = storyboard?.instantiateViewController(withIdentifier: "ContactsVC") else { return } //to create identifier to move between views
                    self.present(contactsVC, animated: true)
                } else {
                    print("error saving")
                }
            }
        } else {
            print("complete text fields")
        }
        
        
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func saveProfile(firstName: String, lastName: String, dateOfBirth: String, phoneNumbers: [String], emails: [String], addresses: [String], completion: (_ complete: Bool) -> ()) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let person = Person(context: managedContext)
        
        person.firstName = firstName
        person.lastName = lastName
        person.dateOfBirth = dateOfBirth
        person.phoneNumbers = phoneNumbers as NSObject
        person.emails = emails as NSObject
        person.addresses = addresses as NSObject
        
        do {
            try managedContext.save()
            print("successfully saved person in core data")
            print(person)
            completion(true)
        } catch {
            print("Could not save. \(error.localizedDescription)")
            completion(false)
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let sectionName = section == 0 ? "Phone Numbers" : section == 1 ? "Email" : "addresses"
        
        let button = UIButton(type: .system)
        button.setTitle(sectionName, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .green
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        
        
        button.addTarget(self, action: #selector(addValues), for: .touchUpInside)
        
        button.tag = section
        
        return button
    }
    
    @objc func addValues(button: UIButton) {
        
        let alert = UIAlertController(title: "New Value", message: "Add a new Value", preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) {
            [unowned self] action in
            
            guard let textField = alert.textFields?.first,
                let stringText = textField.text else {
                    return
            }
            
            self.addArrayValue(text: stringText, section: button.tag)
                                        
        }
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .default)
        
        alert.addTextField()
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
        
    }
    
    func addArrayValue(text: String, section: Int) {
        
        if var array = valueArrays[section] {
            array.append(text)
            valueArrays[section] = array
        } else {
            valueArrays[section] = [text]
        }
    
        print(valueArrays)
        createProfileTableView.reloadData()
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return valueArrays.keys.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return (valueArrays[section]?.count)!
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = createProfileTableView.dequeueReusableCell(withIdentifier: "createProfileCell", for: indexPath) as? CreateProfileCell else { return UITableViewCell() }
        
        
        let value = valueArrays[indexPath.section]
        
        cell.txtLabel.text = value![indexPath.row]
        
        return cell
    }
    
    
}
