//
//  BirthdaysViewModel.swift
//  fbevents
//
//  Created by User on 13.08.2020.
//  Copyright © 2020 nonced. All rights reserved.
//

import Foundation
import SwiftDate


extension BirthdaysTabView{
    func loadBirthdayFriendsFromCache(){
        do{
            self.all.removeAll()
            let friends = try self.appState.dbPool!.read(User.fetchAll)
            self.all.append(contentsOf: friends.filter({$0.birthdate != nil || $0.birthDay != nil}))
        }
        catch{
            self.appState.logger.log(error)
        }
    }
    
    func loadBirthdayFriends(){
        // Pager is not needed here, because Facebook says we cannot access more monthes but we can.
        let requestVars = Networking.BirthdayFriendsVariables(offsetMonth: self.currentMonth)
        
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        if let requestVarsJson = try? encoder.encode(requestVars) {
            if let requestVarsFinal = String(data: requestVarsJson, encoding: .utf8) {
                var components = URLComponents(url: URL(string: "https://graph.facebook.com/graphql")!, resolvingAgainstBaseURL: false)!
                components.queryItems = [
                    URLQueryItem(name: "doc_id", value: "3198768853546898"),
                    URLQueryItem(name: "locale", value: appState.settings.locale),
                    URLQueryItem(name: "variables", value: requestVarsFinal),
                    URLQueryItem(name: "fb_api_req_friendly_name", value: "BirthdayCometRootQuery"),
                    URLQueryItem(name: "fb_api_caller_class", value: "RelayModern"),
                    URLQueryItem(name: "server_timestamps", value: "true")
                ]
                appState.networkManager?.postURL(urlComponents: components, withToken: true){(response: Networking.BirthdayFriendsResponse) in
                    let slices = [(0, response.data?.today), (1, response.data?.recent), (2, response.data?.upcoming)]
                    for (i, slice) in slices{
                        if let edges = slice?.allFriends.edges{
                            for edge in edges{
                                if let node = edge.node{
                                    let friend = User(
                                        id: Int(node.id)!,
                                        name: node.name,
                                        picture: node.profilePicture.uri,
                                        isFriend: true,
                                        birthDay: node.birthdate.day,
                                        birthMonth: node.birthdate.month,
                                        birthdate: node.birthdate.text
                                    )
                                    if friend.exists(dbPool: self.appState.dbPool!){
                                        _ = friend.save(dbPool: self.appState.dbPool!)
                                    }
                                    DispatchQueue.main.async {
                                        switch i{
                                        case 0:
                                            if !self.today.contains(friend){
                                                self.today.append(friend)
                                            }
                                        case 1:
                                        if !self.recent.contains(friend){
                                            self.recent.append(friend)
                                        }
                                        case 2:
                                        if !self.upcoming.contains(friend){
                                            self.upcoming.append(friend)
                                        }
                                        default:
                                            break
                                        }
                                    }
                                }
                            }
                        }
                    }
                    if let edges = response.data?.viewer.allFriendsByBirthdayMonth.edges{
                        for edge in edges{
                            for friendEdge in edge.node.friends.edges{
                                if let node = friendEdge.node{
                                    var friend = User(
                                        id: Int(node.id)!,
                                        name: node.name,
                                        picture: node.profilePicture.uri,
                                        isFriend: true, birthDay: node.birthdate.day,
                                        birthMonth: node.birthdate.month,
                                        birthdate: node.birthdate.text
                                    )
                                    if friend.birthdate == nil && friend.birthDay != nil && friend.birthMonth != nil{
                                        let date = "0001-\(friend.birthMonth!)-\(friend.birthDay!) 00:00".toDate()
                                        friend.birthdate = "\(friend.birthDay!) \(date?.monthName(.default) ?? "/ \(friend.birthMonth!)")"
                                    }
                                    if friend.exists(dbPool: self.appState.dbPool!){
                                        _ = friend.save(dbPool: self.appState.dbPool!)
                                    }
                                    DispatchQueue.main.async {
                                        if !self.all.contains(friend){
                                            self.all.append(friend)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    DispatchQueue.main.async {
                        self.loadedMonths.append(contentsOf: [self.currentMonth,
                          self.currentMonth + 1 > 12 ? self.currentMonth + 1 - 12 : self.currentMonth + 1,
                          self.currentMonth + 2 > 12 ? self.currentMonth + 2 - 12 : self.currentMonth + 2])
                    }
                }
            }
        }
    }
}
