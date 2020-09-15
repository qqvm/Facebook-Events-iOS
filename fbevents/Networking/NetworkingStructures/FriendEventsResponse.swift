//
//  FriendEventsResponse.swift
//  fbevents
//
//  Created by User on 08.08.2020.
//  Copyright © 2020 nonced. All rights reserved.
//

import Foundation


extension Networking {
    struct FriendEventsResponse: Codable, ResponseData{
        struct DataNode: Codable {
            struct PageItems: Codable {
                struct PageInfo: Codable{
                    var startCursor: String?
                    var endCursor: String?
                    var hasNextPage: Bool
                    var hasPreviousPage: Bool?
                }
                struct Edge: Codable {
                    struct EdgeNode: Codable {
                        struct EventTitle: Codable {
                            var text: String
                        }
                        struct EventSubtitle: Codable {
                            var text: String
                        }
                        struct EventImage: Codable {
                            var uri: String
                        }
                        struct EventNode: Codable {
                            var id: String
                        }
                        var id: String/*Base64 encoded:
                        app_item:FriendId:2344061033:59*/
                        var title: EventTitle
                        var subtitleText: EventSubtitle
                        var image: EventImage
                        var node: EventNode?
                    }
                    var node: EdgeNode
                }
                var edges: [Edge]
                var pageInfo: PageInfo?
            }
            var pageItems: PageItems // camelCase in JSON
        }
        struct DataEntity: Codable {
            var node: DataNode?
        }
        var data: DataEntity?
        var error: GenericError.ErrorMessage?
        var errors: [GenericError.ErrorMessage]?
    }
}
