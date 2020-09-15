//
//  EventFriendView.swift
//  fbevents
//
//  Created by User on 12.07.2020.
//  Copyright © 2020 nonced. All rights reserved.
//

import SwiftUI


struct FriendsTabView: View {
    @EnvironmentObject var appState: AppState
    @State var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab){
            NavigationView{
                FriendsBasicNavView()
            }.navigationViewStyle(StackNavigationViewStyle())
            .tabItem {
                Image(systemName: "star.fill")
                Text("Favorite")
            }
            .tag(0)
            NavigationView{
                FriendsBasicNavView(isFavoriteTab: false)
            }.navigationViewStyle(StackNavigationViewStyle())
            .tabItem {
                Image(systemName: "person.3")
                Text("All")
            }
            .tag(1)
        }
    }
}
