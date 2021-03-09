//
//  BirthdayFriendsResponse.swift
//  fbevents
//
//  Created by User on 08.08.2020.
//  Copyright © 2020 nonced. All rights reserved.
//

import Foundation


extension Networking {
    struct BirthdayFriendsResponse: Codable, ResponseData{
        struct Friends: Codable {
            struct Edge: Codable {
                struct EdgeNode: Codable {
                    struct ProfilePicture: Codable {
                        var uri: String
                    }
                    struct Bithdate: Codable {
                        var day: Int
                        var month: Int
                        var year: Int?
                        var text: String?
                    }
                    var id: String
                    var name: String
                    var profilePicture: ProfilePicture
                    var birthdate: Bithdate
                }
                var node: EdgeNode?
            }
            var edges: [Edge]
        }
        struct ViewerEntity: Codable {
            struct ByMonth: Codable {
                struct ViewerEdge: Codable {
                    struct ViewerNode: Codable {
                        var monthNameInIso8601: String
                        var friends: Friends
                    }
                    var node: ViewerNode
                    var cursor: String
                }
                struct PageInfo: Codable{
                    var startCursor: String?
                    var endCursor: String?
                    var hasNextPage: Bool
                    var hasPreviousPage: Bool?
                }
                var edges: [ViewerEdge]
                var pageInfo: PageInfo?
            }
            var allFriendsByBirthdayMonth: ByMonth
            var allFriends: Friends?
        }
        struct Data: Codable {
            struct FriendsEntity: Codable {
                var allFriends: Friends
            }
            var today: FriendsEntity?
            var recent: FriendsEntity?
            var upcoming: FriendsEntity?
            var viewer: ViewerEntity
        }
        var data: Data?
        var error: GenericError.ErrorMessage?
        var errors: [GenericError.ErrorMessage]?
    }
}
