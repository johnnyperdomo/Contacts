//
//  NameTests.swift
//  ContactsTests
//
//  Created by Johnny Perdomo on 12/28/18.
//  Copyright © 2018 Johnny Perdomo. All rights reserved.
//

import XCTest
@testable import Contacts

class NameTests: XCTestCase {
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testToSeeIfCorrectNameFormatIsCorrectWithWhiteSpaceRemover() {
        let name = "Johnny"
        
        let formatName = name.removeWhiteSpaces()
        
        XCTAssertEqual(formatName, "Johnny")
    }
    
    func testForSingleWordWhiteSpaceRemoval() {
        let nameRightSpace = "Johnny "
        let nameLeftSpace = " Johnny"
        let nameBothSpace = " Johnny "
        
        let formatName1 = nameRightSpace.removeWhiteSpaces()
        let formatName2 = nameLeftSpace.removeWhiteSpaces()
        let formatName3 = nameBothSpace.removeWhiteSpaces()
        
        XCTAssertEqual(formatName1, "Johnny", "String should eliminate white spaces. formatted name should equal 'Johnny'")
        XCTAssertEqual(formatName2, "Johnny", "String should eliminate white spaces. formatted name should equal 'Johnny'")
        XCTAssertEqual(formatName3, "Johnny", "String should eliminate white spaces. formatted name should equal 'Johnny'")
    }
    
    func testForSingleWordMultipleWhiteSpaceRemoval() {
        let nameRightSpace = "Johnny      "
        let nameLeftSpace = "      Johnny"
        let nameBothSpace = "  Johnny      "
        
        let formatName1 = nameRightSpace.removeWhiteSpaces()
        let formatName2 = nameLeftSpace.removeWhiteSpaces()
        let formatName3 = nameBothSpace.removeWhiteSpaces()
        
        XCTAssertEqual(formatName1, "Johnny", "String should eliminate multiple white spaces. formatted name should equal 'Johnny'")
        XCTAssertEqual(formatName2, "Johnny", "String should eliminate multiple white spaces. formatted name should equal 'Johnny'")
        XCTAssertEqual(formatName3, "Johnny", "String should eliminate multiple white spaces. formatted name should equal 'Johnny'")
    }
    
    func testForDoubleWordMultipleWhiteSpaceRemoval() {
        let firstName = " Johnny "
        let lastName = "   Perdomo"
        
        let formatFirstName = firstName.removeWhiteSpaces()
        let formatLastName = lastName.removeWhiteSpaces()
        let fullName = "\(formatFirstName) \(formatLastName)"
        
        XCTAssertEqual(fullName, "Johnny Perdomo")
    }
}
