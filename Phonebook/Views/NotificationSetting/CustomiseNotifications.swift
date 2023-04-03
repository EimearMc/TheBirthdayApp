//
//  CustomiseNotifications.swift
//  Birthdays
//
//  Created by user235603 on 3/25/23.
//

import SwiftUI

struct CustomiseNotifications: View {
    @AppStorage("birthdayReminderEnabled") private var birthdayReminderEnabled = true
    @AppStorage("reminderTime") private var reminderTime = 9

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Birthday Reminders")) {
                    Toggle("Enable Birthday Reminders", isOn: $birthdayReminderEnabled)
                }
                
                if birthdayReminderEnabled {
                    Section(header: Text("Reminder Time")) {
                        Picker("Time", selection: $reminderTime) {
                            ForEach(0..<24) { hour in
                                Text("\(hour):00")
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .labelsHidden()
                    }
                }
            }
            .navigationTitle("Notification Settings")
        }
    }
}

struct CustomiseNotifications_Previews: PreviewProvider {
    static var previews: some View {
        CustomiseNotifications()
    }
}

