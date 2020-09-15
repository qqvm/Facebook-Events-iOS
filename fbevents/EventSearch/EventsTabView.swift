//
//  CalendarView.swift
//  fbevents
//
//  Created by User on 16.08.2020.
//  Copyright © 2020 nonced. All rights reserved.
//

import SwiftUI

struct EventsTabView: View {
    @EnvironmentObject var appState: AppState
    @State var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab){
            NavigationView{
                EventSearchView(selectedTab: selectedTab)
                    .navigationBarTitle(Text("Events"), displayMode: .inline)
            }.navigationViewStyle(StackNavigationViewStyle())
            .tabItem {
                Image(systemName: "magnifyingglass")
                Text("Search")
            }
            .tag(0)
            NavigationView{
                EventSearchView(selectedTab: selectedTab)
                    .navigationBarTitle(Text("Events"), displayMode: .inline)
            }.navigationViewStyle(StackNavigationViewStyle())
            .tabItem {
                Image(systemName: "envelope.badge")
                Text("Invites")
            }
            .tag(1)
            NavigationView{
                EventSearchView(selectedTab: selectedTab)
                    .navigationBarTitle(Text("Events"), displayMode: .inline)
            }.navigationViewStyle(StackNavigationViewStyle())
            .tabItem {
                Image(systemName: "arrow.counterclockwise.circle")
                Text("Past")
            }
            .tag(2)
        }
    }
}
