//
//  EmailTests.swift
//  ContactsTests
//
//  Created by Johnny Perdomo on 12/28/18.
//  Copyright © 2018 Johnny Perdomo. All rights reserved.
//

import XCTest
@testable import Contacts

class EmailTests: XCTestCase {

    var profile: ProfileVC!
    
    override func setUp() {
        profile = ProfileVC()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testForValidEmail() {
        let email = "test@testingemail.com"
        
        let checker = profile.isEmailValid(email)
        
        XCTAssertTrue(checker)
    }
    
    func testForInvalidEmail() {
        let email = "gsdfgfdg5fd1g5f"
        
        let checker = profile.isEmailValid(email)
        
        XCTAssertFalse(checker)
    }
    
    func testForLowercaseEmailConversion() {
        let email = "JoHnnyPerdoMO@GmaIL.cOm"
    
        let lowerCasedEmail = email.lowercased()
        
        XCTAssertEqual(lowerCasedEmail, "johnnyperdomo@gmail.com")
    }
    
    func testForUpperCaseEmail() {
        let email = "teSterUnit@gMAil.cOM"
        
        let lowerCasedEmail = email.lowercased()
        
        XCTAssertNotEqual(lowerCasedEmail, email)
    }
    
    func testForIncompleteEmail() {
        let email = "incomplete@gmail"
        
        let checker = profile.isEmailValid(email)
        
        XCTAssertFalse(checker)
    }
    
    func testForEmailNoName() {
        let email = "@gmail.com"
        
        let checker = profile.isEmailValid(email)
        
        XCTAssertFalse(checker)
    }
    
    func testForEmailNoDomain() {
        let email = "johnnytest@"
        
        let checker = profile.isEmailValid(email)
        
        XCTAssertFalse(checker)
    }
    
    func testForWhiteSpacesInEmail() {
        let email = "eleven@stranger things.com"
        
        let checker = profile.isEmailValid(email)
        
        XCTAssertFalse(checker)
    }
}
