//
//  ViewController.swift
//  Contacts
//
//  Created by Johnny Perdomo on 12/18/18.
//  Copyright © 2018 Johnny Perdomo. All rights reserved.
//

import UIKit
import CoreData
import Lottie

class ContactsVC: UIViewController {

    //MARK: Variables, Constants, Arrays ------------------------------------------------------------
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    private let indexLetters = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
    private var indexLettersInContactsArray = [String]()
    
    private var namesArray = [String]()
    private var contactImagesArray = [UIImage]()
    
    private var personArray: [Person] = []
    private var filteredPersonArray: [Person] = []
    
    private var contactNamesDictionary = [String: [String]]()
    private var contactImagesDictionary = [String: UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        setUpNavBar()
        fetchCoreData()
    }
    
    //MARK: IBOutlets -----------------------------------------------------------------------------
    
    @IBOutlet weak private var animationView: LOTAnimationView!
    @IBOutlet weak private var animationViewLbl: UILabel!
    @IBOutlet weak private var tableView: UITableView!
    
    //MARK: IBActions -----------------------------------------------------------------------------
    
    @IBAction private func createContactBtnPressed(_ sender: Any) {
        let profileVC = storyboard?.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC//to create identifier to move between views
        profileVC.initProfileView(profileType: .createNew)
        present(profileVC, animated: true, completion: nil)
    }
    
    //MARK: VC Functions -----------------------------------------------------------------------------

    private func setUpNavBar() {
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.title = "Contacts"
        
        let favoriteBtnItem = UIBarButtonItem(image: UIImage(named: "starUnfilled"), style: .plain, target: self, action: #selector(showFavoriteContacts))
        favoriteBtnItem.tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        
        let sortBtnItem = UIBarButtonItem(image: UIImage(named: "sortIcon"), style: .plain, target: self, action: #selector(sortContactsByType))
        sortBtnItem.tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        
        self.navigationItem.searchController = searchController
        self.navigationItem.hidesSearchBarWhenScrolling = false
        
        self.navigationItem.rightBarButtonItem = sortBtnItem
        self.navigationItem.leftBarButtonItem = favoriteBtnItem
        
        searchController.searchResultsUpdater = self as UISearchResultsUpdating
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
    }
    
     private func startAnimationLoaderForCreateContact() {
        animationView.setAnimation(named: "AddContactLoader")
        animationView.loopAnimation = true
        animationView.isHidden = false
        animationViewLbl.text = "No Contacts Yet. Add your first contact by tapping the button below."
        animationViewLbl.isHidden = false
        animationView.play()
        
        navigationItem.searchController = nil
        tableView.isHidden = true
    }
    
    private func stopAnimationLoader() {
        animationView.isHidden = true
        animationViewLbl.isHidden = true
        animationView.stop()
        navigationItem.searchController = searchController
        tableView.isHidden = false
    }
    
    private func startAnimationLoaderNoSearches() {
        animationView.setAnimation(named: "NoSearches")
        animationView.loopAnimation = true
        animationView.isHidden = false
        animationViewLbl.text = "Oops, can't seem to find any matches."
        animationViewLbl.isHidden = false
        animationView.play()
        
        tableView.isHidden = true
    }
    
    private func createNameDictionary() {
        
        contactNamesDictionary.removeAll()
        for name in namesArray {
            
            let firstLetter = "\(name[name.startIndex])"
            let uppercasedLetter = firstLetter.uppercased()
            
            if var separateNamesArray = contactNamesDictionary[uppercasedLetter] { //check if key already exists
                separateNamesArray.append(name)
                contactNamesDictionary[uppercasedLetter] = separateNamesArray
            } else {
                contactNamesDictionary[uppercasedLetter] = [name]
            }
        }
        
        indexLettersInContactsArray = [String](contactNamesDictionary.keys)
        indexLettersInContactsArray = indexLettersInContactsArray.sorted()
    }
    
    @objc private func showFavoriteContacts() {
        print("favorites Contact Btn pressed")
    }
    
    @objc private func sortContactsByType() {
        print("sort contacts btn pressed")
    }
}

//MARK: Coredata ----------------------------------------------------------------------------

extension ContactsVC {
    
    private func fetchCoreData() {
        fetchContacts { (complete) in
            
            namesArray.removeAll()
            contactImagesArray.removeAll()
            
            if complete {
                
                if personArray.isEmpty {
                    startAnimationLoaderForCreateContact()
                } else {
                    stopAnimationLoader()
                }
                
                personArray = personArray.sorted(by: { (a, b) -> Bool in
                    return a.firstName! < b.firstName!
                })
                
                for i in personArray {
                    let fullName = "\(i.firstName!) \(i.lastName!)"
                    //          let fullName = "\(i.lastName!) \(i.firstName!)"
                    let image = UIImage(data: i.profileImage!)
                    
                    namesArray.append(fullName)
                    contactImagesDictionary[fullName] = image
                }
                createNameDictionary()
            } else {
                print("error fetched core data")
            }
        }
    }
    
    private func fetchContacts(completion: (_ complete: Bool) -> ()) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<Person>(entityName: "Person")
        
        do {
            personArray = try managedContext.fetch(fetchRequest)
            
            print("fetched data")
            completion(true)
        } catch {
            print("error fetching data")
            completion(false)
        }
    }
    
    private func removeContact(atIndexPath indexPath: IndexPath) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        var rowNumber = indexPath.row
        for i in 0..<indexPath.section {
            rowNumber += self.tableView.numberOfRows(inSection: i)
        }
        
        managedContext.delete(personArray[rowNumber])
        namesArray.remove(at: rowNumber)
        
        do { //save the managed context to update everything
            try managedContext.save()
            
            print("successfully removed Contact")
        } catch {
            debugPrint("Could not remove: \(error.localizedDescription)")
        }
    }
}

//MARK: TableView ------------------------------------------------------------------------------

extension ContactsVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "contactCell", for: indexPath) as? ContactsCell else { return UITableViewCell() }
        
        var attributedText = NSAttributedString()
        var contactImage = UIImage()
        
        if searchController.isActive && searchController.searchBar.text != "" {
            if let firstName = filteredPersonArray[indexPath.row].firstName?.capitalized, let lastName = filteredPersonArray[indexPath.row].lastName?.capitalized, let profileImage = filteredPersonArray[indexPath.row].profileImage {
                let text = "\(firstName) \(lastName)"
                let image = UIImage(data: profileImage)
                
                let range = (text.lowercased() as NSString).range(of: (searchController.searchBar.text?.lowercased())!)
                
                let attributedString = NSMutableAttributedString(string: text)
                attributedString.addAttribute(NSAttributedString.Key.backgroundColor, value: UIColor.yellow, range: range)
                attributedString.addAttribute(NSAttributedString.Key.font, value: UIFont(name: "AvenirNext-DemiBold", size: 20)!, range: range)
                
                attributedText = attributedString
                contactImage = image!
            }
            
        } else {
            
            let letter = indexLettersInContactsArray[indexPath.section]
            
            if var names = contactNamesDictionary[letter.uppercased()] {
                names = names.sorted()
                
                let text = names[indexPath.row]
                let attributedString = NSMutableAttributedString(string: text)
                attributedText = attributedString
                
                let image = contactImagesDictionary[text]
                
                contactImage = image!
            }
        }
        
        cell.contactImage.image = contactImage
        cell.contactName.attributedText = attributedText
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        var count = Int()
        
        if searchController.isActive && searchController.searchBar.text != "" {
            count = 1
        } else {
            count = contactNamesDictionary.keys.count
        }
        
        return count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var count = Int()
        
        if searchController.isActive && searchController.searchBar.text != "" {
            count = filteredPersonArray.count
        } else {
            let letter = indexLettersInContactsArray[section]
            
            if let names = contactNamesDictionary[letter] {
                count = names.count
            }
        }
        
        return count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let indexPath = tableView.indexPathForSelectedRow
        
        var rowNumber = indexPath!.row
        for i in 0..<indexPath!.section {
            rowNumber += self.tableView.numberOfRows(inSection: i)
        }
        
        //        personArray = personArray.sorted(by: { (a, b) -> Bool in
        //            return a.firstName! > b.firstName!
        //        })
        
        let fullName = "\(personArray[rowNumber].firstName!) \(personArray[rowNumber].lastName!)"
        //     let fullName = "\(personArray[rowNumber].lastName!) \(personArray[rowNumber].firstName!)"
        
        let firstName = personArray[rowNumber].firstName
        let lastName = personArray[rowNumber].lastName
        let dateOfBirth = personArray[rowNumber].dateOfBirth
        let phoneNumbers = personArray[rowNumber].phoneNumbers
        let emails = personArray[rowNumber].emails
        let addresses = personArray[rowNumber].addresses
        let contactImage = contactImagesDictionary[fullName]
        
        let profileVC = self.storyboard?.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
        profileVC.initProfileView(firstName: firstName!, lastName: lastName!, dateOfBirth: dateOfBirth!, profileImage: contactImage!, phoneNumbers: phoneNumbers as! [String], emails: emails as! [String], addresses: addresses as! [String], profileType: .view)
        
        present(profileVC, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        if searchController.isActive && searchController.searchBar.text != "" {
            return false
        }
        
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            let sortedDict = contactNamesDictionary.sorted { $0.key < $1.key }
            let dictKey = Array(sortedDict[indexPath.section].key)
            
            let arrayCount = contactNamesDictionary[String(dictKey)]?.count
            
            if arrayCount == 1 { //if sections doesn't contain values, delete section header
                
                self.removeContact(atIndexPath: indexPath)
                self.fetchCoreData()
                tableView.beginUpdates()
                tableView.deleteRows(at: [indexPath], with: .automatic)
                
                let indexSet = NSMutableIndexSet()
                indexSet.add(indexPath.section)
                
                tableView.deleteSections(indexSet as IndexSet, with: .automatic)
                tableView.endUpdates()
                
            } else {
                
                self.removeContact(atIndexPath: indexPath)
                self.fetchCoreData()
                
                tableView.beginUpdates()
                tableView.deleteRows(at: [indexPath], with: .automatic)
                tableView.endUpdates()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        var sectionTitle = String()
        
        if searchController.isActive && searchController.searchBar.text != "" {
            sectionTitle = "Top Name Matches"
        } else {
            //         indexLettersInContactsArray = indexLettersInContactsArray.sorted(by: {$0 > $1})
            sectionTitle = indexLettersInContactsArray[section]
        }
        
        return sectionTitle
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return indexLetters
    }
}

//MARK: Searchbar ------------------------------------------------------------------------

extension ContactsVC: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContacts(text: searchController.searchBar.text!)
        
       if searchController.isActive && searchController.searchBar.text != "" {
        
            if filteredPersonArray.isEmpty {
                startAnimationLoaderNoSearches()
            } else {
                stopAnimationLoader()
            }
        
       } else {
            stopAnimationLoader()
        }
    }
    
    private func filterContacts(text: String, scope: String = "All") {
        
        filteredPersonArray = personArray.filter({ (person) -> Bool in
            
            let fullName = "\(person.firstName?.lowercased() ?? "") \(person.lastName?.lowercased() ?? "")"
            
            return fullName.contains(text.lowercased())
        })
        
        tableView.reloadData()
    }
}
