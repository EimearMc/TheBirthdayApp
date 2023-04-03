//
//  AddContactView.swift
//  Phonebook
//
//  Created by user235603 on 3/23/23.
//

import SwiftUI

struct AddContactView: View {
    
    @ObservedObject var viewModel: ContactsViewModel

// Declare an environment property to access the current view's presentation state
    @Environment(\.presentationMode) var presentationMode

    // Declare state properties to store user input for contact information
    @State private var givenName: String = ""
    @State private var familyName: String = ""
    @State private var phoneNumber: String = ""
    @State private var emailAddress: String = ""

    // Declare state properties to store the birthday date
    @State private var birthday: Date? = nil
    @State private var nonOptionalBirthday: Date = Date()
    
    var body: some View {
        
        // Create a form to collect user input
        Form {
             // Create a section with a header for each field
            Section(header: Text("Name")) {
                TextField("First Name", text: $givenName)
                TextField("Last Name", text: $familyName)
            }

            Section(header: Text("Phone")) {
                TextField("Phone Number", text: $phoneNumber)
            }

            Section(header: Text("Email")) {
                TextField("Email Address", text: $emailAddress)
            }

            Section(header: Text("Birthday")) {
                DatePicker("Birthday", selection: $nonOptionalBirthday, displayedComponents: .date)
            }
        }
        // Add a navigation bar item with a save button
        .navigationBarItems(trailing: Button("Save") {
            // Generate a unique ID for the new contact
            let id = UUID().uuidString

            // Extract the year, month, and day components from the nonOptionalBirthday date
            let birthdayComponents = Calendar.current.dateComponents([.year, .month, .day], from: nonOptionalBirthday)

            // Create a new contact instance with the user input
            let newContact = Contact(id: id, givenName: givenName, familyName: familyName, birthday: birthdayComponents, phoneNumber: phoneNumber.isEmpty ? nil : phoneNumber, emailAddress: emailAddress.isEmpty ? nil : emailAddress)

            // Call the createContact method from the viewModel to save the new contact
            viewModel.createContact(newContact)

            // Dismiss the current view
            presentationMode.wrappedValue.dismiss()
        })
        .navigationTitle("Add Contact") // Set the navigation title for the view
    }
}

struct AddContactView_Previews: PreviewProvider {
    static var previews: some View {
        // Return an instance of the AddContactView for SwiftUI previews
        AddContactView(viewModel: ContactsViewModel())
    }
}


