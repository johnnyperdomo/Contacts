//
//  CreateContactVC.swift
//  Contacts
//
//  Created by Johnny Perdomo on 12/19/18.
//  Copyright © 2018 Johnny Perdomo. All rights reserved.
//

import UIKit
import CoreData

class ProfileVC: UIViewController {
    
    //MARK: Variables, Constants, Arrays ------------------------------------------------------------
    
    private var isNameLblHidden = Bool()
    private var isModifyBtnHidden = Bool()
    private var isDateLblHidden = Bool()
    private var isFirstNameTextFieldHidden = Bool()
    private var isLastNameTextFieldHidden = Bool()
    private var isDateOfBirthTextFieldHidden = Bool()
    private var isSaveBtnHidden = Bool()
    private var isBackBtnHidden = Bool()
    private var isCancelBtnHidden = Bool()
    private var isChangeImageBtnHidden = Bool()
    private var isFavoritesIconImgHidden = Bool()
    private var isFavoritesIconShadowViewHidden = Bool()
    private var isFavoritesLblHidden = Bool()
    private var isFavoritesBtnHidden = Bool()
    
    private var firstNameString = String()
    private var lastNameString = String()
    private var dateOfBirthString = String()
    private var profileImage = UIImage()
    
    private var phoneNumberArray = [String]()
    private var emailArray = [String]()
    private var addressArray = [String]()
    
    private var userDataArray: [Int : [String]] = [0: [], 1: [], 2: []] //to store user data -> 0: phone, 1: email, 2: address
    private var profileType: ProfileTypeEnum!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupProfileVC()
    }
    
    //MARK: IBOutlets -----------------------------------------------------------------------------
    
    @IBOutlet weak private var profileTableView: UITableView!
    @IBOutlet weak private var backgroundTableview: CustomUIViewTopRounded!
    @IBOutlet weak private var firstNameTxtField: UITextField!
    @IBOutlet weak private var lastNameTxtField: UITextField!
    @IBOutlet weak private var dateOfBirthTextField: UITextField!
    @IBOutlet weak private var modifyBtn: UIButton!
    @IBOutlet weak private var nameLbl: UILabel!
    @IBOutlet weak private var dateOfBirthLbl: UILabel!
    @IBOutlet weak private var saveBtn: UIButton!
    @IBOutlet weak private var cancelBtn: UIButton!
    @IBOutlet weak private var backBtn: UIButton!
    @IBOutlet weak private var profileImg: UIImageView!
    @IBOutlet weak private var changeImageBtn: UIButton!
    @IBOutlet weak private var favoritesLbl: UILabel!
    @IBOutlet weak private var favoritesBtn: UIButton!
    @IBOutlet weak private var favoritesIconImg: UIImageView!
    @IBOutlet weak private var favoritesIconShadowView: CustomUIView!
    
    @IBOutlet weak var backgroundTableViewTopContraint: NSLayoutConstraint!
    //MARK: IBActions -----------------------------------------------------------------------------
    
    @IBAction private func saveBtnPressed(_ sender: Any) {
        
        if profileType == ProfileTypeEnum.createNew {
            
            if firstNameTxtField.text != "" && lastNameTxtField.text != "" && dateOfBirthTextField.text != "" && (userDataArray[0]?.count)! >= 1 && (userDataArray[1]?.count)! >= 1 {
                
                saveProfile(firstName: (firstNameTxtField.text?.capitalized)!, lastName: (lastNameTxtField.text?.capitalized)!, dateOfBirth: dateOfBirthTextField.text!, phoneNumbers: userDataArray[0]!, emails: userDataArray[1]!, addresses: userDataArray[2]!, profileImage: profileImg.image!) { (complete) in
                    
                    if complete {
                        guard let contactsVC = storyboard?.instantiateViewController(withIdentifier: "ContactsVC") else { return }
                        self.present(contactsVC, animated: true)
                    } else {
                        print("error saving")
                    }
                }
                
            } else {
                print("complete text fields")
            }
            
        } else {
            
            modifyProfileInfo(searchFirstName: firstNameString, searchLastName: lastNameString, searchDateOfBirth: dateOfBirthString, newFirstName: firstNameTxtField.text!, newLastName: lastNameTxtField.text!, newDateOfBirth: dateOfBirthTextField.text!, newProfileImage: profileImg.image!, newPhonenumbers: userDataArray[0]!, newEmails: userDataArray[1]!, newAddresses: userDataArray[2]!) { (complete) in
            
                if complete {
                    guard let contactsVC = storyboard?.instantiateViewController(withIdentifier: "ContactsVC") else { return }
                    self.present(contactsVC, animated: true)
                } else {
                    print("error saving")
                }
            }
        }
    }
    
    @IBAction private func changeImageBtnPressed(_ sender: Any) {
        let picker = UIImagePickerController()
        
        picker.delegate = self
        picker.allowsEditing = true
        
        present(picker, animated: true, completion: nil)
    }
    
    @IBAction private func modifyProfileBtnPressed(_ sender: Any) {
        
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
        
        favoritesBtn.isHidden = false
        favoritesLbl.isHidden = false
        favoritesIconImg.isHidden = true
        favoritesIconShadowView.isHidden = true
        
        backgroundTableViewTopContraint.constant = 40
        
        firstNameTxtField.text = firstNameString
        lastNameTxtField.text = lastNameString
        dateOfBirthTextField.text = dateOfBirthString
    }
    
    @IBAction private func cancelBtnPressed(_ sender: Any) {
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
        
        favoritesBtn.isHidden = true
        favoritesLbl.isHidden = true
        
//        favoritesIconImg.isHidden = true
//        favoritesIconShadowView.isHidden = true
        
        backgroundTableViewTopContraint.constant = -10
        
        nameLbl.text = "\(firstNameString) \(lastNameString)"
        dateOfBirthLbl.text = "Birthday: \(dateOfBirthString) 🎉"
    }
    
    @IBAction private func backBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func favoritesBtnPressed(_ sender: Any) {
        
    }
    
    //MARK: VC Functions -----------------------------------------------------------------------------
    
    func initProfileView(firstName: String = "", lastName: String = "", dateOfBirth: String = "", profileImage: UIImage = UIImage(named: "personPlaceholder")!, phoneNumbers: [String] = [], emails: [String] = [], addresses: [String] = [], profileType: ProfileTypeEnum) {
        
        userDataArray[0] = phoneNumbers
        userDataArray[1] = emails
        userDataArray[2] = addresses
        
        self.profileType = profileType
        
        switch profileType {
        case .createNew:
            
            self.isNameLblHidden = true
            self.isDateLblHidden = true
            self.isModifyBtnHidden = true

            self.isFirstNameTextFieldHidden = false
            self.isLastNameTextFieldHidden = false
            self.isDateOfBirthTextFieldHidden = false
            self.isSaveBtnHidden = false
            self.isChangeImageBtnHidden = false
            
            self.isFavoritesLblHidden = false
            self.isFavoritesBtnHidden = false
            self.isFavoritesIconImgHidden = true
            self.isFavoritesIconShadowViewHidden = true
            
            self.profileImage = profileImage
            
        case .view:
            
            self.isNameLblHidden = false
            self.isDateLblHidden = false
            self.isModifyBtnHidden = false
            
            self.isFirstNameTextFieldHidden = true
            self.isLastNameTextFieldHidden = true
            self.isDateOfBirthTextFieldHidden = true
            self.isSaveBtnHidden = true
            self.isChangeImageBtnHidden = true
            
            self.isFavoritesLblHidden = true
            self.isFavoritesBtnHidden = true
            
            self.firstNameString = firstName
            self.lastNameString = lastName
            self.dateOfBirthString = dateOfBirth
            self.profileImage = profileImage
        }
    }
    
    private func setupProfileVC() {
        firstNameTxtField.delegate = self
        lastNameTxtField.delegate = self
        dateOfBirthTextField.delegate = self
        
        profileTableView.delegate = self
        profileTableView.dataSource = self
        
        if profileType == ProfileTypeEnum.createNew {
            backgroundTableViewTopContraint.constant = 40
        } else if profileType == ProfileTypeEnum.view {
            backgroundTableViewTopContraint.constant = -10
        }
        
        nameLbl.isHidden = isNameLblHidden
        dateOfBirthLbl.isHidden = isDateLblHidden
        firstNameTxtField.isHidden = isFirstNameTextFieldHidden
        lastNameTxtField.isHidden = isLastNameTextFieldHidden
        dateOfBirthTextField.isHidden = isDateOfBirthTextFieldHidden
        saveBtn.isHidden = isSaveBtnHidden
        modifyBtn.isHidden = isModifyBtnHidden
        changeImageBtn.isHidden = isChangeImageBtnHidden
        
        favoritesBtn.isHidden = isFavoritesBtnHidden
        favoritesLbl.isHidden = isFavoritesLblHidden
        favoritesIconImg.isHidden = isFavoritesIconImgHidden
        favoritesIconShadowView.isHidden = isFavoritesIconShadowViewHidden
        
        nameLbl.text = "\(firstNameString) \(lastNameString)"
        dateOfBirthLbl.text = "Birthday: \(dateOfBirthString) 🎉"
        profileImg.image = profileImage
    }
    
    private func appendUserData(text: String, section: Int) {
        
        if var array = userDataArray[section] {
            array.append(text)
            userDataArray[section] = array
        } else {
            userDataArray[section] = [text]
        }
        
        profileTableView.reloadData()
    }
    
    @objc private func callAlertActionForUserData(button: UIButton) {
        
        let alert = UIAlertController(title: "New Value", message: "Add a new Value", preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) {
            [unowned self] action in
            
            guard let textField = alert.textFields?.first,
                let stringText = textField.text else {
                    return
            }
            
            self.appendUserData(text: stringText, section: button.tag)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
        
        alert.addTextField()
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
}

//MARK: Coredata ----------------------------------------------------------------------------

extension ProfileVC {
    
    private func saveProfile(firstName: String, lastName: String, dateOfBirth: String, phoneNumbers: [String], emails: [String], addresses: [String], profileImage: UIImage, completion: (_ complete: Bool) -> ()) {
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
            completion(true)
            print("successfully saved person in core data")
        } catch {
            print("Could not save. \(error.localizedDescription)")
            completion(false)
        }
    }
    
    private func modifyProfileInfo(searchFirstName: String, searchLastName: String, searchDateOfBirth: String, newFirstName: String, newLastName: String, newDateOfBirth: String, newProfileImage: UIImage, newPhonenumbers: [String], newEmails: [String], newAddresses: [String], completion: (_ complete: Bool) -> ()) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<Person>(entityName: "Person")
        
        do {
            
            let results = try managedContext.fetch(request)
            
            if results.count > 0 {
                for result in results as [NSManagedObject] {
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
}

//MARK: TextField ------------------------------------------------------------------------------

extension ProfileVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
}

//MARK: TableView ------------------------------------------------------------------------------

extension ProfileVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return userDataArray.keys.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return (userDataArray[section]?.count)!
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let sectionName = section == 0 ? "Phone Numbers" : section == 1 ? "Email" : "addresses"
        
        let button = UIButton(type: .system)
        button.setTitle(sectionName, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .white
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        
        
        button.addTarget(self, action: #selector(callAlertActionForUserData), for: .touchUpInside)
        
        button.tag = section
        
        return button
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = profileTableView.dequeueReusableCell(withIdentifier: "createProfileCell", for: indexPath) as? CreateProfileCell else { return UITableViewCell() }
        
        
        let value = userDataArray[indexPath.section]
        
        cell.txtLabel.text = value![indexPath.row]
        
        return cell
    }
}

//MARK: Image Picker -----------------------------------------------------------------

extension ProfileVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        var selectedImageFromPicker: UIImage?
        
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
