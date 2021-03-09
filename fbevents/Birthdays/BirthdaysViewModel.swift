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

        let requestVars = self.pager.endCursor == "0" ? Networking.BirthdayFriendsVariables(scale: 2) : Networking.BirthdayFriendsVariables(count: self.monthToLoad, cursor: self.pager.endCursor)
        print(self.pager.endCursor, self.pager.hasNext)
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        if let requestVarsJson = try? encoder.encode(requestVars) {
            if let requestVarsFinal = String(data: requestVarsJson, encoding: .utf8) {
                var components = URLComponents(url: URL(string: "https://graph.facebook.com/graphql")!, resolvingAgainstBaseURL: false)!
                components.queryItems = [
                    URLQueryItem(name: "doc_id", value: self.pager.endCursor == "0" ? "3706366812763626" : "3681233908586032"), // backup doc_id 3198768853546898
                    URLQueryItem(name: "locale", value: appState.settings.locale),
                    URLQueryItem(name: "variables", value: requestVarsFinal),
                    URLQueryItem(name: "fb_api_req_friendly_name", value: self.pager.endCursor == "0" ? "BirthdayCometRootQuery" : "BirthdayCometMonthlyBirthdaysRefetchQuery"),
                    URLQueryItem(name: "fb_api_caller_class", value: "RelayModern"),
                    URLQueryItem(name: "server_timestamps", value: "true")
                ]
                appState.networkManager?.postURL(urlComponents: components, withToken: true){(response: Networking.BirthdayFriendsResponse) in
                    let slices = [(0, response.data?.today?.allFriends), (1, response.data?.recent?.allFriends), (2, response.data?.upcoming?.allFriends), (3, response.data?.viewer.allFriends)]
                    for (i, slice) in slices{
                        if let edges = slice?.edges{
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
                                        case 3:
                                        if !self.recent.contains(friend){
                                            self.recent.append(friend)
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
                            DispatchQueue.main.async {
                                print("\(self.monthOffset): \(edge.node.monthNameInIso8601)")
                                self.loadedMonths.append(edge.node.monthNameInIso8601)
                            }
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
                    if let info = response.data?.viewer.allFriendsByBirthdayMonth.pageInfo{
                        DispatchQueue.main.async {
                            self.pager.endCursor = info.endCursor ?? ""
                            self.pager.startCursor = info.startCursor ?? ""
                            self.pager.hasNext = info.hasNextPage
                            self.pager.hasPrevious = info.hasPreviousPage ?? false
                        }
                    }
                }
            }
        }
    }
}
