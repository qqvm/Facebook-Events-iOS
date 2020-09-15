//
//  BirthdaysView.swift
//  fbevents
//
//  Created by User on 12.07.2020.
//  Copyright © 2020 nonced. All rights reserved.
//

import SwiftUI


struct BirthdaysTabView: View {
    @EnvironmentObject var appState: AppState
    @State var selectedTab = 0
    @State var currentMonth = Date().month{
        didSet{
            self.currentMonthName = "0001-\(self.currentMonth)-01 00:00".toDate()?.monthName(.default) ?? ""
            if self.currentMonth == 13{
                self.currentMonth = 1
            }
            else if self.currentMonth == 0{
                self.currentMonth = 12
            }
            if !loadedMonths.contains(currentMonth){
                self.loadBirthdayFriends()
            }
        }
    }
    @State var currentMonthName = ""
    @State private var offlineMode = false
    @State var loadedMonths = [Int]()
    @State var today = [User]()
    @State var recent = [User]()
    @State var upcoming = [User]()
    @State var all = [User]()
    
    var body: some View {
        TabView(selection: $selectedTab){
            BaseBirthdaysNavView{
                VStack{
                    List(self.today, id: \.self){friend in
                        BirthdayPlateView(friend: friend)
                    }.listStyle(PlainListStyle())
                }
            }
            .tabItem {
                Image(systemName: "clock")
                Text("Today")
            }
            .tag(0)
            BaseBirthdaysNavView{
                VStack{
                    List(self.recent, id: \.self){friend in
                        BirthdayPlateView(friend: friend)
                    }.listStyle(PlainListStyle())
                }
            }
            .tabItem {
                Image(systemName: "timer")
                Text("Recent")
            }
            .tag(1)
            BaseBirthdaysNavView{
                VStack{
                    List(self.upcoming, id: \.self){friend in
                        BirthdayPlateView(friend: friend)
                    }.listStyle(PlainListStyle())
                }
            }
            .tabItem {
                Image(systemName: "alarm")
                Text("Upcoming")
            }
            .tag(2)
            BaseBirthdaysNavView{
                VStack{
                    if self.appState.isInternetAvailable{
                        HStack{
                            Button(action: {self.currentMonth -= 1}){
                                Image(systemName: "arrow.left")
                                    .font(.title)
                            }
                            Spacer()
                            Text(self.currentMonthName)
                            Spacer()
                            Button(action: {self.currentMonth += 1}){
                                Image(systemName: "arrow.right")
                                    .font(.title)
                            }
                        }.onAppear(){
                            self.currentMonthName = "0001-\(self.currentMonth)-01 00:00".toDate()?.monthName(.default) ?? ""
                            if self.offlineMode{
                                self.offlineMode = false
                                self.loadBirthdayFriends()
                            }
                        }
                            .padding(.horizontal)
                            .padding(.top)
                        List(self.all.filter({$0.birthMonth ?? 0 == self.currentMonth}), id: \.self){friend in
                            BirthdayPlateView(friend: friend)
                        }.listStyle(PlainListStyle())
                    }
                    else{
                        List(self.all, id: \.self){friend in
                            BirthdayPlateView(friend: friend)
                        }.listStyle(PlainListStyle())
                    }
                }
            }
            .tabItem {
                Image(systemName: "person.3")
                Text("All")
            }
            .tag(3)
        }.onAppear(){
            if self.all.count == 0{
                if self.all.count == 0 && self.appState.isInternetAvailable{
                    self.loadBirthdayFriends()
                }
                else{
                    self.offlineMode = true
                    self.loadBirthdayFriendsFromCache()
                }
            }
        }
    }
}
