//
//  FriendListPageResponse.swift
//  fbevents
//
//  Created by User on 08.08.2020.
//  Copyright © 2020 nonced. All rights reserved.
//

import Foundation


extension Networking {
    struct FriendListPageResponse: Codable, ResponseData{
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
                        struct Title: Codable {
                            var text: String
                        }
                        struct Image: Codable {
                            var uri: String
                        }
                        struct SubNode: Codable {
                            var id: String
                        }
                        var id: String/*Base64 encoded:
                         app_item:UserId:2356318349:2*/
                        var title: Title
                        var subtitleText: Title?
                        var image: Image
                        var node: SubNode?
                    }
                    var node: EdgeNode
                }
                var edges: [Edge]
                var pageInfo: PageInfo?
            }
            var pageItems: PageItems // camelCase in JSON
        }
        struct DataEntity: Codable {
            var node: DataNode
        }
        var data: DataEntity?
        var error: GenericError.ErrorMessage?
        var errors: [GenericError.ErrorMessage]?
    }
}
