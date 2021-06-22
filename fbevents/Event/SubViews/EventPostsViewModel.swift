//
//  EventPostsViewModel.swift
//  fbevents
//
//  Created by User on 11.09.2020.
//  Copyright © 2020 nonced. All rights reserved.
//

import SwiftUI

extension EventPostsView{
    func loadEventPosts(){
        let vars = Networking.EventPostsVariables(eventID: String(eventId))
        let encoder = JSONEncoder()
        if let json = try? encoder.encode(vars) {
            if let requestVariables = String(data: json, encoding: .utf8) {
                var components = URLComponents(url: URL(string: "https://graph.facebook.com/graphql")!, resolvingAgainstBaseURL: false)!
                components.queryItems = [
                    URLQueryItem(name: "doc_id", value: "3090546670968432"),
                    // backup doc_id 4653693114671195
                    URLQueryItem(name: "locale", value: appState.settings.locale),
                    URLQueryItem(name: "variables", value: requestVariables),
                    URLQueryItem(name: "fb_api_req_friendly_name", value: "EventsRecentPostsCardRendererQuery"),
                    URLQueryItem(name: "fb_api_caller_class", value: "RelayModern"),
                    URLQueryItem(name: "server_timestamps", value: "true")
                ]
                appState.networkManager?.postURL(urlComponents: components, withToken: true){(response: Networking.EventPostsResponse) in
                    var pinnedPosts = [Post]()
                    var posts = [Post]()
                    if let edges = response.data?.event?.pinnedStories.edges{
                        for edge in edges{
                            if edge.node.message?.text == nil{continue}
                            let post = Post(
                                id: self.appState.getIdFromFbString(edge.node.storyID),
                                parentId: self.eventId,
                                parentType: "Event",
                                text: edge.node.message?.text ?? "",
                                time: edge.node.timestamp,
                                actors: edge.node.actors.map{(actor: Networking.EventPostsResponse.EdgesEntity.Edge.Node.Actor) in
                                    Actor(id: self.appState.getIdFromFbString(actor.id), type: ActorType(rawValue: actor.__typename)!, name: actor.name, picture: actor.picture.uri)
                                },
                                pinned: true, lastUpdate: Date()
                            )
                            pinnedPosts.append(post)
                        }
                        pinnedPosts.sort(by: {$0.time < $1.time})
                    }
                    if let edges = response.data?.event?.stories.edges{
                        for edge in edges{
                            if edge.node.message?.text == nil{continue}
                            let post = Post(
                                id: self.appState.getIdFromFbString(edge.node.storyID),
                                parentId: self.eventId,
                                parentType: "Event", text: edge.node.message?.text ?? "",
                                time: edge.node.timestamp,
                                actors: edge.node.actors.map{(actor: Networking.EventPostsResponse.EdgesEntity.Edge.Node.Actor) in
                                    Actor(id: self.appState.getIdFromFbString(actor.id), type: ActorType(rawValue: actor.__typename)!, name: actor.name, picture: actor.picture.uri)
                                },
                                lastUpdate: Date()
                            )
                            if !pinnedPosts.map({$0.text}).contains(post.text){
                                posts.append(post)
                            }
                        }
                        posts.sort(by: {$0.time < $1.time})
                    }
                    posts.insert(contentsOf: pinnedPosts, at: 0)
                    if self.isEventFavorite{
                        posts.forEach{(post: Post) in
                            if post.exists(dbPool: self.appState.dbPool!){
                                _ = post.updateInDB(dbPool: self.appState.dbPool!)
                            }
                            else{
                                _ = post.save(dbPool: self.appState.dbPool!)
                            }
                        }
                    }
                    DispatchQueue.main.async {
                        self.posts.append(contentsOf: posts)
                    }
                }
            }
        }
    }
}
