//
//  ContactTests.swift
//  ContactsTests
//
//  Created by Johnny Perdomo on 12/28/18.
//  Copyright © 2018 Johnny Perdomo. All rights reserved.
//

import XCTest
@testable import Contacts

class ContactTests: XCTestCase {

    var contacts: ContactsVC!
    
    override func setUp() {
        contacts = ContactsVC()
        contacts.namesArray = ["Johnny", "James", "Larry", "Paul", "Ross", "Rachel", "Monica", "Phoebe", "Andrew", "Benjamin"]
    }

    override func tearDown() {
        contacts.namesArray = []
    }

    func testFunctionThatTurnsArrayOfNamesIntoDictionary() {
        let expectedDictionary = ["J": ["Johnny", "James"],  "L": ["Larry"], "P": ["Paul", "Phoebe"], "R": ["Ross", "Rachel"], "M": ["Monica"], "A": ["Andrew"], "B": ["Benjamin"]]
        
        contacts.createNameDictionary()
        
        XCTAssertEqual(contacts.contactNamesDictionary, expectedDictionary, "Array of Names should create dictionary of <String: [String]>")
    }
    
    func testWhetherContactNamesDictionaryRemovesKeyAndNestedStringValues() {
     let expectedDictionary = ["J": ["James", "Johnny"], "L": ["Larry"], "P": ["Paul", "Phoebe"], "R": ["Rachel", "Ross"], "M": ["Monica"], "B": ["Benjamin"]]
        
        contacts.namesArray = contacts.namesArray.sorted()
        contacts.namesArray.remove(at: 0) //removes first name which should be "Andrew"
        
        contacts.createNameDictionary()
        
        XCTAssertEqual(contacts.contactNamesDictionary, expectedDictionary, "Contacts Names Dictionary should remove the Key and Nested String Values ")
        
    }
    
    func testWhetherContactNamesDictionaryRemovesNestedStringValueButNotKey() {
        let expectedDictionary = ["J": ["James"], "L": ["Larry"], "P": ["Paul", "Phoebe"], "R": ["Rachel", "Ross"], "M": ["Monica"], "A": ["Andrew"], "B": ["Benjamin"]]
        
        contacts.namesArray = contacts.namesArray.sorted()
        contacts.namesArray.remove(at: 3) //removes the name "Johnny"
        
        contacts.createNameDictionary()
        
        XCTAssertEqual(contacts.contactNamesDictionary, expectedDictionary, "Contacts Names Dictionary should remove the Key and Nested String Values ")
    }
    
    func testWhetherContactNamesDictionaryAddsKeyandNestedStringValue() {
        let expectedDictionary = ["J": ["James", "Johnny"], "C": ["Coraline"], "L": ["Larry"], "P": ["Paul", "Phoebe"], "R": ["Rachel", "Ross"], "M": ["Monica"], "A": ["Andrew"], "B": ["Benjamin"]]
        
        contacts.namesArray = contacts.namesArray.sorted()
        contacts.namesArray.append("Coraline")
        
        contacts.createNameDictionary()
        
        XCTAssertEqual(contacts.contactNamesDictionary, expectedDictionary, "Contacts Names Dictionary should remove the Key and Nested String Values ")
    }
    
    func testWhetherContactNamesDictionaryAddsNestedStringValueButNotKey() {
        let expectedDictionary = ["J": ["James", "Johnny", "Joey"], "L": ["Larry"], "P": ["Paul", "Phoebe"], "R": ["Rachel", "Ross"], "M": ["Monica"], "A": ["Andrew"], "B": ["Benjamin"]]
        
        contacts.namesArray = contacts.namesArray.sorted()
        contacts.namesArray.append("Joey")
        
        contacts.createNameDictionary()
        
        XCTAssertEqual(contacts.contactNamesDictionary, expectedDictionary, "Contacts Names Dictionary should remove the Key and Nested String Values ")
    }
    
    func testWhetherContactNamesDictionaryDoesNotAddNestedStringInWrongKey() {
        let unexpectedDictionary = ["J": ["James", "Johnny"], "L": ["Larry", "Joey"], "P": ["Paul", "Phoebe"], "R": ["Rachel", "Ross"], "M": ["Monica"], "A": ["Andrew"], "B": ["Benjamin"]]
        
        contacts.namesArray = contacts.namesArray.sorted()
        contacts.namesArray.append("Joey")
        
        contacts.createNameDictionary()
        
        XCTAssertNotEqual(contacts.contactNamesDictionary, unexpectedDictionary, "Contacts Names Dictionary should remove the Key and Nested String Values ")
    }
    
    func testForIndexLettersInContactNamesDictionary() {
        let indexArray = ["A", "B", "J", "L", "M", "P", "R"]
        
        contacts.createNameDictionary()
        
        XCTAssertEqual(contacts.indexLettersInContactsArray, indexArray)
    }
    
    func testForIndexLettersInContactNamesDictionaryAfterNameRemoval() {
        let indexArray = ["B", "J", "L", "M", "P", "R"]
        
        contacts.namesArray = contacts.namesArray.sorted()
        contacts.namesArray.remove(at: 0) //removes the name "Andrew"
        
        contacts.createNameDictionary()
        
        XCTAssertEqual(contacts.indexLettersInContactsArray, indexArray)
    }
    
    func testForIncorrectIndexLettersInContactNamesDictionaryAfterNameRemoval() {
        let indexArray = ["A", "B", "J", "L", "M", "P", "R"]
        
        contacts.namesArray = contacts.namesArray.sorted()
        contacts.namesArray.remove(at: 0) //removes the name "Andrew"
        
        contacts.createNameDictionary()
        
        XCTAssertNotEqual(contacts.indexLettersInContactsArray, indexArray, "Index Array should remove the letter according to the key that was removed in contactNamesDictionary")
    }
    
    func testForIndexLettersInContactNamesDictionaryAfterNameAddition() {
        let indexArray = ["A", "B", "C", "J", "L", "M", "P", "R"]
        
        contacts.namesArray = contacts.namesArray.sorted()
        contacts.namesArray.append("Coraline")
        
        contacts.createNameDictionary()
        
        XCTAssertEqual(contacts.indexLettersInContactsArray, indexArray, "Index Array should add the letter according to the key that was removed in contactNamesDictionary")
    }
    
    func testForIncorrectIndexLettersInContactNamesDictionaryAfterNameAddition() {
        let indexArray = ["A", "B", "J", "L", "M", "P", "R"]
        
        contacts.namesArray = contacts.namesArray.sorted()
        contacts.namesArray.append("Coraline")
        
        contacts.createNameDictionary()
        
        XCTAssertNotEqual(contacts.indexLettersInContactsArray, indexArray, "Index Array should add the letter according to the key that was removed in contactNamesDictionary")
    }
}
