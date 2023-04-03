//
//  ContentView.swift
//  Phonebook


import SwiftUI
import UserNotifications


struct RootView: View {
    @StateObject private var viewModel = ContactsViewModel()
    @State var selectedTab: Tabs = .contacts
    
    var body: some View {
        VStack {
          
            Spacer()
            
            if(selectedTab == .contacts){
                contactsPage()

            }
            
            if(selectedTab == .dates){
                keyDatesPage(viewModel: viewModel)

            }
            
            if(selectedTab == .notifications){
                CustomiseNotifications()

            }
            
            Spacer()
        
            
                CustomTabBar(selectedTab: $selectedTab)
                    .padding(.bottom)
        }
        .padding()
        .edgesIgnoringSafeArea(.bottom)
        .background(Image("background"))
        .environmentObject(viewModel)
        .onAppear {
            viewModel.fetchContacts()
            requestNotificationPermission()
            scheduleBirthdayNotifications(for: viewModel.contacts)
        }
    }
    
}

private func isUpcomingBirthday(birthdayDate: Date) -> Bool {
    let calendar = Calendar.current
    let now = Date()
    let nextBirthday = calendar.nextDate(after: now, matching: calendar.dateComponents([.month, .day], from: birthdayDate), matchingPolicy: .nextTime)

    guard let nextBirthdayDate = nextBirthday else { return false }

    return calendar.isDate(now, equalTo: nextBirthdayDate, toGranularity: .day) || calendar.isDateInToday(nextBirthdayDate)
}


private func scheduleBirthdayNotifications(for contacts: [Contact]) {
    let center = UNUserNotificationCenter.current()

    for contact in contacts {
        if let birthday = contact.birthday,
                 let birthdayDate = Calendar.current.date(from: birthday),
                 isUpcomingBirthday(birthdayDate: birthdayDate) {
                   
                   let content = UNMutableNotificationContent()
                   content.title = "Birthday Reminder"
                   content.body = "Today is \(contact.givenName) \(contact.familyName)'s birthday!"
                   content.sound = .default
                   
                   let calendar = Calendar.current
                   let dateComponents = calendar.dateComponents([.month, .day], from: birthdayDate)
                   let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                   
                   let request = UNNotificationRequest(identifier: "Birthday-\(contact.id)", content: content, trigger: trigger)
                   center.add(request) { error in
                       if let error = error {
                           print("Error scheduling notification: \(error)")
                       }
                   }
               }
        }
    }


private func requestNotificationPermission() {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
        if granted {
            print("Notification permission granted.")
        } else if let error = error {
            print("Notification permission error: \(error)")
        } else {
            print("Notification permission not granted.")
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
