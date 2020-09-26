//
//  ContentModalsView.swift
//  fbevents
//
//  Created by User on 20.08.2020.
//  Copyright © 2020 nonced. All rights reserved.
//

import SwiftUI
import SwiftDate

struct ContentModalsView: View {
    var notificationPublisher = NotificationCenter.default.publisher(for: Notification.Name("NotificationOpened"))
    var urlPublisher = NotificationCenter.default.publisher(for: Notification.Name("URLOpened"))
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var appState: AppState
    @State var showEventSheet = false
    @State var notificationId = 0
    
    var body: some View {
        VStack{
            VStack{
                Text("")
                .frame(width: 0, height: 0)
            }
            .onReceive(self.urlPublisher) {
                if let localUrl = ($0.object as? URL)?.absoluteString.replacingOccurrences(of: "fbevents://", with: ""){
                    let urlContainer = localUrl.split(separator: "/")
                    if urlContainer.count == 2{
                        let id = Int(urlContainer[1]) ?? 0
                        if urlContainer[0] == "event"{
                            DispatchQueue.main.async {
                                self.notificationId = id
                                self.showEventSheet = true
                            }
                        }
                        else if urlContainer[0] == "user"{}
                        else if urlContainer[0] == "page"{}
                    }
                }
            }
            if showEventSheet{
                VStack{
                    Text("")
                    .frame(width: 0, height: 0)
                }
                .sheet(isPresented: self.$showEventSheet, onDismiss: {
                    self.appState.selectedView = self.appState.previousView
                    self.notificationId = 0
                }, content: {
                        NavigationView{
                            VStack{
                                if self.notificationId > 0{
                                    VStack{
                                        EventView(eventId: self.notificationId).environmentObject(self.appState)
                                    }
                                    .navigationBarTitle("", displayMode: .inline)
                                    .navigationBarItems(trailing: CloseButtonView(){
                                        self.showEventSheet = false
                                    })
                                }
                                else{
                                    Text("Failed to load event.")
                                }
                            }
                        }.background(self.colorScheme == .light ? Color(red: 0.95, green: 0.95, blue: 0.95) : Color(red: 0.13, green: 0.13, blue: 0.13))
                    })
            }
            VStack{
                Text("")
                .frame(width: 0, height: 0)
            }
            .sheet(isPresented: self.$appState.showExport){
                ShareView(activityItems: [self.appState.exportURL]).onDisappear(){
                    do{
                        try FileManager.default.removeItem(at: self.appState.exportURL)
                    }
                    catch{
                        self.appState.logger.log(error)
                    }
                }
            }
            VStack{
                Text("")
                .frame(width: 0, height: 0)
            }
            .sheet(isPresented: self.$appState.showImport){
                FilePicker(){urls in
                    if let url = urls.first {
                        self.appState.restoreSettings(from: url)
                    }
                }
            }
            VStack{
                Text("")
                .frame(width: 0, height: 0)
            }
            .alert(isPresented: self.$appState.showError) {
                Alert(title: Text("Error"),
                    message: Text(self.appState.errorDescription), dismissButton: .default(Text("Okay")))
                }
            VStack{
                Text("")
                .frame(width: 0, height: 0)
            }
            .onReceive(self.notificationPublisher) {
                do{
                    if let notificationId = $0.object as? String {
                        let notificationContainer = notificationId.split(separator: "_")
                        if notificationContainer.count == 2{
                            if notificationContainer[0] == "event"{
                                DispatchQueue.main.async {
                                    self.notificationId = Int(notificationContainer[1]) ?? 0
                                    self.showEventSheet = true
                                }
                            }
                            else if notificationContainer[0] == "friend"{
                                self.notificationId = Int(notificationContainer[1]) ?? 0
                                try self.appState.dbPool!.read{db in
                                    if let friend = try User.fetchOne(db, key: self.notificationId){
                                        if friend.birthDay != nil && friend.birthMonth != nil{
                                            if let originalDate = "\(Date().year + 1)-\(friend.birthMonth!)-\(friend.birthDay!) \(self.appState.settings.birthdayNotificationHour):\(self.appState.settings.birthdayNotificationMinute)".toDate()?.date{
                                                if true{
                                                    let date = originalDate - self.appState.settings.birthdayNotificationIntervalDays.days
                                                    SetNotification(id: "friend_\(friend.id)", title: friend.name, subtitle: "has a birthday on \(AppState.getFormattedDate(Int(originalDate.timeIntervalSince1970), isLong: true))", date: date)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                catch{
                    self.appState.logger.log(error)
                    DispatchQueue.main.async {
                        self.appState.errorDescription = error.localizedDescription
                        self.appState.showError = true
                    }
                }
            }
        }
    }
}

struct ContentModalsView_Previews: PreviewProvider {
    static var previews: some View {
        ContentModalsView().environmentObject(AppState())
    }
}
