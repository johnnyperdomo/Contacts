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
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    let indexLetters = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
    
    var namesArray = [String]()
    
    var personArray: [Person] = []
    
    var contactNamesDictionary = [String: [String]]()
    var indexLettersInContactsArray = [String]()
    
    func createNameDictionary() {
        
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
        guard let root = UIApplication.shared.keyWindow?.rootViewController else { return }
        self.definesPresentationContext = true
        profileVC.modalPresentationStyle = .overCurrentContext
        root.present(profileVC, animated: true, completion: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return contactNamesDictionary.keys.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let letter = indexLettersInContactsArray[section]
        
        if let names = contactNamesDictionary[letter] {
            return names.count
        }
        return 0
    }

    func fetchCoreData() {
        fetchContacts { (complete) in
            
            if complete {
                print("got data")
                
                for i in personArray {
                    let fullName = "\(i.firstName!) \(i.lastName!)"
                    
                    namesArray.append(fullName)
                }
                print(namesArray)
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "contactCell", for: indexPath) as? ContactsCell else { return UITableViewCell() }
        
        let letter = indexLettersInContactsArray[indexPath.section]
        
        if let names = contactNamesDictionary[letter.uppercased()] {
            cell.contactName.text = names[indexPath.row]
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return indexLettersInContactsArray[section]
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return indexLetters
    }
}
