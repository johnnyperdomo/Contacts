//
//  ViewController.swift
//  Contacts
//
//  Created by Johnny Perdomo on 12/18/18.
//  Copyright © 2018 Johnny Perdomo. All rights reserved.
//

import UIKit
import CoreData

class ContactsVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        fetchCoreData()
        setUpNavBar()

    }
    
    let searchController = UISearchController(searchResultsController: nil)
    
    func setUpNavBar() {
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.title = "Contacts"
        
        let favoriteBtnItem = UIBarButtonItem(image: UIImage(named: "starFilled"), style: .plain, target: self, action: #selector(showFavoriteContacts))
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
    
    var filteredPersonArray: [Person] = []
    
    func filterContacts(text: String, scope: String = "All") {
        
        filteredPersonArray = personArray.filter({ (person) -> Bool in
            
            let fullName = "\(person.firstName?.lowercased() ?? "") \(person.lastName?.lowercased() ?? "")"
            
            print(fullName)
            return fullName.contains(text.lowercased())
        })

        
        tableView.reloadData()
        
    }
    
    @objc func showFavoriteContacts() {
        print("favorites Contact Btn pressed")
    }
    
    @objc func sortContactsByType() {
        print("sort contacts btn pressed")
    }
    
    
    let indexLetters = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
    
    var namesArray = [String]()
    
    var personArray: [Person] = []
    
    var contactNamesDictionary = [String: [String]]()
    var indexLettersInContactsArray = [String]()
    
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
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func createContactBtnPressed(_ sender: Any) {
        guard let profileVC = storyboard?.instantiateViewController(withIdentifier: "ProfileVC") else { return } //to create identifier to move between views
        present(profileVC, animated: true, completion: nil)
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

    func fetchCoreData() {
        fetchContacts { (complete) in
            
            namesArray.removeAll()
            
            if complete {
                print("got data")
                
                personArray = personArray.sorted(by: { (a, b) -> Bool in
                    return a.firstName! < b.firstName!
                })
                
                for i in personArray {
                    let fullName = "\(i.firstName!) \(i.lastName!)"
                    
                    namesArray.append(fullName)
                }
                createNameDictionary()
            } else {
                print("error fetched core data")
            }
        }
    }
    
    func fetchContacts(completion: (_ complete: Bool) -> ()) {
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
    
    func removeContact(atIndexPath indexPath: IndexPath) { //to remove a goal, we want to remove it from the core data
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "contactCell", for: indexPath) as? ContactsCell else { return UITableViewCell() }
    
        var text = String()

        if searchController.isActive && searchController.searchBar.text != "" {
            if let firstName = filteredPersonArray[indexPath.row].firstName?.capitalized, let lastName = filteredPersonArray[indexPath.row].lastName?.capitalized {
                text = "\(firstName) \(lastName)"
            }
            
        } else {
            let letter = indexLettersInContactsArray[indexPath.section]

            if var names = contactNamesDictionary[letter.uppercased()] {
                names = names.sorted()
                text = names[indexPath.row]
            }
        }
        
        cell.contactName.text = text
        
        return cell
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
            sectionTitle = indexLettersInContactsArray[section]
        }
        
        return sectionTitle
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return indexLetters
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
     
        let indexPath = tableView.indexPathForSelectedRow

        var rowNumber = indexPath!.row
        for i in 0..<indexPath!.section {
            rowNumber += self.tableView.numberOfRows(inSection: i)
        }
    }
}

extension ContactsVC: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContacts(text: searchController.searchBar.text!)
 //       print(filteredPersonArray)
    //    print(namesArray)
    }
}
