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
    var indexLettersInContactsArray = [String]()
    
    var namesArray = [String]()
    private var contactImagesArray = [UIImage]()
    
    private var personArray: [Person] = []
    private var filteredPersonArray: [Person] = []
    private var onlyFavoriteContactsArray: [Person] = []
    
    var contactNamesDictionary = [String: [String]]() //i.e. "A" : ["Anakin Skywalker" , "Astro Boy"], "C" : ["Charlie Brown"], "J" : ["Johnny Perdomo", "Jason Vorhees", "Julia Child"]
    private var contactImagesDictionary = [String: UIImage]() //i.e. "Johnny Perdomo" : <<Picture 27, User Picture >>
    private var contactFavoritesDictionary = [String: Bool]() //i.e "Ross Geller" : True, "Joey Tribiani" : False
    
    private var sortOrder: SortOrderEnum = .byFirstName
    private var sortImage: UIImage = UIImage(named: "sortIconFirstName")!
    
    private var showFavoriteContactsOnly: IsFavoriteEnum = .no
    private var showFavoriteContactStarImage: UIImage = UIImage(named: "starUnfilled")!
    
    private var navBarTitle: String = "All Contacts"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contactsTableView.delegate = self
        contactsTableView.dataSource = self
        setUpNavBar()
        fetchCoreData(sortOrderType: sortOrder, isFavorite: showFavoriteContactsOnly)
    }
    
    //MARK: IBOutlets -----------------------------------------------------------------------------
    
    @IBOutlet weak private var animationView: LOTAnimationView!
    @IBOutlet weak private var animationViewLbl: UILabel!
    @IBOutlet weak private var contactsTableView: UITableView!
    
    //MARK: IBActions -----------------------------------------------------------------------------
    
    @IBAction private func createContactBtnPressed(_ sender: Any) {
        let profileVC = storyboard?.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC//to create identifier to move between views
        profileVC.initProfileView(profileType: .createNew)
        present(profileVC, animated: true, completion: nil)
    }
    
    //MARK: VC Functions -----------------------------------------------------------------------------

    private func setUpNavBar() {
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.title = navBarTitle
        
        let favoriteBtnItem = UIBarButtonItem(image: showFavoriteContactStarImage, style: .plain, target: self, action: #selector(showFavoriteContacts))
        favoriteBtnItem.tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        
        let sortBtnItem = UIBarButtonItem(image: sortImage, style: .plain, target: self, action: #selector(sortContactsByType))
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
        contactsTableView.isHidden = true
    }
    
    private func startAnimationLoaderNoSearches() {
        animationView.setAnimation(named: "NoSearches")
        animationView.loopAnimation = true
        animationView.isHidden = false
        animationViewLbl.text = "Oops, can't seem to find any matches."
        animationViewLbl.isHidden = false
        animationView.play()
        
        contactsTableView.isHidden = true
    }
    
    private func startAnimationLoaderNoFavorites() {
        animationView.setAnimation(named: "Star")
        animationView.loopAnimation = true
        animationView.isHidden = false
        animationViewLbl.text = "Oops, you don't have any favorite contacts yet. Add your first by tapping on the star while editing a person's contact information."
        animationViewLbl.isHidden = false
        animationView.play()
        
        navigationItem.searchController = nil
        contactsTableView.isHidden = true
    }
    
    private func stopAnimationLoader() {
        animationView.isHidden = true
        animationViewLbl.isHidden = true
        animationView.stop()
        navigationItem.searchController = searchController
        contactsTableView.isHidden = false
    }
    
    func createNameDictionary() {
        
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
        
        switch showFavoriteContactsOnly {
        case .no:
            showFavoriteContactsOnly = .yes
            navBarTitle = "Favorites"
            showFavoriteContactStarImage = UIImage(named: "starFilled")!
            setUpNavBar()
            fetchCoreData(sortOrderType: sortOrder, isFavorite: showFavoriteContactsOnly)
            contactsTableView.reloadData()
        case .yes:
            showFavoriteContactsOnly = .no
            navBarTitle = "All Contacts"
            showFavoriteContactStarImage = UIImage(named: "starUnfilled")!
            setUpNavBar()
            fetchCoreData(sortOrderType: sortOrder, isFavorite: showFavoriteContactsOnly)
            contactsTableView.reloadData()
        }
        
    }
    
    @objc private func sortContactsByType() {
        
        switch sortOrder {
        case .byFirstName:
            sortOrder = .byLastName
            sortImage = UIImage(named: "sortIconLastName")!
            setUpNavBar()
            fetchCoreData(sortOrderType: sortOrder, isFavorite: showFavoriteContactsOnly)
            contactsTableView.reloadData()
        case .byLastName:
            sortOrder = .byFirstName
            sortImage = UIImage(named: "sortIconFirstName")!
            setUpNavBar()
            fetchCoreData(sortOrderType: sortOrder, isFavorite: showFavoriteContactsOnly)
            contactsTableView.reloadData()
        }
    }
}

//MARK: Coredata ----------------------------------------------------------------------------

extension ContactsVC {
    
    private func fetchCoreData(sortOrderType: SortOrderEnum, isFavorite: IsFavoriteEnum) {
        fetchContacts { (complete) in
            
            namesArray.removeAll()
            contactImagesArray.removeAll()
            
            var tempContactsArray: [Person] = []
            
            if complete {
                
                if personArray.isEmpty {
                    startAnimationLoaderForCreateContact()
                } else {
                    stopAnimationLoader()
                }
                
                personArray = personArray.sorted(by: { (a, b) -> Bool in
                    return a.firstName! < b.firstName!
                })
                
                onlyFavoriteContactsArray = personArray.filter( {$0.isFavorite == true})
                
                if showFavoriteContactsOnly == .yes {
                    tempContactsArray = onlyFavoriteContactsArray
                    
                    if onlyFavoriteContactsArray.isEmpty {
                        startAnimationLoaderNoFavorites()
                    } else {
                        stopAnimationLoader()
                    }
                    
                } else if showFavoriteContactsOnly == .no {
                    tempContactsArray = personArray
                }
                
                for i in tempContactsArray {
                    
                    var fullName = String()
                    
                    if sortOrderType == .byFirstName {
                        fullName = "\(i.firstName!) \(i.lastName!)"
                    } else if sortOrderType == .byLastName {
                        fullName = "\(i.lastName!) \(i.firstName!)"
                    }
                    
                    let image = UIImage(data: i.profileImage!)
                    let isFavorite = i.isFavorite
                    
                    namesArray.append(fullName)
                    contactImagesDictionary[fullName] = image
                    contactFavoritesDictionary[fullName] = isFavorite
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
            rowNumber += self.contactsTableView.numberOfRows(inSection: i)
        }
        
        if sortOrder == .byFirstName {
            
            personArray = personArray.sorted(by: { (a, b) -> Bool in
                return a.firstName! < b.firstName!
            })
            
        } else if sortOrder == .byLastName {
            
            personArray = personArray.sorted(by: { (a, b) -> Bool in
                return a.lastName! < b.lastName!
            })
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "contactCell", for: indexPath) as? ContactsCell else { return UITableViewCell() }
        
        var attributedText = NSAttributedString()
        var contactImage = UIImage()
        var isFavoriteBool = Bool()
        
        if searchController.isActive && searchController.searchBar.text != "" {
            if let firstName = filteredPersonArray[indexPath.row].firstName?.capitalized, let lastName = filteredPersonArray[indexPath.row].lastName?.capitalized, let profileImage = filteredPersonArray[indexPath.row].profileImage {
                
                let favoriteBool = filteredPersonArray[indexPath.row].isFavorite
                
                let text = "\(firstName) \(lastName)"
                let image = UIImage(data: profileImage)
                
                let range = (text.lowercased() as NSString).range(of: (searchController.searchBar.text?.lowercased())!)
                
                let attributedString = NSMutableAttributedString(string: text)
                attributedString.addAttribute(NSAttributedString.Key.backgroundColor, value: UIColor.yellow, range: range)
                attributedString.addAttribute(NSAttributedString.Key.font, value: UIFont(name: "AvenirNext-DemiBold", size: 20)!, range: range)
                
                attributedText = attributedString
                contactImage = image!
                isFavoriteBool = favoriteBool
            }
            
        } else {
            
            let letter = indexLettersInContactsArray[indexPath.section]
            
            if var names = contactNamesDictionary[letter.uppercased()] {
                names = names.sorted()
                
                let text = names[indexPath.row]
                let attributedString = NSMutableAttributedString(string: text)
                attributedText = attributedString
                
                let image = contactImagesDictionary[text]
                let favoriteBool = contactFavoritesDictionary[text]
                
                contactImage = image!
                isFavoriteBool = favoriteBool!
            }
        }
        
        cell.contactImage.image = contactImage
        cell.isFavoriteImage.isHidden = !(isFavoriteBool)
        cell.contactName.attributedText = attributedText
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let indexPath = tableView.indexPathForSelectedRow
        
        var rowNumber = indexPath!.row
        for i in 0..<indexPath!.section {
            rowNumber += self.contactsTableView.numberOfRows(inSection: i)
        }
        
        var fullName = String()
        
        var firstName = String()
        var lastName = String()
        var dateOfBirth = String()
        var phoneNumbers = NSObject()
        var emails = NSObject()
        var addresses = NSObject()
        var contactImage = UIImage()
        var favorite = Bool()
        
        var isFavorite: IsFavoriteEnum!
        
        if sortOrder == .byFirstName {
            
            personArray = personArray.sorted(by: { (a, b) -> Bool in
                return a.firstName! < b.firstName!
            })
            fullName = "\(personArray[rowNumber].firstName!) \(personArray[rowNumber].lastName!)"
           
        } else if sortOrder == .byLastName {
            
            personArray = personArray.sorted(by: { (a, b) -> Bool in
                return a.lastName! < b.lastName!
            })
             fullName = "\(personArray[rowNumber].lastName!) \(personArray[rowNumber].firstName!)"
        }
        
        if searchController.isActive && searchController.searchBar.text != "" {
            fullName = "\(filteredPersonArray[rowNumber].firstName!) \(filteredPersonArray[rowNumber].lastName!)"
            
            firstName = filteredPersonArray[rowNumber].firstName!
            lastName = filteredPersonArray[rowNumber].lastName!
            dateOfBirth = filteredPersonArray[rowNumber].dateOfBirth!
            phoneNumbers = filteredPersonArray[rowNumber].phoneNumbers!
            emails = filteredPersonArray[rowNumber].emails!
            addresses = filteredPersonArray[rowNumber].addresses!
            contactImage = contactImagesDictionary[fullName]!
            favorite = contactFavoritesDictionary[fullName]!
        } else {
            firstName = personArray[rowNumber].firstName!
            lastName = personArray[rowNumber].lastName!
            dateOfBirth = personArray[rowNumber].dateOfBirth!
            phoneNumbers = personArray[rowNumber].phoneNumbers!
            emails = personArray[rowNumber].emails!
            addresses = personArray[rowNumber].addresses!
            contactImage = contactImagesDictionary[fullName]!
            favorite = contactFavoritesDictionary[fullName]!
        }
        
        if favorite == true {
            isFavorite = .yes
        } else if favorite == false {
            isFavorite = .no
        }
        
        let profileVC = self.storyboard?.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
        profileVC.initProfileView(firstName: firstName, lastName: lastName, dateOfBirth: dateOfBirth, profileImage: contactImage, phoneNumbers: phoneNumbers as! [String], emails: emails as! [String], addresses: addresses as! [String], profileType: .view, isFavorite: isFavorite)
        
        present(profileVC, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        if searchController.isActive && searchController.searchBar.text != "" || showFavoriteContactsOnly == .yes {
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
                self.fetchCoreData(sortOrderType: sortOrder, isFavorite: showFavoriteContactsOnly)
                tableView.beginUpdates()
                tableView.deleteRows(at: [indexPath], with: .automatic)
                
                let indexSet = NSMutableIndexSet()
                indexSet.add(indexPath.section)
                
                tableView.deleteSections(indexSet as IndexSet, with: .automatic)
                tableView.endUpdates()
                
            } else {
                
                self.removeContact(atIndexPath: indexPath)
                self.fetchCoreData(sortOrderType: sortOrder, isFavorite: showFavoriteContactsOnly)
                
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
        
        contactsTableView.reloadData()
    }
}
