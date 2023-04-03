//
//  CustomTabBar.swift
//  Phonebook

//

import SwiftUI

enum Tabs: Int {
    case dates = 0
    case contacts = 1
    case notifications = 2
}

struct CustomTabBar: View {
    
    @Binding var selectedTab: Tabs
    @EnvironmentObject var viewModel: ContactsViewModel
//    @StateObject private var viewModel = ContactsViewModel()

    var body: some View {
        
        VStack{
            
            HStack(alignment: .center){
                Spacer()
                Button {
                    //dates
                    selectedTab = .dates
                } label: {
                    
                    GeometryReader{ geo in
                        
                        if selectedTab == .dates {
                            Rectangle()
                                .foregroundColor(.black)
                                .frame(width: geo.size.width/3, height: 4)
                                .padding(.leading, geo.size.width/3)
                        }
                        VStack(alignment: .center, spacing: 4.0){
                            
                            Image("BirthdaySymbol")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 45)
                                .tint(Color("buttons"))
                            
                            Text("Birthdays")
                                .font(.caption)
                        }
                        .frame(width: geo.size.width, height: geo.size.height)
                    }
                }.tint(Color("buttons"))
                
                Spacer()
                
               
                
                Button {
                    //Contacts
                    selectedTab = .contacts
                } label: {
                    
                    GeometryReader{ geo in
                        
                        if selectedTab == .contacts{
                            Rectangle()
                                .foregroundColor(.black)
                                .frame(width: geo.size.width/3, height: 4)
                                .padding(.leading, geo.size.width/3)
                        }
                        VStack(alignment: .center){
                            Image(systemName: "person.3")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 70, height: 40)
                            
                            Text("Contacts")
                                .font(.caption)
                            
                        }
                        .frame(width: geo.size.width, height: geo.size.height)
                    }
                    
                    
                }.tint(Color("AccentColor"))
                
                Spacer()
                
                Button {
                    //Notificaton Settings
                    selectedTab = .notifications
                } label: {
                    
                    GeometryReader{ geo in
                        
                        if selectedTab == .notifications {
                            Rectangle()
                                .foregroundColor(.black)
                                .frame(width: geo.size.width/3, height: 4)
                                .padding(.leading, geo.size.width/3)
                        }
                        VStack(alignment: .center, spacing: 4.0){
                            
                            Image(systemName: "bell")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 70, height: 40)
                            
                            Text("Notifications")
                                .font(.caption)
                            
                           
                        }
                        .frame(width: geo.size.width, height: geo.size.height)
                    }
                }.tint(Color("buttons"))
                
            }
            .frame(height: 75)
            .background(Color.white.opacity(0.7))
            .cornerRadius(15)
        }
    }
}

struct CustomTabBar_Previews: PreviewProvider {
    static var previews: some View {
        CustomTabBar(selectedTab: .constant(.contacts))
    }
}
