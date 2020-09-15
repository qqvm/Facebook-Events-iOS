//
//  EventPostsResponse.swift
//  fbevents
//
//  Created by User on 07.08.2020.
//  Copyright © 2020 nonced. All rights reserved.
//

import Foundation


extension Networking {
    struct EventPostsResponse: Codable, ResponseData{
        struct DataEntity: Codable {
            var event: EventEntity?
        }
        struct EventEntity: Codable {
            var eventID: String
            var pinnedStories: EdgesEntity
            var stories: EdgesEntity
            var id: String
        }
        struct EdgesEntity: Codable {
            struct Edge: Codable {
                struct Node: Codable {
                    struct Message: Codable {
                        var text: String
                    }
                    struct Actor: Codable {
                        struct Picture: Codable {
                            var uri: String
                        }
                        var __typename: String
                        var id: String
                        var name: String
                        var picture: Picture
                    }
                    var storyID: String
                    var url: String
                    var actors: [Actor]
                    var message: Message?
                    var timestamp: Int
                    var id: String
                }
                var node: Node
            }
            var edges: [Edge]
        }
        var data: DataEntity?
        var error: GenericError.ErrorMessage?
        var errors: [GenericError.ErrorMessage]?
    }
}
