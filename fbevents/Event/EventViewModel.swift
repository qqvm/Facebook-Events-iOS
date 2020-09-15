//
//  EventViewModel.swift
//  fbevents
//
//  Created by User on 07.07.2020.
//  Copyright © 2020 nonced. All rights reserved.
//

import SwiftUI


extension EventView{
    func loadEventDetails(){
        self.appState.loadEventDetails(eventId: self.eventId){ev in
            DispatchQueue.main.async{
                self.event = nil // We must do this trick because our view wouldn't be invalidated to show new changes otherwise. Probably due to Event? type.
                self.event = ev
                self.aproxTextHeight = self.appState.getAproxTextHeight(self.event?.eventDescription ?? "")
                NotificationCenter.default.post(name: Notification.Name("NeedRefreshFromDB"), object: self.eventId)
                self.loadEventFriends()
            }
        }
    }
    
    func UpdateNotificationStatus(){
        ProcessNotificationIdentifiers(){ids in
            DispatchQueue.main.async {
                self.notifyEnabled = ids.contains(String("event_\(self.eventId)"))
            }
        }
    }
    
    func loadEventFriends(){
        if !self.friendPager.canProceed {return}
        var connectionTypes = [String]()
        if self.event?.interestedFriends ?? 6 > 5 {connectionTypes.append("INTERESTED")}
        if self.event?.goingFriends ?? 6 > 5 {connectionTypes.append("GOING")}
        if connectionTypes.count == 0 {return} // No need to make request, data is already loaded with loadEventDetails() request.
        let requestVars = Networking.EventFriendsVariables(connectionTypes: connectionTypes, cursor: self.friendPager.endCursor, eventID: self.eventId)
        let encoder = JSONEncoder()
        if let requestVarsJson = try? encoder.encode(requestVars) {
            if let requestVarsFinal = String(data: requestVarsJson, encoding: .utf8) {
                var components = URLComponents(url: URL(string: "https://graph.facebook.com/graphql")!, resolvingAgainstBaseURL: false)!
                components.queryItems = [
                    URLQueryItem(name: "doc_id", value: "3203158023113195"),
                    //backup doc ids 3361469267219014 for "GOING" and 3158525554236503 for "INTERESTED".
                    URLQueryItem(name: "locale", value: appState.settings.locale),
                    URLQueryItem(name: "variables", value: requestVarsFinal),
                    URLQueryItem(name: "fb_api_req_friendly_name", value: "EventCometGuestlistDetailsListUsersSelfRendererQuery"),
                    URLQueryItem(name: "fb_api_caller_class", value: "RelayModern"),
                    URLQueryItem(name: "server_timestamps", value: "true")
                ]
                appState.networkManager?.postURL(urlComponents: components, withToken: true){(response: Networking.EventFriendsResponse) in
                    if let edges = response.data?.event.eventConnectedUsers.edges{
                        var maybeFriends = [User]()
                        var memberFriends = [User]()
                        for edge in edges{
                            let friend = User(id: Int(edge.node.id)!, name: edge.node.name, picture: edge.node.profilePicture.uri, isFriend: true)
                            switch edge.connectionType{
                            case "INTERESTED":
                                maybeFriends.append(friend)
                            case "GOING":
                                memberFriends.append(friend)
                            default:
                                break
                            }
                        }
                        if self.event!.exists(dbPool: self.appState.dbPool!){
                            _ = self.event!.updateInDB(dbPool: self.appState.dbPool!)
                        }
                        if self.event!.exists(dbPool: self.appState.cacheDbPool!){
                            _ = self.event!.updateInDB(dbPool: self.appState.cacheDbPool!)
                        }
                        else{
                            _ = self.event!.save(dbPool: self.appState.cacheDbPool!)
                        }
                        DispatchQueue.main.async{
                            var event = self.event!
                            self.event = nil // We must do this trick because our view wouldn't be invalidated to show new changes otherwise. Probably due to Event? type.
                            maybeFriends.forEach{
                                if !event.maybeFriends.contains($0){
                                    event.maybeFriends.append($0)
                                }
                            }
                            memberFriends.forEach{
                                if !event.memberFriends.contains($0){
                                    event.memberFriends.append($0)
                                }
                            }
                            self.event = event
                        }
                        if let info = response.data?.event.eventConnectedUsers.pageInfo{
                            DispatchQueue.main.async{
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
