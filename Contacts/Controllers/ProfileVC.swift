//
//  CreateContactVC.swift
//  Contacts
//
//  Created by Johnny Perdomo on 12/19/18.
//  Copyright © 2018 Johnny Perdomo. All rights reserved.
//

import UIKit
import CoreData
import SwiftMessages
import BLTNBoard

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
    private var isTableViewEditable = Bool()
    
    private var firstNameString = String()
    private var lastNameString = String()
    private var dateOfBirthString = String()
    private var profileImage = UIImage()
    
    private var phoneNumberArray = [String]()
    private var emailArray = [String]()
    private var addressArray = [String]()
    
    private var datePicker = UIDatePicker()
    
    private var userDataArray: [Int : [String]] = [0: [], 1: [], 2: []] //to store user data -> 0: phone, 1: email, 2: address
    
    private var profileType: ProfileTypeEnum!
    private var isFavorite: IsFavoriteEnum!
    private var initialIsFavoriteValue: IsFavoriteEnum!
    
    private var userDataButtonInfo = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupProfileVC()
    }
    
    //MARK: Bulletin Items -----------------------------------------------------------------------------
    
    lazy var phoneNumberBulletin: BLTNItemManager = {
        
        let page = PhoneTextFieldBulletinItem(title: "Phone Number")
        page.descriptionText = "Enter a phone number"
        page.actionButtonTitle = "Enter"
        page.alternativeButtonTitle = "Close"
        
        page.actionHandler = { (item: BLTNActionItem) in
            
            var numberString = page.textField.text!
            
            if self.isPhoneNumberValid(numberString) == false {
                self.showIncorrectPhoneNumberErrorCard()
                return
            }
            
            numberString.insert("-", at: numberString.index(numberString.startIndex, offsetBy: 3))
            numberString.insert("-", at: numberString.index(numberString.startIndex, offsetBy: 7))
            print(numberString)
            
            print("Action button tapped")
           
        }
        
        page.alternativeHandler = { (item: BLTNActionItem) in
            self.dismissPhoneNumberBoard()
        }
        
        let item: BLTNItem = page
        item.isDismissable = true
        item.requiresCloseButton = false
        return BLTNItemManager(rootItem: item)
    }()
    
    lazy var emailBulletin: BLTNItemManager = {
        
        let page = EmailTextFieldBulletinItem(title: "Email")
        page.descriptionText = "Enter an email."
        page.actionButtonTitle = "Enter"
        page.alternativeButtonTitle = "Close"
        
        page.actionHandler = { (item: BLTNActionItem) in
            
            if self.isEmailValid(page.textField.text!) == false {
                self.showIncorrectEmailFormatErrorCard()
                return
            }
            
            self.dismissEmailBoard()
            print(page.textField.text)
            print(self.userDataButtonInfo.tag)
            
            
            print("Action button tapped")
        }
        page.alternativeHandler = { (item: BLTNActionItem) in
            self.dismissEmailBoard()
        }
        
        let item: BLTNItem = page
        item.isDismissable = true
        item.requiresCloseButton = false
        return BLTNItemManager(rootItem: item)
    }()
    
    lazy var addressBulletin: BLTNItemManager = {
        
        let page = AddressTextFieldBulletinItem(title: "Address")
        page.descriptionText = "Enter a work or home address."
        page.actionButtonTitle = "Enter"
        page.alternativeButtonTitle = "Close"

        page.actionHandler = { (item: BLTNActionItem) in
            
            print("Action button tapped")
        }
        
        page.alternativeHandler = { (item: BLTNActionItem) in
            self.dismissAddressBoard()
        }
        
        let item: BLTNItem = page
        item.isDismissable = true
        item.requiresCloseButton = false
        return BLTNItemManager(rootItem: item)
    }()
    
    
    lazy var datePickerBulletin: BLTNItemManager = {
        
        let page = DatePickerBLTNItem(title: "Birthday")
        page.descriptionText = "Enter a date of birth."
        page.actionButtonTitle = "Enter"
        page.alternativeButtonTitle = "Close"
        
        page.actionHandler = { (item: BLTNActionItem) in
            
            self.dateChanged(datePicker: page.datePicker)
            self.dismissDatePickerBoard()
        }
        
        page.alternativeHandler = { (item: BLTNActionItem) in
            self.dismissDatePickerBoard()
        }
        
        let item: BLTNItem = page
        item.isDismissable = true
        item.requiresCloseButton = false
        return BLTNItemManager(rootItem: item)
    }()
    
    //MARK: IBOutlets -----------------------------------------------------------------------------
    
    @IBOutlet weak private var profileTableView: UITableView!
    @IBOutlet weak private var backgroundTableview: CustomUIViewTopRounded!
    @IBOutlet weak private var backgroundTableViewTopContraint: NSLayoutConstraint!
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
    
    //MARK: IBActions -----------------------------------------------------------------------------
    
    @IBAction private func saveBtnPressed(_ sender: Any) {
        
        if profileType == ProfileTypeEnum.createNew {
            
            if firstNameTxtField.text != "" && lastNameTxtField.text != "" && dateOfBirthTextField.text != "" && (userDataArray[0]?.count)! >= 1 && (userDataArray[1]?.count)! >= 1 {
                
                
                if isPhoneNumberValid(userDataArray[0]![0]) == false {
                    showIncorrectPhoneNumberErrorCard()
                    return
                }
                
                saveProfile(firstName: (firstNameTxtField.text?.capitalized)!, lastName: (lastNameTxtField.text?.capitalized)!, dateOfBirth: dateOfBirthTextField.text!, phoneNumbers: userDataArray[0]!, emails: userDataArray[1]!, addresses: userDataArray[2]!, profileImage: profileImg.image!, isFavoritePerson: isFavorite) { (complete) in
                    
                    if complete {
                        guard let contactsVC = storyboard?.instantiateViewController(withIdentifier: "ContactsVC") else { return }
                        self.present(contactsVC, animated: true)
                    } else {
                        print("error saving")
                    }
                }
                
            } else {
                showIncompleteFieldsErrorCard()
            }
            
        } else {
            
            var isFavoriteBool = Bool()
            
            if isFavorite == .no {
                isFavoriteBool = false
            } else if isFavorite == .yes {
                isFavoriteBool = true
            }
            
            if firstNameTxtField.text != "" && lastNameTxtField.text != "" && dateOfBirthTextField.text != "" && (userDataArray[0]?.count)! >= 1 && (userDataArray[1]?.count)! >= 1 {
            
                modifyProfileInfo(searchFirstName: firstNameString, searchLastName: lastNameString, searchDateOfBirth: dateOfBirthString, newFirstName: firstNameTxtField.text!, newLastName: lastNameTxtField.text!, newDateOfBirth: dateOfBirthTextField.text!, newProfileImage: profileImg.image!, newPhonenumbers: userDataArray[0]!, newEmails: userDataArray[1]!, newAddresses: userDataArray[2]!, newIsFavoritePerson: isFavoriteBool ) { (complete) in
                
                    if complete {
                        guard let contactsVC = storyboard?.instantiateViewController(withIdentifier: "ContactsVC") else { return }
                        self.present(contactsVC, animated: true)
                    } else {
                        print("error saving")
                    }
                }
                
            } else {
                showIncompleteFieldsErrorCard()
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
        
        isTableViewEditable = true
        
        favoritesBtn.isHidden = false
        favoritesLbl.isHidden = false
        favoritesIconImg.isHidden = true
        favoritesIconShadowView.isHidden = true
        
        if initialIsFavoriteValue == .no {
  
            favoritesBtn.setImage(UIImage(named: "starUnfilled"), for: .normal)
            favoritesLbl.text = "Add to favorites"
            
        } else if initialIsFavoriteValue == .yes {
            
            favoritesBtn.setImage(UIImage(named: "starFilled"), for: .normal)
            favoritesLbl.text = "Remove from favorites"
        }
        
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
        
        isTableViewEditable = false
        
        favoritesBtn.isHidden = true
        favoritesLbl.isHidden = true
        
        if initialIsFavoriteValue == .no {
            isFavorite = initialIsFavoriteValue
            
            favoritesIconImg.isHidden = true
            favoritesIconShadowView.isHidden = true
            
            favoritesBtn.setImage(UIImage(named: "starUnfilled"), for: .normal)
            favoritesLbl.text = "Add to favorites"
            
        } else if initialIsFavoriteValue == .yes {
            isFavorite = initialIsFavoriteValue
            
            favoritesIconImg.isHidden = false
            favoritesIconShadowView.isHidden = false
            
            favoritesBtn.setImage(UIImage(named: "starFilled"), for: .normal)
            favoritesLbl.text = "Remove from favorites"
        }
        
        backgroundTableViewTopContraint.constant = -10
        
        nameLbl.text = "\(firstNameString) \(lastNameString)"
        dateOfBirthLbl.text = "Birthday: \(dateOfBirthString) 🎉"
    }
    
    @IBAction private func backBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func favoritesBtnPressed(_ sender: Any) {
        
        addFavoritePerson(isFavoritePerson: isFavorite)
    }
    
    //MARK: VC Functions -----------------------------------------------------------------------------
    
    func initProfileView(firstName: String = "", lastName: String = "", dateOfBirth: String = "", profileImage: UIImage = UIImage(named: "personPlaceholder")!, phoneNumbers: [String] = [], emails: [String] = [], addresses: [String] = [], profileType: ProfileTypeEnum, isFavorite: IsFavoriteEnum = .no) {
        
        userDataArray[0] = phoneNumbers
        userDataArray[1] = emails
        userDataArray[2] = addresses
        
        self.profileType = profileType
        self.isFavorite = isFavorite
        self.initialIsFavoriteValue = isFavorite
        
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
            
            self.isTableViewEditable = true
            
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
            
            self.isTableViewEditable = false
            
            self.isFavoritesLblHidden = true
            self.isFavoritesBtnHidden = true
            
            switch isFavorite {
            case .no:
                self.isFavoritesIconImgHidden = true
                self.isFavoritesIconShadowViewHidden = true
            case .yes:
                self.isFavoritesIconImgHidden = false
                self.isFavoritesIconShadowViewHidden = false
            }
            
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
    
     private func dateChanged(datePicker: UIDatePicker) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        
        dateOfBirthTextField.text = dateFormatter.string(from: datePicker.date)
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
    
    @objc private func addUserDataText(button: UIButton) {
        
        userDataButtonInfo = button
        
        if button.tag == 0 {
             phoneNumberBulletin.showBulletin(above: self)
        } else if button.tag == 1 {
            emailBulletin.showBulletin(above: self)
        } else if button.tag == 2 {
            addressBulletin.showBulletin(above: self)
        }
        
//        let alert = UIAlertController(title: "New Value", message: "Add a new Value", preferredStyle: .alert)
//
//        let saveAction = UIAlertAction(title: "Save", style: .default) {
//            [unowned self] action in
//
//            guard let textField = alert.textFields?.first,
//                let stringText = textField.text else {
//                    return
//            }
//
//            self.appendUserData(text: stringText, section: button.tag)
//        }
//
//        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
//
//        alert.addTextField()
//
//        alert.addAction(saveAction)
//        alert.addAction(cancelAction)
//
//        present(alert, animated: true)
    }
    
    private func addFavoritePerson(isFavoritePerson: IsFavoriteEnum) {

        switch isFavoritePerson {
        case .no:
            isFavorite = .yes
            favoritesBtn.setImage(UIImage(named: "starFilled"), for: .normal)
            favoritesLbl.text = "Remove from favorites"
        case .yes:
            isFavorite = .no
            favoritesBtn.setImage(UIImage(named: "starUnfilled"), for: .normal)
            favoritesLbl.text = "Add to favorites"
        }
    }
}

//MARK: Validations, Error Cards, Boards  ----------------------------------------------------------------------------

extension ProfileVC {
    
    private func isEmailValid(_ email: String) -> Bool {
        
        do {
            if try NSRegularExpression(pattern: "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}$", options: .caseInsensitive).firstMatch(in: email, options: [], range: NSRange(location: 0, length: email.count)) == nil {
                return false
            }
        } catch {
            return false
        }
        return true
    }
    
    func isPhoneNumberValid(_ phoneNumber: String) -> Bool {
        
        if phoneNumber.count < 10 {
            return false
        }
        
        var number = phoneNumber
        
        number.insert("-", at: number.index(number.startIndex, offsetBy: 3))
        number.insert("-", at: number.index(number.startIndex, offsetBy: 7))

        let regex = "^\\d{3}-\\d{3}-\\d{4}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", regex)
        let result =  phoneTest.evaluate(with: number)
        return result
        
    }
    
    private func showIncompleteFieldsErrorCard() {
        
        let view = MessageView.viewFromNib(layout: .cardView)
        
        view.configureTheme(.error)
        
        view.configureDropShadow()
        
        view.button?.isHidden = true
        let iconText = "😕"
        view.configureContent(title: "Incomplete Fields", body: "Make sure to fill out all the information, addresses are optional.", iconText: iconText)
        SwiftMessages.show(view: view)
    }
    
    private func showIncorrectPhoneNumberErrorCard() {
        let view = MessageView.viewFromNib(layout: .cardView)
        
        view.configureTheme(.error)
        
        view.configureDropShadow()
        
        view.button?.isHidden = true
        let iconText = "📱"
        view.configureContent(title: "Incorrect Phone Number", body: "Please enter a valid phone number.", iconText: iconText)
        SwiftMessages.show(view: view)
    }
    
    private func showIncorrectEmailFormatErrorCard() {
        let view = MessageView.viewFromNib(layout: .cardView)
        
        view.configureTheme(.error)
        
        view.configureDropShadow()
        
        view.button?.isHidden = true
        let iconText = "✉️"
        view.configureContent(title: "Incorrect Email Format", body: "Please enter a valid email.", iconText: iconText)
        SwiftMessages.show(view: view)
    }
    
    private func dismissDatePickerBoard() {
        datePickerBulletin.dismissBulletin()
    }
    
    private func dismissPhoneNumberBoard() {
        phoneNumberBulletin.dismissBulletin()
    }
    
    private func dismissEmailBoard() {
        emailBulletin.dismissBulletin()
    }
    
    private func dismissAddressBoard() {
        addressBulletin.dismissBulletin()
    }
}

//MARK: Coredata ----------------------------------------------------------------------------

extension ProfileVC {
    
    private func saveProfile(firstName: String, lastName: String, dateOfBirth: String, phoneNumbers: [String], emails: [String], addresses: [String], profileImage: UIImage, isFavoritePerson: IsFavoriteEnum, completion: (_ complete: Bool) -> ()) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let person = Person(context: managedContext)
        
        let profileImageData: Data = profileImage.pngData()!
        
        var isFavoriteBool = Bool()
        
        if isFavoritePerson == .no {
            isFavoriteBool = false
        } else if isFavoritePerson == .yes {
            isFavoriteBool = true
        }
        
        person.firstName = firstName
        person.lastName = lastName
        person.dateOfBirth = dateOfBirth
        person.profileImage = profileImageData
        person.phoneNumbers = phoneNumbers as NSObject
        person.emails = emails as NSObject
        person.addresses = addresses as NSObject
        person.isFavorite = isFavoriteBool
        
        do {
            try managedContext.save()
            completion(true)
            print("successfully saved person in core data")
        } catch {
            print("Could not save. \(error.localizedDescription)")
            completion(false)
        }
    }
    
    private func modifyProfileInfo(searchFirstName: String, searchLastName: String, searchDateOfBirth: String, newFirstName: String, newLastName: String, newDateOfBirth: String, newProfileImage: UIImage, newPhonenumbers: [String], newEmails: [String], newAddresses: [String], newIsFavoritePerson: Bool,  completion: (_ complete: Bool) -> ()) {
        
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
                            result.setValue(newIsFavoritePerson, forKey: "isFavorite")
                            
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
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if textField == dateOfBirthTextField {
            datePickerBulletin.showBulletin(above: self)
            return false
        }
        
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
        
        button.addTarget(self, action: #selector(addUserDataText), for: .touchUpInside)
        
        button.tag = section
        
        return button
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = profileTableView.dequeueReusableCell(withIdentifier: "createProfileCell", for: indexPath) as? CreateProfileCell else { return UITableViewCell() }
        
        
        let value = userDataArray[indexPath.section]
        
        cell.txtLabel.text = value![indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        if isTableViewEditable == false {
            return false
        } else {
            return true
        }
    
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            var tempArray = userDataArray[indexPath.section]
            tempArray?.remove(at: indexPath.row)
            
            userDataArray[indexPath.section] = tempArray

            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
            
        }
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
