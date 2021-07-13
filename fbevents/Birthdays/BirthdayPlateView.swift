//
//  BirthdayFriendPlateView.swift
//  fbevents
//
//  Created by User on 13.08.2020.
//  Copyright © 2020 nonced. All rights reserved.
//

import SwiftUI
import SwiftDate

struct BirthdayPlateView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.colorScheme) var colorScheme
    @State var friend: User
    @State var notifyEnabled = false
    @State private var onTapScaleRatio: CGFloat = 1
    @State var showCustomNotificationView = false
    @State private var customNotificationDate = Date()
    @State private var birthDate = Date()
    
    func updateNotificationStatus(){
        ProcessNotificationIdentifiers(){ids in
            DispatchQueue.main.async {
                self.notifyEnabled = ids.contains(String("friend_\(self.friend.id)"))
            }
        }
    }
    
    func getProposedNotificationDate() -> (Date, Date)?{
        if self.friend.birthDay != nil && self.friend.birthMonth != nil{
            if let originalDate = "\(Date().year)-\(self.friend.birthMonth!)-\(self.friend.birthDay!) \(self.appState.settings.birthdayNotificationHour):\(self.appState.settings.birthdayNotificationMinute)".toDate()?.date{
                if originalDate > Date(){
                    return (originalDate - self.appState.settings.birthdayNotificationIntervalDays.days, originalDate)
                }
                else{
                    return ((originalDate - self.appState.settings.birthdayNotificationIntervalDays.days) + 1.years, originalDate + 1.years)
                }
            }
        }
        return nil
    }
    
    func setNotification(date: Date? = nil, bdate: Date? = nil){
        if !self.friend.exists(dbPool: self.appState.dbPool!){
            _ = self.friend.updateInDB(dbPool: self.appState.dbPool!)
        }
        if date != nil && bdate != nil{
            SetNotification(id: "friend_\(self.friend.id)", title: self.friend.name, subtitle: "has a birthday on \(AppState.getFormattedDate(Int(bdate!.timeIntervalSince1970), isLong: true))", date: date!)
        }
        else if let (notificationDate, birthDate) = getProposedNotificationDate(){
            SetNotification(id: "friend_\(self.friend.id)", title: self.friend.name, subtitle: "has a birthday on \(AppState.getFormattedDate(Int(birthDate.timeIntervalSince1970), isLong: true))", date: notificationDate)
        }
    }
    
    var body: some View {
        HStack{
            ImageView(height: 70, width: 70, imageData: friend.imageData)
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
            }) {
                VStack {
                    Image(systemName: self.notifyEnabled ? "bell.fill" : "bell")
                    .foregroundColor(.blue)
                    .scaleEffect(onTapScaleRatio)
                    .onTapGesture {
                        self.notifyEnabled.toggle()
                        if self.notifyEnabled {
                            self.setNotification()
                        }
                        else{
                            DeleteNotification(id: "friend_\(self.friend.id)")
                        }
                    }
                    .onLongPressGesture(minimumDuration: 0.1, pressing: {inProgress in
                        withAnimation{
                            self.onTapScaleRatio = inProgress ? 4 : 1
                        }
                    }) {
                        if self.notifyEnabled {
                            DispatchQueue.main.async {
                                self.notifyEnabled.toggle()
                            }
                            DeleteNotification(id: "friend_\(self.friend.id)")
                        }
                        else if let dates = self.getProposedNotificationDate(){
                            DispatchQueue.main.async {
                                self.customNotificationDate = dates.0
                                self.birthDate = dates.1
                                if self.birthDate > Date(){
                                    self.showCustomNotificationView = true
                                }
                            }
                        }
                    }
                }.padding(.trailing)
            }
            
            if self.showCustomNotificationView{
                Text("")
                .frame(width: 0, height: 0)
                .sheet(isPresented: $showCustomNotificationView, onDismiss: {
                    self.updateNotificationStatus()
                }){
                    CustomNotificationView(customNotificationDate: self.$customNotificationDate, dateRange: Date()...self.birthDate, title: self.friend.name, subtitle: "has a birthday on \(AppState.getFormattedDate(Int(self.birthDate.timeIntervalSince1970), isLong: true))"){
                        self.setNotification(date: self.customNotificationDate, bdate: self.birthDate)
                        DispatchQueue.main.async {
                            self.notifyEnabled = true
                        }
                    }
                }
            }
        }.onAppear(){
            self.updateNotificationStatus()
        }
    }
}
