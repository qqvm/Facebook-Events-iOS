//
//  ContentView.swift
//  fbevents
//
//  Created by User on 21.06.2020.
//  Copyright © 2020 nonced. All rights reserved.
//

import SwiftUI


struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        let drag = DragGesture()
            .onEnded {
                if $0.translation.width < -70 {
                    withAnimation {
                        self.appState.showMenu = false
                    }
                }
                else if $0.translation.width > 70 {
                   withAnimation {
                    self.appState.showMenu = true
                   }
               }
            }
        
        return GeometryReader { geometry in
            ZStack(alignment: .leading) {
                VStack{
                    if self.appState.selectedView == .events {
                        if !self.appState.isInternetAvailable && self.appState.searchEvents.count == 0{
                            if self.appState.showFavoriteFilter{
                                FilterTabView(showFilter: self.$appState.showFavoriteFilter, filterOptions: self.$appState.favoriteFilterOptions)
                            }
                            else{
                                FavoritesTabView()
                            }
                        }
                        else if self.appState.settings.token == ""{
                            LoginView()
                        }
                        else if self.appState.settings.cityId == 0 && self.appState.settings.cityLat == 0{
                            CitySearchNavView()
                        }
                        else if self.appState.showSearchFilter{
                            FilterTabView(showFilter: self.$appState.showSearchFilter, filterOptions: self.$appState.settings.filterOptions)
                        }
                        else{
                            EventsTabView()
                        }
                    }
                    else if self.appState.selectedView == .favorites {
                        if self.appState.showFavoriteFilter{
                            FilterTabView(showFilter: self.$appState.showFavoriteFilter, filterOptions: self.$appState.favoriteFilterOptions)
                        }
                        else{
                            FavoritesTabView()
                        }
                    }
                    else if self.appState.selectedView == .friends {
                        if self.appState.settings.token == ""{
                            LoginView()
                        }
                        else if self.appState.settings.userId == 0{
                            NavigationView {
                                VStack{
                                    Text("")
                                    .frame(width: 0, height: 0)
                                    .onAppear(){
                                        self.appState.isTokenValid(completion: {(_,_) in})
                                    }
                                }
                                .navigationBarTitle(Text("Friends"), displayMode: .inline)
                                .navigationBarItems(leading: MenuButtonView())
                            }.navigationViewStyle(StackNavigationViewStyle())
                        }
                        else{
                            FriendsTabView()
                        }
                    }
                    else if self.appState.selectedView == .birthdays {
                        if self.appState.settings.token == ""{
                            LoginView()
                        }
                        else{
                            BirthdaysTabView()
                        }
                    }
                    else if self.appState.selectedView == .pages {
                        if self.appState.settings.token == ""{
                            LoginView()
                        }
                        else{
                            PagesTabView()
                        }
                    }
                    else if self.appState.selectedView == .settings {
                        SettingsView()
                    }
                    else if self.appState.selectedView == .about {
                        InfoView()
                    }
                    ContentModalsView() // Container for app wide modal views.
                }
                .background(self.colorScheme == .light ? Color(red: 0.95, green: 0.95, blue: 0.95) : Color(red: 0.13, green: 0.13, blue: 0.13))
                .frame(width: geometry.size.width, height: geometry.size.height)
                .offset(x: self.appState.showMenu ? (UIDevice.current.orientation.isLandscape ? geometry.size.width/3 : geometry.size.width/2) : 0)
                .disabled(self.appState.showMenu)
                if self.appState.showMenu {
                    MenuView()
                        .frame(width: UIDevice.current.orientation.isLandscape ? geometry.size.width/3 : geometry.size.width/2)
                    .transition(.move(edge: .leading))
                }
                else if self.appState.loadComplete == false && !(geometry.frame(in: .global).maxY <= 0){
                    HStack{
                        Spacer()
                        LoadBasicView()
                        Spacer()
                    }
                }
            }
            .gesture(drag)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(AppState())
    }
}
