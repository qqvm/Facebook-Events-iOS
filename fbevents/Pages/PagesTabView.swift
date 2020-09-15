//
//  PagesView.swift
//  fbevents
//
//  Created by User on 14.08.2020.
//  Copyright © 2020 nonced. All rights reserved.
//

import SwiftUI

struct PagesTabView: View {
    @EnvironmentObject var appState: AppState
    @State var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab){
            NavigationView{
                PagesBasicNavView()
            }.navigationViewStyle(StackNavigationViewStyle())
            .tabItem {
                Image(systemName: "star.fill")
                Text("Favorite")
            }
            .tag(0)
            NavigationView{
                PagesBasicNavView(isFavoriteTab: false)
            }.navigationViewStyle(StackNavigationViewStyle())
            .tabItem {
                Image(systemName: "magnifyingglass")
                Text("Search")
            }
            .tag(1)
        }
    }
}

struct PagesView_Previews: PreviewProvider {
    static var previews: some View {
        PagesTabView().environmentObject(AppState())
    }
}
