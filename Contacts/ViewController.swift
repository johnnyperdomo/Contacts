//
//  ViewController.swift
//  Contacts
//
//  Created by Johnny Perdomo on 12/18/18.
//  Copyright © 2018 Johnny Perdomo. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        createNameDictionary()
    }

    let indexLetters = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
    
    let namesArray = ["apple", "aston martin", "bread", "cow", "donkey", "elephant", "ffat", "great", "hat", "igloo", "joke", "kangaroo", "lampstand", "quarts", "rude", "tuv", "walrus", "taco", "zebra"]
    
    var contactNamesDictionary = [String: [String]]()
    var indexLettersInContactsArray = [String]()
    
    func createNameDictionary() {
        
        for name in namesArray {
            
            let firstLetter = "\(name[name.startIndex])"
            let uppercasedLetter = firstLetter.uppercased()
            
            if var separateNamesArray = contactNamesDictionary[uppercasedLetter] { //check if key already exists
                separateNamesArray.append(name)
                contactNamesDictionary[uppercasedLetter] = separateNamesArray
                print(separateNamesArray)
            } else {
                contactNamesDictionary[uppercasedLetter] = [name]
            }
        }
    
        indexLettersInContactsArray = [String](contactNamesDictionary.keys)
        indexLettersInContactsArray = indexLettersInContactsArray.sorted()
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func createContactBtnPressed(_ sender: Any) {
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
