//
//  EventBaseView.swift
//  fbevents
//
//  Created by User on 09.08.2020.
//  Copyright © 2020 nonced. All rights reserved.
//

import SwiftUI

struct EventView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var appState: AppState
    @State var event: Event? = nil
    @State var eventId: Int
    @State var originId = 0
    @State var showShareView = false
    @State var showCustomNotificationView = false
    @State private var customNotificationDate = Date()
    @State var notifyEnabled = false
    @State var aproxTextHeight: CGFloat = 0
    @State private var onTapScaleRatio: CGFloat = 1
    @State var friendPager = NetworkPager(){
        didSet{
            if self.friendPager.canProceed{
                loadEventFriends()
            }
        }
    }
    @State var isFavorite = false{
        willSet{
            if !isFavorite && newValue{
                _ = self.event?.save(dbPool: self.appState.dbPool!)
            }
            else if isFavorite && !newValue{
                _ = self.event?.delete(dbPool: self.appState.dbPool!)
                self.event?.deleteNotification()
            }
        }
    }
    
    var body: some View {
        GeometryReader{ (reader: GeometryProxy) in
        VStack(alignment: .leading){
            if self.event != nil{
                ScrollView{
                    VStack{
                        VStack{
                            Text(self.event!.name)
                                .font(.title)
                                .fontWeight(.thin)
                            HStack{
                                if self.event!.parentEventId != nil{
                                    NavigationLink(destination: EventView(eventId: self.event!.parentEventId!, originId: self.originId)){
                                        Image(systemName: "cube.box")
                                    }.padding(.trailing)
                                        .disabled(self.event!.parentEventId == self.originId)
                                }
                                if self.event!.childEvents != nil || self.event!.parentEventId != nil{
                                    if self.event!.childEvents!.count > 0{
                                        NavigationLink(destination: EventChildsView(originId: self.originId, childs: self.event!.childEvents!)){
                                            Image(systemName: "list.number")
                                        }.padding(.trailing)
                                    }
                                    else if self.event!.parentEventId ?? 0 > 0{
                                        NavigationLink(destination: EventChildsView(originId: self.originId, parentId: self.event!.parentEventId!)){
                                            Image(systemName: "list.number")
                                        }.padding(.trailing)
                                    }
                                }
                                else if self.event!.parentEventId != nil{
                                    NavigationLink(destination: EventChildsView(originId: self.originId, parentId: self.event!.parentEventId!)){
                                        Image(systemName: "list.number")
                                    }.padding(.trailing)
                                }
                                if self.event!.onlineUrl != nil{
                                    if URL(string: self.event!.onlineUrl!) != nil{
                                        Button(action: {
                                            UIApplication.shared.open(URL(string: self.event!.onlineUrl!)!)
                                        }, label: {Image(systemName: "globe")})
                                            .padding(.trailing)
                                    }
                                }
                                if self.event!.eventBuyTicketDisplayUrl != nil{
                                    if URL(string: self.event!.eventBuyTicketDisplayUrl!) != nil{
                                        Button(action: {
                                            UIApplication.shared.open(URL(string: self.event!.eventBuyTicketDisplayUrl!)!)
                                        }, label: {Image(systemName: "creditcard")})
                                            .padding(.trailing)
                                    }
                                }
                                if self.event!.hasStories ?? true{ // display if state is unknown
                                    NavigationLink(destination: EventPostsView(eventId: self.eventId, isEventFavorite: self.isFavorite)){
                                        Image(systemName: "message")
                                            .padding(.trailing)
                                    }
                                }
                                if !self.event!.expired{
                                    Button(action: {
                                    }) {
                                        VStack {
                                            Image(systemName: self.notifyEnabled ? "bell.fill" : "bell")
                                            .scaleEffect(self.onTapScaleRatio)
                                            .onTapGesture{
                                                self.notifyEnabled.toggle()
                                                if self.notifyEnabled {
                                                    self.event!.setNotification()
                                                    if !self.isFavorite{
                                                        self.isFavorite.toggle()
                                                    }
                                                }
                                                else{
                                                    self.event!.deleteNotification()
                                                }
                                            }
                                            .onLongPressGesture(minimumDuration: 0.1, pressing: {inProgress in
                                                withAnimation{
                                                    self.onTapScaleRatio = inProgress ? 4 : 1
                                                }
                                            }) {
                                                if self.notifyEnabled {
                                                    DispatchQueue.main.async{
                                                        self.notifyEnabled.toggle()
                                                    }
                                                    self.event!.deleteNotification()
                                                }
                                                else{
                                                    DispatchQueue.main.async{
                                                        self.customNotificationDate = self.event!.getProposedNotificationDate()
                                                        self.showCustomNotificationView = true
                                                    }
                                                }
                                            }
                                        }.padding(.trailing)
                                    }
                                }
                                Button(action: {
                                    self.isFavorite.toggle()
                                    NotificationCenter.default.post(name: Notification.Name("NeedRefreshFromDB"), object: self.event!.id)// to delete immediately and go to fav screen.
                                }, label: {Image(systemName: self.isFavorite ? "star.fill" : "star")})
                                    .padding(.trailing)
                                    .disabled(self.appState.selectedView != .favorites && self.event!.expired)
                            }.padding(.bottom)
                        }
                        EventImageView(url: URL(string: self.event!.coverPhoto))
                        VStack(alignment: .leading, spacing: 10){
                            if self.event!.endDate != nil{
                                if self.event!.isMultiYear{
                                    Text(AppState.getFormattedDate(self.event!.startTimestamp, withYear: true) + " - ")
                                    .fontWeight(.semibold)
                                    Text(AppState.getFormattedDate(self.event!.endTimestamp, isLong: self.event!.multiDay, withYear: true))
                                    .fontWeight(.semibold)
                                }
                                else if self.event!.multiDay{
                                    Text(AppState.getFormattedDate(self.event!.startTimestamp) + " - ")
                                    .fontWeight(.semibold)
                                    Text(AppState.getFormattedDate(self.event!.endTimestamp, isLong: self.event!.multiDay))
                                    .fontWeight(.semibold)
                                }
                                else {
                                    Text(AppState.getFormattedDate(self.event!.startTimestamp) + " - ")
                                    .fontWeight(.semibold)
                                        + Text(AppState.getFormattedDate(self.event!.endTimestamp, isLong: self.event!.multiDay))
                                    .fontWeight(.semibold)
                                }
                            }
                            if self.event!.eventPlaceAddress.contains(",") &&
                                UIApplication.shared.canOpenURL(URL(string: "https://maps.apple.com/?q=\(self.event!.eventPlaceAddress.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed) ?? "")")!){
                                Button(action: {
                                    UIApplication.shared.open(URL(string: "https://maps.apple.com/?q=\(self.event!.eventPlaceAddress.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed) ?? "")")!)
                                }, label: {Text(self.event!.eventPlaceAddress)})
                            }
                            else if self.event!.eventPlaceAddress != ""{
                                Text(self.event!.eventPlaceAddress)
                                    .foregroundColor(Color(self.colorScheme == .light ? .darkGray : .lightGray))
                            }
                            if self.event!.hosts.count > 0{
                                ForEach(self.event!.hosts, id: \.id){(host: Actor) in
                                    Group{
                                        if host.type == .page{
                                            NavigationLink(destination: PageEventsView(isSubview: true, originId: self.originId, pageId: host.id)){
                                                Text(host.name).fixedSize(horizontal: false, vertical: true)
                                            }
                                        }
                                        else if host.type == .user{
                                            NavigationLink(destination: UserEventsView(isSubview: true, originId: self.originId,
                                                                user: User(id: host.id, name: host.name, picture: host.picture))){
                                                Text(host.name).fixedSize(horizontal: false, vertical: true)
                                            }
                                        }
                                    }
                                }
                            }
                            else{
                                Text(self.event!.eventPlaceName == self.event!.eventPlaceAddress ? "No place name" : self.event!.eventPlaceName)
                                    .foregroundColor(Color(self.colorScheme == .light ? .darkGray : .lightGray))
                            }
                            HStack{
                                if self.event!.categoryName != nil{
                                    Text(self.event!.categoryName!)
                                        .foregroundColor(Color(self.colorScheme == .light ? .darkGray : .lightGray))
                                }
                                else{
                                    Text(self.event!.previewSocialContext)
                                    .foregroundColor(Color(self.colorScheme == .light ? .darkGray : .lightGray))
                                }
                                if self.event!.goingGuests != nil &&  self.event!.interestedGuests != nil && self.event!.goingFriends != nil &&  self.event!.interestedFriends != nil{
                                    if self.event!.goingGuests != 0 {
                                        Image(systemName: "person.badge.plus")
                                        Text("\(self.event!.goingGuests!)")
                                            .foregroundColor(Color(self.colorScheme == .light ? .darkGray : .lightGray))
                                    }
                                    if self.event!.interestedGuests != 0 {
                                        Image(systemName: "person")
                                        Text("\(self.event!.interestedGuests!)")
                                            .foregroundColor(Color(self.colorScheme == .light ? .darkGray : .lightGray))
                                    }
                                    if self.event!.memberFriends.count != 0 {
                                        NavigationLink(destination: FriendsBasicView(isSubview: true, originId: self.originId, friends: self.event!.memberFriends, isFavoriteTab: false)){
                                            Image(systemName: "person.crop.circle.badge.plus")
                                            Text("\(self.event!.memberFriends.count)")
                                                .foregroundColor(Color(self.colorScheme == .light ? .darkGray : .lightGray))
                                        }
                                    }
                                    if self.event!.maybeFriends.count != 0 {
                                        NavigationLink(destination: FriendsBasicView(isSubview: true, originId: self.originId, friends: self.event!.maybeFriends, isFavoriteTab: false)){
                                            Image(systemName: "person.crop.circle")
                                            Text("\(self.event!.maybeFriends.count)")
                                                .foregroundColor(Color(self.colorScheme == .light ? .darkGray : .lightGray))
                                        }
                                    }
                                }
                                Spacer()
                            }
                            if self.event!.isCanceled != nil{
                                if self.event!.isCanceled!{
                                    Text("Canceled")
                                        .foregroundColor(Color(.red))
                                }
                            }
                            if self.aproxTextHeight > 0{
                                VStack{
                                    TextView(text: self.event!.eventDescription)
                                        .frame(width: reader.frame(in: .global).origin.x > 30 ? UIScreen.main.bounds.width / 2 :  UIScreen.main.bounds.width - 40, height: reader.frame(in: .global).origin.x > 30 ? self.aproxTextHeight * 1.55 : self.aproxTextHeight, alignment: .leading)
                                    .padding(.trailing)
                                }
                            }
                            else{
                                VStack{
                                    Text(self.event!.eventDescription)
                                    .multilineTextAlignment(.leading)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .lineLimit(nil)
                                }
                            }
                        }
                    }
                }
                .sheet(isPresented: self.$showShareView){
                    ShareView(activityItems: [URL(string: "https://www.facebook.com/events/\(self.event!.id)/")!])
                }
                if self.showCustomNotificationView{
                    VStack{
                        Text("")
                        .frame(width: 0, height: 0)
                    }
                    .sheet(isPresented: self.$showCustomNotificationView, onDismiss: {
                        self.UpdateNotificationStatus()
                    }){
                        CustomNotificationView(customNotificationDate: self.$customNotificationDate, dateRange: self.event!.startDate > Date() ? Date()...self.event!.startDate : self.event!.endDate == nil ? Date()...Calendar.current.date(byAdding: .day, value: 1, to: Date())! : Date()...self.event!.endDate!, title: self.event!.name, subtitle: self.event!.getProposedNotificationSubtitle()){
                            self.event?.setNotification(date: self.customNotificationDate)
                            DispatchQueue.main.async {
                                if !self.isFavorite{
                                    self.isFavorite.toggle()
                                }
                                self.notifyEnabled = true
                            }
                        }
                    }
                }
            }
        }
        .padding(.horizontal)
        .navigationBarTitle(self.event?.hasChildEvents ?? false ? "Parent event" : "Event")
        .navigationBarItems(trailing:
            ShareButtonView(action: {withAnimation{self.showShareView.toggle()}}))
        .onAppear(){
            if self.originId == 0 {self.originId = self.eventId}
            self.UpdateNotificationStatus()
            self.isFavorite = Event.exists(id: self.eventId, dbPool: self.appState.dbPool!)
            if self.isFavorite{
                if let event = Event.get(id: self.eventId, dbPool: self.appState.dbPool!){
                    self.event = event
                    self.aproxTextHeight = self.appState.getAproxTextHeight(event.eventDescription)
                }
            }
            if let event = Event.get(id: self.eventId, dbPool: self.appState.cacheDbPool!){
                if self.event == nil{
                    self.event = event
                    self.aproxTextHeight = self.appState.getAproxTextHeight(event.eventDescription)
                }
            }
            if self.event == nil{
                self.loadEventDetails()
            }
            else if !self.event!.isFullInfoAvailable || self.event!.lastUpdate == nil{
                self.loadEventDetails()
                
            }
            else if self.event!.lastUpdate!.difference(in: .hour, from: Date()) ?? 0 >= self.appState.settings.reloadIntervalHours{
                self.loadEventDetails()
            }
        }
        }
    }
}
