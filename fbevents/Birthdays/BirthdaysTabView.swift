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
    @State var currentMonth = Date().month
    @State var monthToLoad = 3
    @State var pager = NetworkPager()
    @State var maxMonthOffset = 12 - Date().month
    @State var minMonthOffset = 1 - Date().month
    @State var monthOffset = 0 {
        didSet{
            if self.monthOffset > maxMonthOffset{
                self.monthOffset = maxMonthOffset
            }
            else if self.monthOffset < minMonthOffset{
                self.monthOffset = maxMonthOffset
            }
            self.offsetMonthName = "0001-\(self.currentMonth + self.monthOffset)-01 00:00".toDate()?.monthName(.default) ?? ""
            if !loadedMonths.contains(offsetMonthName) && self.pager.hasNext{
                self.loadBirthdayFriends()
            }
        }
    }
    @State var offsetMonthName = ""
    @State private var offlineMode = false
    @State var loadedMonths = [String]()
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
                            Button(action: {self.monthOffset -= 1}){
                                Image(systemName: "arrow.left")
                                    .font(.title)
                            }
                            Spacer()
                            Text(self.offsetMonthName)
                            Spacer()
                            Button(action: {self.monthOffset += 1}){
                                Image(systemName: "arrow.right")
                                    .font(.title)
                            }
                        }.onAppear(){
                            self.offsetMonthName = "0001-\(self.currentMonth + self.monthOffset)-01 00:00".toDate()?.monthName(.default) ?? ""
                            if self.offlineMode{
                                self.offlineMode = false
                                self.loadBirthdayFriends()
                            }
                        }
                            .padding(.horizontal)
                            .padding(.top)
                        List(self.all.filter({$0.birthMonth ?? 0 == self.currentMonth + self.monthOffset}), id: \.self){friend in
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
                if self.appState.isInternetAvailable{
                    self.pager.endCursor = "0"
                    print(self.currentMonth, self.maxMonthOffset, self.minMonthOffset)
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
