//
//  keyDatesPage.swift
//  Phonebook
//
//  Created by user233245 on 3/15/23.
//

import SwiftUI

struct keyDatesPage: View {
    
    @ObservedObject var viewModel: ContactsViewModel
    
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

    var body: some View {
        NavigationView {
            List {
                ForEach(upcomingBirthdays) { contact in
                    if let birthday = contact.birthday,
                       let birthdayDate = Calendar.current.date(from: birthday) {
                        let isThisWeek = isBirthdayThisWeek(birthdayDate: birthdayDate)
                        NavigationLink(destination: BirthdayDetailsView(viewModel: viewModel, contact: contact)) {
                            HStack {
                                if isThisWeek {
                                    Text("\(contact.givenName) \(contact.familyName)'s birthday is this week!")
                                } else {
                                    Text("\(contact.givenName) \(contact.familyName)'s birthday is coming up on")
                                }
                                Spacer()
                                Text(getFormattedBirthday(birthdayDate: birthdayDate))
                            }
                        }
                    }
                }
            }
            
            .navigationTitle("Upcoming Birthdays")
            .background(Image("background"))
        }
    }
}




private func isBirthdayThisWeek(birthdayDate: Date) -> Bool {
    let now = Date()
    let nextBirthday = Calendar.current.nextDate(after: now, matching: Calendar.current.dateComponents([.month, .day], from: birthdayDate), matchingPolicy: .nextTime)!

    let startOfWeek = Calendar.current.date(from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!
    let endOfWeek = Calendar.current.date(byAdding: .day, value: 7, to: startOfWeek)!

    return nextBirthday >= startOfWeek && nextBirthday < endOfWeek
}



private func calculateAge(birthdayDate: Date) -> Int {
    let now = Date()
    let thisYearBirthday = Calendar.current.date(bySetting: .year, value: Calendar.current.component(.year, from: now), of: birthdayDate)!
    let nextBirthday = Calendar.current.nextDate(after: now, matching: Calendar.current.dateComponents([.month, .day], from: birthdayDate), matchingPolicy: .nextTime)!
    let isNextYear = (nextBirthday != thisYearBirthday)
    let ageComponents = Calendar.current.dateComponents([.year], from: birthdayDate, to: now)
    let age = ageComponents.year! + (isNextYear ? 1 : 0)
    return age
}



private func getFormattedBirthday(birthdayDate: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMMM d"
    return formatter.string(from: birthdayDate)
}

struct keyDatesPage_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = ContactsViewModel()
        viewModel.fetchContacts()
        return keyDatesPage(viewModel: viewModel)
    }
}
