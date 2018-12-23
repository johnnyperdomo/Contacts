//
//  CreateContactVC.swift
//  Contacts
//
//  Created by Johnny Perdomo on 12/19/18.
//  Copyright © 2018 Johnny Perdomo. All rights reserved.
//

import UIKit
import CoreData

class CreateProfileVC: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        firstNameTxtField.delegate = self
        lastNameTxtField.delegate = self
        dateOfBirthTextField.delegate = self
        
        createProfileTableView.delegate = self
        createProfileTableView.dataSource = self
        
        nameLbl.isHidden = isNameLblHidden
        dateOfBirthLbl.isHidden = isDateLblHidden
        firstNameTxtField.isHidden = isFirstNameTextFieldHidden
        lastNameTxtField.isHidden = isLastNameTextFieldHidden
        dateOfBirthTextField.isHidden = isDateOfBirthTextFieldHidden
        saveBtn.isHidden = isSaveBtnHidden
        modifyBtn.isHidden = isModifyBtnHidden
        changeImageBtn.isHidden = isChangeImageBtnHidden
        
        nameLbl.text = "\(firstNameString) \(lastNameString)"
        dateOfBirthLbl.text = "Birthday: \(dateOfBirthString) 🎉"
        profileImg.image = profileImage
    }
    
    var valueArrays: [Int : [String]] = [0: [], 1: [], 2: []]
    var isNameLblHidden = Bool()
    var isModifyBtnHidden = Bool()
    var isDateLblHidden = Bool()
    var isFirstNameTextFieldHidden = Bool()
    var isLastNameTextFieldHidden = Bool()
    var isDateOfBirthTextFieldHidden = Bool()
    var isSaveBtnHidden = Bool()
    var isBackBtnHidden = Bool()
    var isCancelBtnHidden = Bool()
    var isChangeImageBtnHidden = Bool()
    
    var firstNameString = String()
    var lastNameString = String()
    var dateOfBirthString = String()
    var profileImage = UIImage()
    
    var phoneNumberArray = [String]()
    var emailArray = [String]()
    var addressArray = [String]()
    
    var profileType: ProfileTypeEnum!
    
    @IBOutlet weak var createProfileTableView: UITableView!
    
    @IBOutlet weak var firstNameTxtField: UITextField!
    @IBOutlet weak var lastNameTxtField: UITextField!
    @IBOutlet weak var dateOfBirthTextField: UITextField!
    @IBOutlet weak var modifyBtn: UIButton!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var dateOfBirthLbl: UILabel!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var changeImageBtn: UIButton!
    
    
    @IBAction func saveBtnPressed(_ sender: Any) {
        
        print(profileType)
        if profileType == ProfileTypeEnum.createNew {
            
            if firstNameTxtField.text != "" && lastNameTxtField.text != "" && dateOfBirthTextField.text != "" && (valueArrays[0]?.count)! >= 1 && (valueArrays[1]?.count)! >= 1 {
                
                saveProfile(firstName: (firstNameTxtField.text?.capitalized)!, lastName: (lastNameTxtField.text?.capitalized)!, dateOfBirth: dateOfBirthTextField.text!, phoneNumbers: valueArrays[0]!, emails: valueArrays[1]!, addresses: valueArrays[2]!, profileImage: profileImg.image!) { (complete) in
                    
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
            
        } else {
            
            modifyProfileInfo(searchFirstName: firstNameString, searchLastName: lastNameString, searchDateOfBirth: dateOfBirthString, newFirstName: firstNameTxtField.text!, newLastName: lastNameTxtField.text!, newDateOfBirth: dateOfBirthTextField.text!, newProfileImage: profileImg.image!, newPhonenumbers: valueArrays[0]!, newEmails: valueArrays[1]!, newAddresses: valueArrays[2]!) { (complete) in
            
                if complete {
                    guard let contactsVC = storyboard?.instantiateViewController(withIdentifier: "ContactsVC") else { return } //to create identifier to move between views
                    self.present(contactsVC, animated: true)
                } else {
                    print("error saving")
                }
            }
            
        }
        
        
        
        
    }
    
    @IBAction func changeImageBtnPressed(_ sender: Any) {
        let picker = UIImagePickerController()
        
        picker.delegate = self
        picker.allowsEditing = true
        
        present(picker, animated: true, completion: nil)
    }
    
    @IBAction func modifyProfileBtnPressed(_ sender: Any) {
        
        nameLbl.isHidden = true
        dateOfBirthLbl.isHidden = true
        firstNameTxtField.isHidden = false
        lastNameTxtField.isHidden = false
        dateOfBirthTextField.isHidden = false
        
        modifyBtn.isHidden = true
        backBtn.isHidden = true
        
        saveBtn.isHidden = false
        cancelBtn.isHidden = false
        changeImageBtn.isHidden = false
        
        firstNameTxtField.text = firstNameString
        lastNameTxtField.text = lastNameString
        dateOfBirthTextField.text = dateOfBirthString
    }
    
    @IBAction func cancelBtnPressed(_ sender: Any) {
        nameLbl.isHidden = false
        dateOfBirthLbl.isHidden = false
        firstNameTxtField.isHidden = true
        lastNameTxtField.isHidden = true
        dateOfBirthTextField.isHidden = true
        
        modifyBtn.isHidden = false
        backBtn.isHidden = false
        
        saveBtn.isHidden = true
        cancelBtn.isHidden = true
        changeImageBtn.isHidden = true
        
        nameLbl.text = "\(firstNameString) \(lastNameString)"
        dateOfBirthLbl.text = dateOfBirthString
        
    }
    
    
    @IBAction func backBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func initProfileView(firstName: String = "", lastName: String = "", dateOfBirth: String = "", profileImage: UIImage = UIImage(named: "personPlaceholder")!, phoneNumbers: [String] = [], emails: [String] = [], addresses: [String] = [], profileType: ProfileTypeEnum) {
        
        valueArrays[0] = phoneNumbers
        valueArrays[1] = emails
        valueArrays[2] = addresses
        
        self.profileType = profileType
        
        switch profileType {
        case .createNew:
            print("create new")
            self.isNameLblHidden = true
            self.isDateLblHidden = true
            self.isModifyBtnHidden = true

            self.isFirstNameTextFieldHidden = false
            self.isLastNameTextFieldHidden = false
            self.isDateOfBirthTextFieldHidden = false
            self.isSaveBtnHidden = false
            self.isChangeImageBtnHidden = false
            
            self.profileImage = profileImage
        case .view:
            print("view")
            
            self.isNameLblHidden = false
            self.isDateLblHidden = false
            self.isModifyBtnHidden = false
            
            self.isFirstNameTextFieldHidden = true
            self.isLastNameTextFieldHidden = true
            self.isDateOfBirthTextFieldHidden = true
            self.isSaveBtnHidden = true
            self.isChangeImageBtnHidden = true
            
            self.firstNameString = firstName
            self.lastNameString = lastName
            self.dateOfBirthString = dateOfBirth
            self.profileImage = profileImage
     //       modifyProfileInfo(searchFirstName: firstName, searchLastName: lastName)
        }
    }

    func modifyProfileInfo(searchFirstName: String, searchLastName: String, searchDateOfBirth: String, newFirstName: String, newLastName: String, newDateOfBirth: String, newProfileImage: UIImage, newPhonenumbers: [String], newEmails: [String], newAddresses: [String], completion: (_ complete: Bool) -> ()) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<Person>(entityName: "Person")
            
        do {
            
            let results = try managedContext.fetch(request)
            
            if results.count > 0 {
                for result in results as! [NSManagedObject] {
                    if let firstName = result.value(forKey: "firstName") as? String, let lastName = result.value(forKey: "lastName") as? String, let dateOfBirth = result.value(forKey: "dateOfBirth") as? String {
                        if firstName == searchFirstName && lastName == searchLastName && dateOfBirth == searchDateOfBirth {
                            
                            let profileImageData: Data = newProfileImage.pngData()!
                            
                            result.setValue(newFirstName, forKey: "firstName")
                            result.setValue(newLastName, forKey: "lastName")
                            result.setValue(newDateOfBirth, forKey: "dateOfBirth")
                            result.setValue(profileImageData, forKey: "profileImage")
                            result.setValue(newPhonenumbers, forKey: "phoneNumbers")
                            result.setValue(newEmails, forKey: "emails")
                            result.setValue(newAddresses, forKey: "addresses")
                            
                            do {
                                
                                try managedContext.save()
                                completion(true)
                             //   print(results)
                            } catch {
                                print("couldn't save profile")
                                completion(false)
                            }
                        }
                    }
                }
            }
            
        } catch {
            print("couldn't get core data results")
        }
    }
    
    
    func saveProfile(firstName: String, lastName: String, dateOfBirth: String, phoneNumbers: [String], emails: [String], addresses: [String], profileImage: UIImage, completion: (_ complete: Bool) -> ()) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let person = Person(context: managedContext)
        
        let profileImageData: Data = profileImage.pngData()!
        
        person.firstName = firstName
        person.lastName = lastName
        person.dateOfBirth = dateOfBirth
        person.profileImage = profileImageData
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
        button.backgroundColor = .white
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
extension CreateProfileVC {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        var selectedImageFromPicker: UIImage? //to see if we selected an image
        
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] {
            selectedImageFromPicker = editedImage as? UIImage
            
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] {
            selectedImageFromPicker = originalImage as? UIImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            profileImg.image = selectedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
}
