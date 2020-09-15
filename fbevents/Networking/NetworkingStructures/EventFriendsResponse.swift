//
//  EventFriendsResponse.swift
//  fbevents
//
//  Created by User on 08.08.2020.
//  Copyright © 2020 nonced. All rights reserved.
//

import Foundation


extension Networking {
    struct EventFriendsResponse: Codable, ResponseData{
        struct EventEntity: Codable {
            struct Users: Codable {
                struct PageInfo: Codable{
                    var startCursor: String?
                    var endCursor: String?
                    var hasNextPage: Bool
                    var hasPreviousPage: Bool?
                }
                struct Edge: Codable {
                    struct EdgeNode: Codable {
                        struct ProfilePicture: Codable {
                            var uri: String
                        }
                        var id: String
                        var name: String
                        var profilePicture: ProfilePicture
                    }
                    var connectionType: String
                    var node: EdgeNode
                }
                var edges: [Edge]
                var pageInfo: PageInfo?
            }
            var id: String
            var eventConnectedUsers: Users // camelCase in JSON
        }
        struct Data: Codable {
            var event: EventEntity
        }
        var data: Data?
        var error: GenericError.ErrorMessage?
        var errors: [GenericError.ErrorMessage]?
    }
}
