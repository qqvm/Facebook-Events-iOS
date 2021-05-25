//
//  PageEventsView.swift
//  fbevents
//
//  Created by User on 14.08.2020.
//  Copyright © 2020 nonced. All rights reserved.
//

import SwiftUI

struct PageEventsView: View {
    @EnvironmentObject var appState: AppState
    @State var isSubview = false
    @State var originId = 0
    @State var page: Page
    @State var pageEvents = [BasicEventData]()
    @State var upcomingEventPager = NetworkPager()
    @State var recurringEventPager = NetworkPager()
    @State var eventsInFocus = [Int](){
           didSet{
               //self.appState.logger.log("LOADED", eventsInFocus.count, eventsInFocus.last, pageEvents.count, pageEvents.last?.id)
               if self.appState.loadComplete && self.appState.settings.token != "" && (self.upcomingEventPager.canProceed || self.recurringEventPager.canProceed) &&
                self.appState.isInternetAvailable && self.appState.loadComplete && eventsInFocus.count > 0 /*&&
                   eventsInFocus.count <= (pageEvents.count > 7 ? 7 : pageEvents.count) */&&
                eventsInFocus.last == pageEvents.last?.id && eventsInFocus.last != oldValue.last{
                    self.loadPageUpcomingEventsPage()
                    self.loadPageRecurringEventsPage()
               }
           }
       }
    @State private var isFavorite = false{
        willSet{
            if !isFavorite && newValue{
                _ = self.page.save(dbPool: self.appState.dbPool!)
            }
            else if isFavorite && !newValue{
                _ = self.page.delete(dbPool: self.appState.dbPool!)
            }
        }
    }
    
    var body: some View {
        VStack{
            VStack{
                List(pageEvents, id: \.id) { (event: BasicEventData) in
                    VStack{
                        NavigationLink(destination: EventView(eventId: event.id)) {
                            VStack(alignment: .leading){
                                Text(event.name)
                                    .font(.title)
                                    .fontWeight(.light)
                                Text(event.dayTimeSentence)
                                    .font(.headline)
                                    .fontWeight(.light)
                            }
                                .padding()
                        }.disabled(event.id == self.originId)
                        .buttonStyle(PlainButtonStyle())
                        .onAppear(){
                            DispatchQueue.main.async {
                                if !self.eventsInFocus.contains(event.id){
                                    self.eventsInFocus.append(event.id)
                                }
                            }
                        }
                        .onDisappear(){
                            DispatchQueue.main.async {
                                self.eventsInFocus.removeAll(where: {$0 == event.id})
                            }
                        }
                    }
                }.listStyle(PlainListStyle())
            }
        }.onAppear(){
            self.isFavorite = page.exists(dbPool: self.appState.dbPool!)
            if self.pageEvents.count == 0{
                if self.appState.isInternetAvailable{
                    self.loadPageUpcomingEventsPage()
                    self.loadPageRecurringEventsPage()
                }
                else{
                    self.upcomingEventPager.hasNext = false
                    self.recurringEventPager.hasNext = false
                    self.loadEventsFromCache()
                }
            }
        }
        .navigationBarTitle(Text(page.name), displayMode: .inline)
        .navigationBarItems(trailing:
            Button(action: {
                self.isFavorite.toggle()
                NotificationCenter.default.post(name: Notification.Name("NeedRefreshFromDB"), object: self.page.id) // to delete immediately from favorites screen.
            }, label: {Image(systemName: isFavorite ? "star.fill" : "star")})
            
        )
    }
}
