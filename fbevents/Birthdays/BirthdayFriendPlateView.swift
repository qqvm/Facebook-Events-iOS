//
//  BirthdayFriendPlateView.swift
//  fbevents
//
//  Created by User on 13.08.2020.
//  Copyright © 2020 nonced. All rights reserved.
//

import SwiftUI
import SDWebImageSwiftUI
import SwiftDate

struct BirthdayPlateView: View {
    @EnvironmentObject var appState: AppState
    @State var friend: Friend
    @State var notifyEnabled = false
    
    func updateNotificationStatus(){
        ProcessNotificationIdentifiers(){ids in
            DispatchQueue.main.async {
                self.notifyEnabled = ids.contains(String("friend_\(self.friend.id)"))
            }
        }
    }
    
    func setNotification(){
        if self.friend.birthdate != nil{
            if let originalDate = "\(Date().year)-\(self.friend.birthMonth!)-\(self.friend.birthDay!) \(self.appState.settings.birthdayNotificationHour):\(self.appState.settings.birthdayNotificationMinute)".toDate()?.date{
                if true{
                    let date = originalDate - self.appState.settings.birthdayNotificationIntervalDays.days
                    SetNotification(id: "friend_\(self.friend.id)", title: self.friend.name, subtitle: "has a birthday on \(self.friend.birthdate!)", date: date)
                }
            }
        }
    }
    
    var body: some View {
        HStack{
            if self.appState.settings.downloadImages || self.appState.selectedView == .favorites{
                WebImage(url: URL(string: friend.picture))
                    .resizable()
                    .frame(width: 70, height: 70, alignment: .leading)
                    .padding(.trailing)
            }
            VStack(alignment: .leading){
                Text(friend.name)
                    .font(.title)
                    .fontWeight(.thin)
                Text(friend.birthdate ?? "")
                    .font(.headline)
                    .fontWeight(.thin)
            }
            Spacer()
            Button(action: {
                self.notifyEnabled.toggle()
                if self.notifyEnabled {
                    self.setNotification()
                }
                else{
                    DeleteNotification(id: "friend_\(self.friend.id)")
                }
            }){
                Image(systemName: notifyEnabled ? "bell.fill" : "bell")
            }.padding(.trailing)
        }.onAppear(){
            self.updateNotificationStatus()
        }
    }
}
