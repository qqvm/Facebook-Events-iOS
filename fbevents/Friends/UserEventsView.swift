//
//  FriendEventsView.swift
//  fbevents
//
//  Created by User on 14.08.2020.
//  Copyright © 2020 nonced. All rights reserved.
//

import SwiftUI

struct UserEventsView: View {
    @EnvironmentObject var appState: AppState
    @State var isSubview = false
    @State var originId = 0
    @State var friendEvents = [BasicEventData]()
    @State var eventPager = NetworkPager()
    @State var user: BasicActorData
    @State var eventsInFocus = [Int](){
           didSet{
               //self.appState.logger.log("LOADED", eventsInFocus.count, eventsInFocus.last, friendEvents.count, friendEvents.last?.id)
               if self.appState.loadComplete && self.appState.settings.token != "" && self.eventPager.canProceed &&
                   self.appState.isInternetAvailable /*&& eventsInFocus.count > 0 &&
                   eventsInFocus.count <= (friendEvents.count > 7 ? 7 : friendEvents.count)*/ &&
               eventsInFocus.contains(friendEvents.last?.id ?? -1) && eventsInFocus.last != oldValue.last{
                   self.loadUserEventsPage()
               }
           }
       }
    
    var body: some View {
        VStack{
            List{
                ForEach(friendEvents, id: \.id) { event in
                    NavigationLink(destination: EventView(eventId: event.id)) {
                        EventPlateView(event: event)
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
            }.listStyle(DefaultListStyle())
        }.onAppear(){
            if self.friendEvents.count == 0{
                if self.appState.isInternetAvailable{
                    self.loadUserEventsPage()
                }
                else{
                    self.eventPager.hasNext = false
                    self.loadEventsFromCache()
                }
            }
        }
        .navigationBarTitle(Text((user as? User)?.isFriend ?? false ? (self.appState.isInternetAvailable ? "Friend's events" : "Friend's events (cached)") : "User's events"), displayMode: .inline)
    }
}
