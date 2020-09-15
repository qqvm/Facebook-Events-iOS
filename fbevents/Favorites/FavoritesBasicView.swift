//
//  FavoritesBaseView.swift
//  fbevents
//
//  Created by User on 14.08.2020.
//  Copyright © 2020 nonced. All rights reserved.
//

import SwiftUI

struct FavoritesBasicView: View {
    @EnvironmentObject var appState: AppState
    @State var events = [Event]()
    @State var isFavoriteTab = true
    
    var body: some View {
        VStack(alignment: .leading){
            List {
                ForEach(events, id: \.id) { (event: Event) in
                    NavigationLink(destination: EventView(eventId: event.id)) {
                        EventPlateView(event: event)
                    }.buttonStyle(PlainButtonStyle())
                }
            }.listStyle(DefaultListStyle())
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name("NeedRefreshFromDB"))) {
                if $0.object is Int {
                    self.refreshEventsFromDb()
                }
            }
        }
        .onAppear(){
            self.refreshEventsFromDb()
        }
        .navigationBarTitle(Text(self.appState.selectedView == .events ? "Offline search" : "Favorites"), displayMode: .inline)
        .navigationBarItems(leading:
            MenuButtonView(), trailing:
            HStack{
                RefreshButtonView(action: {withAnimation{self.refreshEventsFromDb()}})
                Button(action: {withAnimation{self.appState.showFavoriteFilter.toggle()}}, label: {
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: UserSettings.buttonSize, weight: .light, design: .default))
                })
            })
    }
}

struct FavoritesBaseView_Previews: PreviewProvider {
    static var previews: some View {
        FavoritesBasicView().environmentObject(AppState())
    }
}
