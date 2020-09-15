//
//  FriendsViewModel.swift
//  fbevents
//
//  Created by User on 08.08.2020.
//  Copyright © 2020 nonced. All rights reserved.
//

import SwiftUI
import GRDB


extension UserEventsView{
    func loadEventsFromCache(){
        do{
            self.friendEvents.removeAll()
            let events = try self.appState.cacheDbPool!.read(Event.filter(Column("isFriend") == true).fetchAll)
            self.friendEvents.append(contentsOf: events.filter({($0.memberFriends.map{$0.id == self.user.id}).contains(true)}))
            events.filter({($0.maybeFriends.map{$0.id == self.user.id}).contains(true)}).forEach{(event: Event) in
                if !self.friendEvents.contains(where: {$0.id == event.id}){self.friendEvents.append(event)}
            }
        }
        catch{
            self.appState.logger.log(error)
        }
    }
    
    func loadUserEventsPage(){
        if !self.eventPager.canProceed {return}
        let requestVars = Networking.FriendEventsVariables(id: Data("app_collection:\(self.user.id):2344061033:59".utf8).base64EncodedString(), cursor: self.eventPager.endCursor)

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        if let requestVarsJson = try? encoder.encode(requestVars) {
            if let requestVarsFinal = String(data: requestVarsJson, encoding: .utf8) {
                var components = URLComponents(url: URL(string: "https://graph.facebook.com/graphql")!, resolvingAgainstBaseURL: false)!
                components.queryItems = [
                    URLQueryItem(name: "doc_id", value: "3339315492793103"),
                    URLQueryItem(name: "locale", value: appState.settings.locale),
                    URLQueryItem(name: "variables", value: requestVarsFinal),
                    URLQueryItem(name: "fb_api_req_friendly_name", value: "ProfileCometAppCollectionListRendererPaginationQuery"),
                    URLQueryItem(name: "fb_api_caller_class", value: "RelayModern"),
                    URLQueryItem(name: "server_timestamps", value: "true")
                ]
                appState.networkManager?.postURL(urlComponents: components, withToken: true){(response: Networking.FriendEventsResponse) in
                    if let edges = response.data?.node?.pageItems.edges{
                        for edge in edges{
                            let event = SimpleEvent(
                                id: Int(edge.node.node?.id ?? "0")!,
                                name: edge.node.title.text,
                                coverPhoto: edge.node.image.uri,
                                dayTimeSentence: edge.node.subtitleText.text
                            )
                            DispatchQueue.main.async {
                                if !self.friendEvents.contains(where: {$0.id == event.id}){
                                    self.friendEvents.append(event)
                                }
                            }
                        }
                        if let info = response.data?.node?.pageItems.pageInfo{
                            DispatchQueue.main.async {
                                self.eventPager.endCursor = info.endCursor ?? ""
                                self.eventPager.startCursor = info.startCursor ?? ""
                                self.eventPager.hasNext = info.hasNextPage
                                self.eventPager.hasPrevious = info.hasPreviousPage ?? false
                            }
                        }
                    }
                }
            }
        }
    }
}

extension FriendsBasicView{
    func refreshFriends() {
        if self.isFavoriteTab{
            loadFriendsFromDB()
        }
        else{
            self.friendPager.reset()
            self.friends.removeAll()
            self.friendsInFocus.removeAll()
            self.loadMyFriendsPage()
        }
        withAnimation{
            self.showSearchField?.wrappedValue = false
        }
    }
    
    func loadFriendsFromDB(){
        do{
            self.friends.removeAll()
            let friends = try self.appState.dbPool!.read(User.fetchAll)
            if self.searchKeyword?.wrappedValue ?? "" != ""{
                self.friends.append(contentsOf: friends.filter({$0.name.lowercased().contains((self.searchKeyword?.wrappedValue ?? "").lowercased())}))
            }
            else{
                self.friends.append(contentsOf: friends)
            }
        }
        catch{
            self.appState.logger.log(error)
        }
    }
    
    func loadMyFriendsPage(){
        if !self.friendPager.canProceed || self.appState.settings.userId == 0{return}
        var requestVars = Networking.FriendListPageVariables(cursor: self.friendPager.endCursor, id: Data("app_collection:\(self.appState.settings.userId):2356318349:2".utf8).base64EncodedString())
        if self.searchKeyword?.wrappedValue ?? "" != ""{
            requestVars.search = self.searchKeyword?.wrappedValue ?? ""
        }
        
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        if let requestVarsJson = try? encoder.encode(requestVars) {
            if let requestVarsFinal = String(data: requestVarsJson, encoding: .utf8) {
                var components = URLComponents(url: URL(string: "https://graph.facebook.com/graphql")!, resolvingAgainstBaseURL: false)!
                components.queryItems = [
                    URLQueryItem(name: "doc_id", value: "3339315492793103"),
                    URLQueryItem(name: "locale", value: appState.settings.locale),
                    URLQueryItem(name: "variables", value: requestVarsFinal),
                    URLQueryItem(name: "fb_api_req_friendly_name", value: "ProfileCometAppCollectionListRendererPaginationQuery"),
                    URLQueryItem(name: "fb_api_caller_class", value: "RelayModern"),
                    URLQueryItem(name: "server_timestamps", value: "true")
                ]
                appState.networkManager?.postURL(urlComponents: components, withToken: true){(response: Networking.FriendListPageResponse) in
                    if let edges = response.data?.node.pageItems.edges{
                        for edge in edges{
                            var id = 0
                            if let data = Data(base64Encoded: edge.node.id){
                                if let str = String(data: data, encoding: .utf8)?.split(separator: ":").last{
                                    if let num = Int(str){
                                        id = num
                                    }
                                }
                            }
                            else if Int(edge.node.node?.id ?? "0") ?? 0 > 0{
                                id = Int(edge.node.node?.id ?? "0") ?? 0
                            }
                            let friend = User(
                                id: id,
                                name: edge.node.title.text,
                                picture: edge.node.image.uri,
                                isFriend: true
                            )
                            DispatchQueue.main.async {
                                if !self.friends.contains(friend){
                                    self.friends.append(friend)
                                }
                            }
                        }
                        if let info = response.data?.node.pageItems.pageInfo{
                            DispatchQueue.main.async {
                                self.friendPager.endCursor = info.endCursor ?? ""
                                self.friendPager.startCursor = info.startCursor ?? ""
                                self.friendPager.hasNext = info.hasNextPage
                                self.friendPager.hasPrevious = info.hasPreviousPage ?? false
                            }
                        }
                    }
                }
            }
        }
    }
}
