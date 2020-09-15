//
//  SettingsView.swift
//  fbevents
//
//  Created by User on 21.06.2020.
//  Copyright © 2020 nonced. All rights reserved.
//

import SwiftUI
import SwiftDate
import SDWebImageSwiftUI


struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.colorScheme) var colorScheme
    @State var newWord = ""
    @State var selectedTab = 0
    @State var cacheSize = "(0 KB)"
    @State var diskSize = "(0 KB)"
    @State var showSheet = false
    @State var showDoneAlert = false
    @State var showConfirmationAlert = false
    @State var confirmationAlertMessage = ""
    @State var confirmationAlertAction: ()->() = {}
    @State var confirmationAlertCancelAction: ()->() = {}
    @State var views = SelectedView.allCases.map{$0.rawValue}
    @State var startViewRawValue = ""{
        didSet{
            if let view = SelectedView(rawValue: startViewRawValue){
                self.appState.settings.startView = view
            }
        }
    }
    
    func generateActionSheet() -> ActionSheet {
        let buttons = self.views.map {option in
            Alert.Button.default(Text(option), action: {
                self.startViewRawValue = option
            })
        }
        return ActionSheet(title: Text("Select start screen:"),
                           buttons: buttons + [Alert.Button.cancel()])
    }
    
    func removeWord(_ index: IndexSet) {
        self.appState.settings.bannedWords.remove(atOffsets: index)
    }
    
    func checkStorageSize(){
        let cacheBytes = (try? FileManager.default.allocatedSizeOfDirectory(at: FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0])) ?? 0
        cacheSize = cacheBytes < 1024 * 1024 ? "(\(cacheBytes / 1024) KB)" : "(\(cacheBytes / 1024 / 1024) MB)"
        let diskBytes = ((try? FileManager.default.allocatedSizeOfDirectory(at: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0])) ?? 0)
        diskSize = diskBytes < 1024 * 1024 ? "(\(diskBytes / 1024) KB)" : "(\(diskBytes / 1024 / 1024) MB)"
    }
    
    var body: some View {
        return TabView(selection: $selectedTab){
            BaseSettingsNavView{
                Form{
                    Section(header: Text("City")){
                        CitySearchBasicView()
                        .disabled(!self.appState.isInternetAvailable)
                    }
                    Section(header: Text("Settings")){
                    Group{
                        Toggle("Download images", isOn: self.$appState.settings.downloadImages)
                        Toggle("Use coordinates instead of city", isOn: self.$appState.settings.useCoordinates)
                        Toggle("Delete expired events", isOn: self.$appState.settings.deleteExpired)
                        Toggle("Delete cache on exit", isOn: self.$appState.settings.deleteCacheOnExit)
                        Toggle("Search pages instead of places", isOn: self.$appState.settings.usePagesSearchInsteadOfPlaces)
                        HStack{
                            Text("Reload event's data after")
                                .fixedSize()
                            TextField("", value: self.$appState.settings.reloadIntervalHours, formatter: NumberFormatter()){
                                if self.appState.settings.reloadIntervalHours > 24{
                                    self.appState.settings.reloadIntervalHours = 24
                                }
                                UserDefaults.standard.set(self.appState.settings.reloadIntervalHours, forKey: "reloadIntervalHours")
                            }
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.numberPad)
                                .frame(width: 40, height: 20)
                            Text("hour(s)")
                        }
                        Toggle("Do not show events with banned words", isOn: self.$appState.settings.enableBanning)
                        }
                    }.padding(.trailing)
                }
            }
                .onTapGesture {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil) // hide keyboard on tap
                }
                .tabItem {
                    Image(systemName: "gear")
                    Text("Main settings")
                }
                .tag(0)
            BaseSettingsNavView{
                Form{
                    Section{
                        VStack{
                            HStack{
                                Image(systemName: "gift")
                                Text("Birthday")
                                    .fixedSize()
                            }
                            HStack{
                                TextField("", value: self.$appState.settings.birthdayNotificationIntervalDays, formatter: NumberFormatter()){
                                    UserDefaults.standard.set(self.appState.settings.birthdayNotificationIntervalDays, forKey: "birthdayNotificationIntervalDays")
                                }
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .keyboardType(.numberPad)
                                    .frame(width: 40, height: 20)
                                Text("day(s) before at")
                                    .fixedSize()
                                TextField("", text: self.$appState.settings.birthdayNotificationHour){
                                    UserDefaults.standard.set(self.appState.settings.birthdayNotificationHour, forKey: "birthdayNotificationHour")
                                }
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .keyboardType(.numberPad)
                                    .frame(width: 40, height: 20)
                                Text(":")
                                    .fixedSize()
                                TextField("", text: self.$appState.settings.birthdayNotificationMinute){
                                    UserDefaults.standard.set(self.appState.settings.birthdayNotificationMinute, forKey: "birthdayNotificationMinute")
                                }
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .keyboardType(.numberPad)
                                    .frame(width: 40, height: 20)
                                }
                        }.padding()
                        VStack{
                            HStack{
                                Image(systemName: "calendar")
                                Text("Event")
                                    .fixedSize()
                            }
                            HStack{
                                TextField("", value: self.$appState.settings.notificationIntervalHours, formatter: NumberFormatter()){
                                    UserDefaults.standard.set(self.appState.settings.notificationIntervalHours, forKey: "notificationIntervalHours")
                                }
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .keyboardType(.numberPad)
                                    .frame(width: 40, height: 20)
                                Text("hour(s)")
                                    .fixedSize()
                                TextField("", value: self.$appState.settings.notificationIntervalMinutes, formatter: NumberFormatter()){
                                    UserDefaults.standard.set(self.appState.settings.notificationIntervalMinutes, forKey: "notificationIntervalMinutes")
                                }
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .keyboardType(.numberPad)
                                    .frame(width: 40, height: 20)
                                Text("min(s) before")
                                    .fixedSize()
                            }
                        }.padding()
                    }
                }
            }
                .onTapGesture {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil) // hide keyboard on tap
                }
                .tabItem {
                    Image(systemName: "bell")
                    Text("Notification settings")
                }
                .tag(1)
            BaseSettingsNavView{
                VStack{
                    HStack{
                        TextField("Word to be banned", text: self.$newWord){
                            if !self.appState.settings.bannedWords.contains( self.newWord.lowercased()) {
                                self.appState.settings.bannedWords.insert(self.newWord.lowercased(), at: 0)
                            }
                        }
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        GoButtonView(action: {
                            if !self.appState.settings.bannedWords.contains( self.newWord.lowercased()) {
                                self.appState.settings.bannedWords.insert(self.newWord.lowercased(), at: 0)
                            }
                        })
                    }
                    List{
                        ForEach(self.appState.settings.bannedWords, id: \.self){ el in
                            HStack{
                                Text(el)
                                Spacer()
                                Button(action: {
                                    if let index = self.appState.settings.bannedWords.firstIndex(of: el){
                                        self.appState.settings.bannedWords.remove(at: index)
                                    }
                                }, label:
                                    {Image(systemName: "trash").foregroundColor(.red)})
                            }.padding(.trailing)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }.listStyle(DefaultListStyle())
                        .border(Color(UIColor.systemGray4))
                        .cornerRadius(3)
                }.padding()
            }
                .onTapGesture {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil) // hide keyboard on tap
                }
                .tabItem {
                    Image(systemName: "delete.left")
                    Text("Banned words")
                }
                .tag(2)
            BaseSettingsNavView{
                VStack(alignment: .center, spacing: 10){
                    Button(action: {
                        self.showSheet.toggle()}){
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(self.colorScheme == .light ? Color.black : Color.white)
                            .frame(width: 180, height: 40, alignment: .center)
                            .opacity(0.4)
                            .overlay(
                                HStack{
                                    Image(systemName: "desktopcomputer")
                                    Text("Start screen")
                                }
                                .font(.system(size: 22))
                        )
                            .actionSheet(isPresented: self.$showSheet){
                                self.generateActionSheet()
                            }
                    }
                    Button(action: {self.appState.backupSettings()}){
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(self.colorScheme == .light ? Color.black : Color.white)
                            .frame(width: 180, height: 40, alignment: .center)
                            .opacity(0.4)
                            .overlay(
                                HStack{
                                    Image(systemName: "tray.and.arrow.up")
                                    Text("Back up")
                                }
                                .font(.system(size: 22))
                            )
                    }
                    Button(action: {self.appState.showImport = true}){
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(self.colorScheme == .light ? Color.black : Color.white)
                            .frame(width: 180, height: 40, alignment: .center)
                            .opacity(0.4)
                            .overlay(
                                HStack{
                                    Image(systemName: "tray.and.arrow.down")
                                    Text("Restore")
                                        .fixedSize()
                                }
                                    .font(.system(size: 22))
                            )
                    }
                    Button(action: {
                        self.appState.deleteCache(){
                            DispatchQueue.main.async {
                                self.checkStorageSize()
                                self.showDoneAlert.toggle()
                            }
                        }
                    }){
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(self.colorScheme == .light ? Color.black : Color.white)
                            .frame(width: 180, height: 50, alignment: .center)
                            .opacity(0.4)
                            .overlay(
                                VStack(alignment: .center, spacing: .zero){
                                    HStack{
                                        Image(systemName: "trash")
                                        Text("Wipe cache")
                                            .fixedSize()
                                    }.font(.system(size: 22))
                                    Text(self.cacheSize)
                                        .font(.system(size: 14))
                                }.foregroundColor(.orange)
                            )
                        }.buttonStyle(PlainButtonStyle())
                    .alert(isPresented: self.$showDoneAlert){
                        Alert(title: Text("Done"))
                    }
                    Button(action: {
                        self.confirmationAlertMessage = "This will delete all data including credentials and settings."
                        self.confirmationAlertAction = {
                            self.appState.resetState(){
                                DispatchQueue.main.async {
                                    self.checkStorageSize()
                                    self.showDoneAlert.toggle()
                                }
                            }
                        }
                        self.showConfirmationAlert.toggle()
                    }){
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(self.colorScheme == .light ? Color.black : Color.white)
                            .frame(width: 180, height: 50, alignment: .center)
                            .opacity(0.4)
                            .overlay(
                                VStack(alignment: .center, spacing: .zero){
                                    HStack{
                                        Image(systemName: "trash")
                                        Text("Wipe data")
                                            .fixedSize()
                                    }.font(.system(size: 22))
                                    Text(self.diskSize)
                                        .font(.system(size: 14))
                                }.foregroundColor(.red)
                            )
                        }.buttonStyle(PlainButtonStyle())
                }
            }
                .tabItem {
                    Image(systemName: "hammer")
                    Text("Advanced")
                }
                .tag(3)
        }
        .alert(isPresented: self.$showConfirmationAlert){
            Alert(title: Text("Confirmation"), message: Text(confirmationAlertMessage), primaryButton: Alert.Button.destructive(Text("Proceed"), action: confirmationAlertAction), secondaryButton: Alert.Button.cancel(confirmationAlertCancelAction))
        }
        .onAppear(){
            self.checkStorageSize()
            self.startViewRawValue = self.appState.settings.startView.rawValue
        }
        .onDisappear(){
            self.appState.settings.saveAll()
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(selectedTab: 2).environmentObject(AppState())
    }
}
