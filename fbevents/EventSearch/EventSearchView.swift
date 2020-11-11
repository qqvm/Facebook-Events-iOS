//
//  ContentView.swift
//  fbappState.searchEvents 
//
//  Created by User on 20.06.2020.
//  Copyright © 2020 nonced. All rights reserved.
//

import SwiftUI


struct EventSearchView: View {
    @EnvironmentObject var appState: AppState
    @State var selectedTab: Int
    @State var nonSearchEvents = [BasicEventData]()
    @State var nonSearchPager = NetworkPager()
    @State var inFocus = [Int](){
        didSet{
            //self.appState.logger.log("LOADED Non Search", inFocus.count, inFocus.last, nonSearchEvents.count, nonSearchEvents.last?.id)
            //self.appState.logger.log("LOADED Search", inFocus.count, inFocus.last, appState.searchEvents.count, appState.searchEvents.last?.id)
            if selectedTab > 0{
                if self.appState.loadComplete && self.appState.settings.token != "" && self.appState.isInternetAvailable /*&& inFocus.count > 0 &&
                    inFocus.count <= (nonSearchEvents.count > 6 ? 6 : nonSearchEvents.count)*/ &&
                    inFocus.last == nonSearchEvents.last?.id && inFocus.last != oldValue.last{
                    self.loadNonSearchEventsPage()
                }
            }
            else if self.appState.loadComplete && self.appState.settings.token != "" && self.appState.isInternetAvailable && inFocus.count > 0 /*&& inFocus.count <= (appState.searchEvents.count > 7 ? 7 : appState.searchEvents.count)*/ && inFocus.contains(appState.searchEvents.last?.id ?? -1) && inFocus.last != oldValue.last{
                self.appState.settings.filterOptions.searchKeyword == "" ? self.loadEventDiscoverPage() : self.loadEventSearchPageByKeyword()
            }
        }
    }
    
    var body: some View {
        VStack{
            List{
                ForEach(selectedTab > 0 ? nonSearchEvents : appState.searchEvents, id: \.id) { event in
                    NavigationLink(destination: EventView(eventId: event.id)) {
                        EventPlateView(event: event)
                    }.buttonStyle(PlainButtonStyle())
                    .onAppear(){
                        DispatchQueue.main.async {
                            if !self.inFocus.contains(event.id){
                                self.inFocus.append(event.id)
                            }
                        }
                    }
                    .onDisappear(){
                        DispatchQueue.main.async {
                            self.inFocus.removeAll(where: {$0 == event.id})
                        }
                    }
                }
            }.listStyle(DefaultListStyle())
        }
        .onAppear(){
            if self.appState.settings.token != "" && (self.selectedTab > 0 ? self.nonSearchEvents.count == 0 : self.appState.searchEvents.count == 0) && self.appState.isInternetAvailable {
                self.refreshEvents()
            }
            else if self.appState.settings.token != "" && self.appState.settings.filterChanged && self.appState.isInternetAvailable{
                self.appState.searchPager.reset()
                self.refreshEvents()
                self.appState.settings.filterChanged = false
                self.appState.settings.saveAll()
            }
            else{
                for event in self.appState.searchEvents{
                    if let dbEvent = Event.get(id: event.id, dbPool: self.appState.cacheDbPool!){
                        let index = self.getEventIndex(eventId: event.id)
                        if self.selectedTab > 0 && index != -1{
                            self.nonSearchEvents[index] = dbEvent
                        }
                        else if self.selectedTab == 0 && index != -1{
                            self.appState.searchEvents[self.getEventIndex(eventId: event.id)] = dbEvent
                        }
                    }
                }
            }
        }
        .navigationBarItems(leading: MenuButtonView(),
                            trailing:
            HStack{
                RefreshButtonView(action: {withAnimation{self.refreshEvents()}})
                if self.selectedTab == 0{
                    Button(action: {withAnimation{self.appState.showSearchFilter.toggle()}}, label: {
                        Image(systemName: "slider.horizontal.3")
                            .font(.system(size: UserSettings.buttonSize, weight: .light, design: .default))
                    })
                        .padding(.trailing)
                }
        })
    }
}
