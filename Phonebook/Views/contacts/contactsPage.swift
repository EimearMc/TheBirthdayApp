//
//  contactsPage.swift
//  Phonebook
//
//  Created by user233245 on 3/15/23.
//

import SwiftUI
import Contacts
import LinkPresentation
import ContactsUI


struct Contact: Identifiable {
    let id: String
    let givenName: String
    let familyName: String
    let birthday: DateComponents?
    let phoneNumber: String?
    let emailAddress: String?
    }

struct contactsPage: View {

    
    @EnvironmentObject var viewModel: ContactsViewModel

    
    @State private var searchText = ""

  
    private func indexedContacts() -> [String: [Contact]] {

      
        var indexedContacts: [String: [Contact]] = [:]

        let filteredContacts = viewModel.contacts.filter { contact in
            searchText.isEmpty || contact.givenName.lowercased().contains(searchText.lowercased()) || contact.familyName.lowercased().contains(searchText.lowercased())
        }

        
        for contact in filteredContacts {
           
            let firstLetter = String(contact.givenName.prefix(1)).uppercased()
            
           
            if indexedContacts[firstLetter] != nil {
               
                indexedContacts[firstLetter]?.append(contact)
            } else {
                
                indexedContacts[firstLetter] = [contact]
            }
        }

        return indexedContacts
    }


   var body: some View {
    NavigationView {
        List {
            TextField("Search", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle()) 
                .padding(.horizontal) 
           
            ForEach(indexedContacts().keys.sorted(), id: \.self) { key in
             
                Section(header: Text(key)) {
                    
                    ForEach(indexedContacts()[key]!, id: \.id) { contact in
                        
                        NavigationLink(destination: ContactDetailsView(contact: contact, viewModel: viewModel)) {
                         
                            Text("\(contact.givenName) \(contact.familyName)")
                        }
                       
                        .swipeActions(edge: .trailing) {
                          
                            Button(role: .destructive) {
                 
                                viewModel.deleteContact(contact)
                            } label: {
                               
                                Label("Delete", systemImage: "trash.fill")
                            }
                        }
                    }
                }
            }
        }
      
        .onAppear(perform: viewModel.fetchContacts)
    
        .listStyle(InsetGroupedListStyle())
       
        .navigationTitle("Contacts")
       
        .navigationBarItems(trailing: NavigationLink(destination: AddContactView(viewModel: viewModel)) {
            Image(systemName: "plus")
        })
    }
  
    .background(Image("background"))
}

class ContactsViewModel: ObservableObject {

    @Published var contacts: [Contact] = []

    func addContact(_ contact: Contact) {
        
        if !contacts.contains(where: { $0.id == contact.id }) {
            
            contacts.append(contact)
            contacts.sort { $0.givenName.localizedStandardCompare($1.givenName) == .orderedAscending }
        }
    }
    
    func deleteContact(_ contact: Contact) {
        let store = CNContactStore()
        let request = CNSaveRequest()
        
        do {
            
            if let existingContact = try store.unifiedContact(withIdentifier: contact.id, keysToFetch: [CNContactViewController.descriptorForRequiredKeys()]) as? CNMutableContact {
                
                request.delete(existingContact)
           
                try store.execute(request)
                
                if let index = contacts.firstIndex(where: { $0.id == contact.id }) {
                    contacts.remove(at: index)
                }
            }
        } catch {
            print("Error deleting contact: \(error)")
        }
    }
}

    
func fetchContacts() {
    DispatchQueue.global(qos: .userInitiated).async {
        let store = CNContactStore()
        let keysToFetch = [
            CNContactGivenNameKey as CNKeyDescriptor,
            CNContactFamilyNameKey as CNKeyDescriptor,
            CNContactIdentifierKey as CNKeyDescriptor,
            CNContactBirthdayKey as CNKeyDescriptor,
            CNContactPhoneNumbersKey as CNKeyDescriptor,
            CNContactEmailAddressesKey as CNKeyDescriptor,
            CNContactDatesKey as CNKeyDescriptor
        ]

        let request = CNContactFetchRequest(keysToFetch: keysToFetch)

        do {
            try store.enumerateContacts(with: request, usingBlock: { (contact, _) in
                let id = contact.identifier
                let givenName = contact.givenName
                let familyName = contact.familyName
                let birthday = contact.birthday
                let phoneNumber = contact.phoneNumbers.first?.value.stringValue
                let emailAddress = contact.emailAddresses.first?.value as String?

                DispatchQueue.main.async {
                    if let birthday = birthday, !self.contacts.contains(where: { $0.id == id }) {
                        self.addContact(Contact(id: id, givenName: givenName, familyName: familyName, birthday: birthday, phoneNumber: phoneNumber, emailAddress: emailAddress))
                    }
                }
            })

        } catch {
            print("Error fetching contacts: \(error)")
        }
    }
}

func createContact(_ contact: Contact) {
    let store = CNContactStore()
    let newContact = CNMutableContact()

    newContact.givenName = contact.givenName
    newContact.familyName = contact.familyName

    if let phoneNumber = contact.phoneNumber {
        newContact.phoneNumbers = [CNLabeledValue(label: CNLabelPhoneNumberMain, value: CNPhoneNumber(stringValue: phoneNumber))]
    }

    if let emailAddress = contact.emailAddress {
        newContact.emailAddresses = [CNLabeledValue(label: CNLabelWork, value: emailAddress as NSString)]
    }

    if let birthday = contact.birthday {
        newContact.birthday = birthday
    }

    let saveRequest = CNSaveRequest()
    saveRequest.add(newContact, toContainerWithIdentifier: nil)

    do {
        try store.execute(saveRequest)
        addContact(contact)
    } catch {
        print("Error creating contact: \(error)")
    }
}

    
    func updateContact(_ contact: Contact) {
        let store = CNContactStore()
        let mutableContact: CNMutableContact

        do {
            let originalContact = try store.unifiedContact(withIdentifier: contact.id, keysToFetch: [CNContactViewController.descriptorForRequiredKeys()])
            mutableContact = originalContact.mutableCopy() as! CNMutableContact
        } catch {
            print("Error fetching contact: \(error)")
            return
        }

        mutableContact.givenName = contact.givenName
        mutableContact.familyName = contact.familyName

        if let phoneNumber = contact.phoneNumber {
            mutableContact.phoneNumbers = [CNLabeledValue(label: CNLabelPhoneNumberMain, value: CNPhoneNumber(stringValue: phoneNumber))]
        } else {
            mutableContact.phoneNumbers = []
        }

        if let emailAddress = contact.emailAddress {
            mutableContact.emailAddresses = [CNLabeledValue(label: CNLabelWork, value: emailAddress as NSString)]
        } else {
            mutableContact.emailAddresses = []
        }

        if let birthday = contact.birthday {
            mutableContact.birthday = birthday
        } else {
            mutableContact.birthday = nil
        }

        let saveRequest = CNSaveRequest()
        saveRequest.update(mutableContact)
        
        do {
            try store.execute(saveRequest)
            if let index = contacts.firstIndex(where: { $0.id == contact.id }) {
                contacts[index] = contact
            }
        } catch {
            print("Error updating contact: \(error)")
        }
    }


}

struct ContactDetailsView: View {
    
    let contact: Contact
    @ObservedObject var viewModel: ContactsViewModel
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter
    }()
    
    func callURL(for phoneNumber: String) -> URL? {
            let allowedCharacterSet = CharacterSet(charactersIn: "+0123456789")
            let sanitizedPhoneNumber = String(phoneNumber.unicodeScalars.filter(allowedCharacterSet.contains))
            let callURLString = "tel:\(sanitizedPhoneNumber)"
            
            return URL(string: callURLString)
        }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Group {
                Text("First Name:")
                Text(contact.givenName)
                    .font(.title2)
                    .bold()
                
                Text("Last Name:")
                Text(contact.familyName)
                    .font(.title2)
                    .bold()
                
                if let phoneNumber = contact.phoneNumber, let callURL = callURL(for: phoneNumber) {
                                    HStack {
                                        Text("Phone Number:")
                                        Text(phoneNumber)
                                            .font(.title2)
                                            .bold()
                                        Spacer()
                                        Link(destination: callURL) {
                                            Image(systemName: "phone.fill")
                                                .foregroundColor(.blue)
                                                .font(.system(size: 24))
                                        }
                                    }
                                }
                
                if let emailAddress = contact.emailAddress {
                    Text("Email Address:")
                    Text(emailAddress)
                        .font(.title2)
                        .bold()
                }
                
                if let birthday = contact.birthday, let date = Calendar.current.date(from: birthday) {
                    Text("Birthday:")
                    Text(date, formatter: dateFormatter)
                        .font(.title2)
                        .bold()
                }
                
            }
            Spacer()
        }
        .background(Color.white.opacity(0.7))
        .padding()
        .navigationTitle("Contact Details")
        .navigationBarItems(trailing: NavigationLink(destination: EditContactView(viewModel: viewModel, contact: contact)) {
            Image(systemName: "pencil")
        })
    }
}


struct EditContactView: View {
    
    @ObservedObject var viewModel: ContactsViewModel
    let contact: Contact
    
    @Environment(\.presentationMode) var presentationMode
    @State private var givenName: String
    @State private var familyName: String
    @State private var phoneNumber: String
    @State private var emailAddress: String
    @State private var birthday: Date?
    @State private var nonOptionalBirthday: Date
    
    init(viewModel: ContactsViewModel, contact: Contact) {
        self.viewModel = viewModel
        self.contact = contact
        _givenName = State(initialValue: contact.givenName)
        _familyName = State(initialValue: contact.familyName)
        _phoneNumber = State(initialValue: contact.phoneNumber ?? "")
        _emailAddress = State(initialValue: contact.emailAddress ?? "")
        _birthday = State(initialValue: contact.birthday.flatMap { Calendar.current.date(from: $0) })
        _nonOptionalBirthday = State(initialValue: contact.birthday.flatMap { Calendar.current.date(from: $0) } ?? Date())
    }
    
    var body: some View {
        Form {
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
                    .onChange(of: nonOptionalBirthday, perform: { value in
                        birthday = value
                    })
            }
            
        }
        .navigationBarItems(trailing: Button("Save") {
            let updatedBirthday = birthday.flatMap { Calendar.current.dateComponents([.year, .month, .day], from: $0) }
            let updatedContact = Contact(id: contact.id, givenName: givenName, familyName: familyName, birthday: updatedBirthday, phoneNumber: phoneNumber.isEmpty ? nil : phoneNumber, emailAddress: emailAddress.isEmpty ? nil : emailAddress)
            
            viewModel.updateContact(updatedContact)
            presentationMode.wrappedValue.dismiss()
        })
        
        
    }
}
    
    struct contactsPage_Previews: PreviewProvider {
        static var previews: some View {
            contactsPage()
        }
    }
