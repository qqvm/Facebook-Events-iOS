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
    @State var user: User
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
    @State private var isFavorite = false{
        willSet{
            if !isFavorite && newValue{
                _ = self.user.save(dbPool: self.appState.dbPool!)
            }
            else if isFavorite && !newValue{
                _ = self.user.delete(dbPool: self.appState.dbPool!)
            }
        }
    }
    
    var body: some View {
        VStack{
            List{
                if friendEvents.count == 0{
                    EmptySection()
                }
                else{
                    Section{
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
                    }
                }
            }.listStyle(DefaultListStyle())
        }.onAppear(){
            self.isFavorite = user.exists(dbPool: self.appState.dbPool!)
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
        .navigationBarTitle(Text(user.name), displayMode: .inline)
        .navigationBarItems(trailing:
            Button(action: {
                self.isFavorite.toggle()
                NotificationCenter.default.post(name: Notification.Name("NeedRefreshFromDB"), object: self.user.id) // to delete immediately from favorites screen.
            }, label: {Image(systemName: isFavorite ? "star.fill" : "star")})
            
        )
    }
}
