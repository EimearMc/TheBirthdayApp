//
//  TheBirthdayAppTests.swift
//  TheBirthdayAppTests
//
//  Created by user235603 on 3/26/23.
//
@testable import Birthdays
import XCTest

final class TheBirthdayAppTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testAddContact() {
        let viewModel = ContactsViewModel()
        let newContact = Contact(id: "1", givenName: "John", familyName: "Doe", birthday: DateComponents(calendar: .current, year: 1990, month: 1, day: 1), phoneNumber: "123-456-7890", emailAddress: "john@example.com")

        viewModel.addContact(newContact)

        XCTAssertTrue(viewModel.contacts.contains(where: { $0.id == newContact.id }), "New contact should be added to the contacts list")
    }

    func testDeleteContact() {
        let viewModel = ContactsViewModel()
        let contactToDelete = Contact(id: "1", givenName: "John", familyName: "Doe", birthday: DateComponents(calendar: .current, year: 1990, month: 1, day: 1), phoneNumber: "123-456-7890", emailAddress: "john@example.com")

        viewModel.contacts = [contactToDelete]
        viewModel.deleteContact(contactToDelete)

        XCTAssertFalse(viewModel.contacts.contains(where: { $0.id == contactToDelete.id }), "Contact should be removed from the contacts list")
    }

    func testUpdateContact() {
        let viewModel = ContactsViewModel()
        let originalContact = Contact(id: "1", givenName: "John", familyName: "Doe", birthday: DateComponents(calendar: .current, year: 1990, month: 1, day: 1), phoneNumber: "123-456-7890", emailAddress: "john@example.com")
        let updatedContact = Contact(id: "1", givenName: "Jane", familyName: "Doe", birthday: DateComponents(calendar: .current, year: 1990, month: 1, day: 1), phoneNumber: "123-456-7890", emailAddress: "jane@example.com")

        viewModel.contacts = [originalContact]
        viewModel.updateContact(updatedContact)

        XCTAssertTrue(viewModel.contacts.contains(where: { $0.id == updatedContact.id }), "Contact should be updated in the contacts list")
        XCTAssertFalse(viewModel.contacts.contains(where: { $0.id == originalContact.id }), "Original contact should be removed from the contacts list")
    }



}
