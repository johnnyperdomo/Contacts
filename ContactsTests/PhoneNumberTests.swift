//
//  ContactsTests.swift
//  ContactsTests
//
//  Created by Johnny Perdomo on 12/28/18.
//  Copyright © 2018 Johnny Perdomo. All rights reserved.
//

import XCTest
@testable import Contacts

class PhoneNumberTests: XCTestCase {

    var profile: ProfileVC!
    
    override func setUp() {
        profile = ProfileVC()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testForValidPhoneNumber() {
        let number = "3115552368"
        
        let checker = profile.isPhoneNumberValid(number)
        
        XCTAssertTrue(checker)
    }
    
    func testForLettersInPhoneNumber() {
        let number = "3115552hj8"
        
        let checker = profile.isPhoneNumberValid(number)
        
        XCTAssertFalse(checker)
    }
    
    func testWhetherCharacterCountInNumberIsLessThan10() {
        let number = "132153"
        let number9 = "123456789"
        
        let checker = profile.isPhoneNumberValid(number)
        let checker9 = profile.isPhoneNumberValid(number9)
        
        XCTAssertFalse(checker, "Number count should be 10")
        XCTAssertFalse(checker9, "Number count should be 10")
    }
    
    func testWhetherCharactersCountInNumberIsMoreThan10() {
        let number10 = "1234567891"
        let number11 = "12345678911"
        
        let checker1 = profile.isPhoneNumberValid(number10)
        let checker2 = profile.isPhoneNumberValid(number11)
        
        XCTAssertTrue(checker1, "10 characters should be allowed in a phone number. Phone Number should be true")
        XCTAssertFalse(checker2, "10 characters should be the max in a phone number, you currently have \(number11.count) characters. Phone Number should be false")
    }
    
    func testForMultipleInvalidCharactersInNumber() {
        let number = "+++++++*+9"
        
        let checker = profile.isPhoneNumberValid(number)
        
        XCTAssertFalse(checker)
        
    }
}
