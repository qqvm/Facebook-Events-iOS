//
//  EventPlateView.swift
//  fbevents
//
//  Created by User on 23.06.2020.
//  Copyright © 2020 nonced. All rights reserved.
//


import SwiftUI


struct EventPlateView: View{
    @EnvironmentObject var appState: AppState
    @State var event: BasicEventData
    @State private var isFavorite = false{
        willSet{
            let eventData = self.event as? Event
            if eventData != nil {
                if !isFavorite && newValue{
                    _ = eventData!.save(dbPool: self.appState.dbPool!)
                }
                else if isFavorite && !newValue{
                    _ = eventData?.delete(dbPool: self.appState.dbPool!)
                    eventData!.deleteNotification()
                }
            }
        }
    }
    
    var body: some View {
        var eventData = self.event as? Event
        if eventData?.exists(dbPool: self.appState.dbPool!) ?? false{
            if let event = Event.get(id: self.event.id, dbPool: self.appState.dbPool!){
                eventData = nil // We must do this trick because our view wouldn't be invalidated to show new changes otherwise. Probably due to Event? type.
                eventData = event
            }
        }
        else if !(eventData?.isFullInfoAvailable ?? false){
            if let event = Event.get(id: self.event.id, dbPool: self.appState.cacheDbPool!){
                eventData = nil // We must do this trick because our view wouldn't be invalidated to show new changes otherwise. Probably due to Event? type.
                eventData = event
            }
        }
        
        return VStack{
            if eventData != nil{
                VStack{
                    HStack(alignment: .center){
                        if eventData?.isCanceled ?? false {
                            Image(systemName: "minus.circle").foregroundColor(.red)
                        }
                        if eventData?.expired ?? false {
                            Image(systemName: "exclamationmark.arrow.circlepath").foregroundColor(.red)
                        }
                        if eventData?.hasChildEvents ?? false {
                            Image(systemName: "cube.box").foregroundColor(.gray)
                        }
                        else if eventData?.parentEventId ?? 0 > 0 {
                            Image(systemName: "list.number").foregroundColor(.gray)
                        }
                        if eventData?.isOnline ?? false {
                            Image(systemName: "globe").foregroundColor(.gray)
                        }
                        Spacer()
                        Text(eventData!.expired ? "\(AppState.getFormattedDate(eventData!.startTimestamp, withYear: true))" : "\(eventData!.dayTimeSentence)")
                            .font(.headline)
                            .fontWeight(.thin)
                        Spacer()
                        if self.appState.selectedView == .favorites || !eventData!.expired{
                        Button(action: {
                            self.isFavorite.toggle()
                            NotificationCenter.default.post(name: Notification.Name("NeedRefreshFromDB"), object: eventData!.id) // to delete immediately from favorites screen.
                        }, label: {Image(systemName: isFavorite ? "star.fill" : "star").foregroundColor(self.appState.selectedView != .favorites && eventData!.expired ? .gray : .blue)})
                        }
                    }.padding(.horizontal)
                    EventImageView(url: URL(string: eventData!.coverPhoto))
                    Text(eventData!.name)
                        .font(.headline)
                        .padding(.trailing)
                }
                .onAppear(){
                    self.isFavorite = eventData!.exists(dbPool: self.appState.dbPool!)
                }
            }
            else{
                VStack{
                    HStack(alignment: .center){
                        Spacer()
                        Text("\(event.dayTimeSentence)")
                            .font(.headline)
                            .fontWeight(.thin)
                        Spacer()
                        Button(action: {}, label: {Image(systemName: "star")})
                            .disabled(true)

                    }.padding(.horizontal)
                    EventImageView(url: URL(string: event.coverPhoto))
                    Text(event.name)
                        .font(.headline)
                        .padding(.trailing)
                }
            }
        }
    }
}

