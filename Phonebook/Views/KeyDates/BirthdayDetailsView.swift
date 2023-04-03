//
//  BirthdayDetailsView.swift
//  Phonebook
//
//  Created by user235603 on 3/22/23.
//

import SwiftUI

struct BirthdayDetailsView: View {
    
    @ObservedObject var viewModel: ContactsViewModel
    let contact: Contact
    
    var age: Int? {
        guard let birthday = contact.birthday,
              let birthdayDate = Calendar.current.date(from: birthday),
              let age = Calendar.current.dateComponents([.year], from: birthdayDate, to: Date()).year
        else {
            return nil
        }
        
        let nextBirthday = Calendar.current.nextDate(after: Date(), matching: Calendar.current.dateComponents([.month, .day], from: birthdayDate), matchingPolicy: .nextTime)!
        let isNextYear = Calendar.current.component(.year, from: Date()) != Calendar.current.component(.year, from: nextBirthday)
        
        return age + (isNextYear ? 1 : 0)
    }
    
    
    var isBirthdayWithinNextWeek: Bool {
        guard let birthday = contact.birthday,
              let birthdayDate = Calendar.current.date(from: birthday)
        else {
            return false
        }
        
        let now = Date()
        let thisYearBirthday = Calendar.current.date(bySetting: .year, value: Calendar.current.component(.year, from: now), of: birthdayDate)!
        
        let components = Calendar.current.dateComponents([.day], from: now, to: thisYearBirthday)
        if let dayDifference = components.day {
            return 0 <= dayDifference && dayDifference <= 6
        } else {
            return false
        }
    }

    //Finding upcoming  birthdays to prompt user to call
    private var upcomingBirthdays: [Contact] {
        viewModel.contacts
            .compactMap { contact -> (Contact, Date)? in
                guard let birthday = contact.birthday,
                      let birthdayDateFromComponents = Calendar.current.date(from: birthday),
                      let birthdayDate = Calendar.current.nextDate(
                          after: Date(),
                          matching: Calendar.current.dateComponents([.month, .day], from: birthdayDateFromComponents),
                          matchingPolicy: .nextTime)
                else { return nil }
                
                return (contact, birthdayDate)
            }
            .sorted { $0.1 < $1.1 }
            .map { $0.0 }
    }
    
    private func isBirthdayThisWeek(birthdayDate: Date) -> Bool {
        let now = Date()
        let nextBirthday = Calendar.current.nextDate(after: now, matching: Calendar.current.dateComponents([.month, .day], from: birthdayDate), matchingPolicy: .nextTime)!

        let startOfWeek = Calendar.current.date(from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!
        let endOfWeek = Calendar.current.date(byAdding: .day, value: 7, to: startOfWeek)!

        return nextBirthday >= startOfWeek && nextBirthday < endOfWeek
    }

    var body: some View {
        if let birthday = contact.birthday,
           let birthdayDate = Calendar.current.date(from: birthday) {
            let isThisWeek = isBirthdayThisWeek(birthdayDate: birthdayDate)
            NavigationLink(destination: BirthdayDetailsView(viewModel: viewModel, contact: contact)) {
                VStack(alignment: .center, spacing: 16) {
                           if let age = age {
                               Text("\(contact.givenName) \(contact.familyName) is turning \(age) years old.")
                                   .font(.title)
                                   .foregroundColor(.primary)
                           } else {
                               Text("\(contact.givenName) \(contact.familyName)'s age is not available.")
                                   .font(.title)
                                   .foregroundColor(.primary)
                           }
                    
                    if isThisWeek, let phoneNumber = contact.phoneNumber {
                        VStack(alignment: .center, spacing: 8) {
                            Text("That time of year again? It's time to celebrate \(contact.givenName)'s birthday! Give them a call")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            Button(action: {
                                if let phoneURL = URL(string: "tel://\(phoneNumber)") {
                                    UIApplication.shared.open(phoneURL)
                                }
                            }) {
                                Text("Call")
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                        }
                    }

                }
            }
        }
    }
}

struct BirthdayDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleContact = Contact(id: UUID().uuidString, givenName: "Jane", familyName: "Doe", birthday: DateComponents(calendar: .current, year: 1996, month: 11, day: 29), phoneNumber: "123-456-7890", emailAddress: "Jane.doe@example.com")
        let viewModel = ContactsViewModel()
        viewModel.fetchContacts()
        return BirthdayDetailsView(viewModel: viewModel, contact: sampleContact)
    }
}





