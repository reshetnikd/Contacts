//
//  ContactsTests.swift
//  ContactsTests
//
//  Created by Dmitry Reshetnik on 28.05.2020.
//  Copyright © 2020 Dmitry Reshetnik. All rights reserved.
//

import XCTest
@testable import Contacts

class ContactsTests: XCTestCase {
    lazy var mailsFilePath: String? = Bundle.main.path(forResource: "list", ofType: "txt")

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testAllMailsLoaded() {
        guard mailsFilePath != nil else {
            XCTFail("List file should exist")
            return
        }
        let data = MailData()
        XCTAssertEqual(data.mailboxes.count, 50, "List should have 50 email")
    }
    
    func testSimulateChanges() {
        let peopleVC = PeopleViewController()
        peopleVC.viewDidLoad()
        peopleVC.simulateChanges()
        XCTAssertNotEqual(peopleVC.people.count, 50, "At least one person should be inserted or deleted")
    }
    
    func testFetchPersonData() {
        XCTAssertNotNil(Person.fetchDataOfProfile(with: "person@server.com"), "At least template person should exist")
    }

    func testPerformanceFetchPersonData() throws {
        measure {
            let data = MailData()
            var people = [Person]()
            
            data.mailboxes.forEach { (mail) in
                people.append(Person.fetchDataOfProfile(with: mail))
            }
        }
    }

}
