//
//  FavoritesView.swift
//  fbevents
//
//  Created by User on 21.06.2020.
//  Copyright © 2020 nonced. All rights reserved.
//

import SwiftUI

struct FavoritesTabView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        TabView(selection: self.$appState.favoritesSelectedTab){
            NavigationView{
                FavoritesBasicView()
                    .navigationBarTitle(Text(self.appState.selectedView == .events ? "Offline mode" : "Favorites"), displayMode: .inline)
            }.navigationViewStyle(StackNavigationViewStyle())
            .tabItem {
                Image(systemName: self.appState.selectedView == .events ? "star" : "star.fill")
                Text(self.appState.selectedView == .events ? "Cached" : "Favorites")
            }
            .tag(0)
            NavigationView{
                FavoritesBasicView(isFavoriteTab: false)
                    .navigationBarTitle(Text(self.appState.selectedView == .events ? "Offline mode" : "Favorites"), displayMode: .inline)
            }.navigationViewStyle(StackNavigationViewStyle())
            .tabItem {
                Image(systemName: "arrow.counterclockwise.circle")
                Text(self.appState.selectedView == .events ? "Expired" : "Past")
            }
            .tag(1)
        }
    }
}

struct FavoritesView_Previews: PreviewProvider {
    static var previews: some View {
        FavoritesTabView().environmentObject(AppState())
    }
}
