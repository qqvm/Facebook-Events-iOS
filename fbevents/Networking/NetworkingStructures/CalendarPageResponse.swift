//
//  EventPageResponse.swift
//  fbevents
//
//  Created by User on 07.08.2020.
//  Copyright © 2020 nonced. All rights reserved.
//

import Foundation


extension Networking {
    struct CalendarPageResponse: Codable, ResponseData{
        struct EdgeEntity: Codable{
            var node: NodeEntity
        }
        struct NodeEntity: Codable{
            var id: String
            var name: String
            var coverMediaRenderer: CoverMediaRenderer
            var utcStartTimestamp: Int
            var utcEndTimestamp: Int?
            var isCanceled: Bool
            var eventPlace: EventPlace
            var socialContext: SocialContext
        }
        struct CoverMediaRenderer: Codable{
            struct PhotoEntity: Codable{
                struct ImageEntity: Codable{
                    var uri: String
                }
                struct PhotoEntity: Codable{
                    var id: String
                    var image: ImageEntity
                }
                var photo: PhotoEntity
            }
            var coverPhoto: PhotoEntity?
        }
        struct EventPlace: Codable{
            var name: String
            var id: String
        }
        struct SocialContext: Codable{
            var text: String
        }
        struct PageInfo: Codable{
            var startCursor: String?
            var endCursor: String?
            var hasNextPage: Bool
            var hasPreviousPage: Bool?
        }
        struct ViewerEntity: Codable {
            var viewer: Actor
        }
        struct Actor: Codable {
            var actor: MultiEntity
        }
        struct MultiEntity: Codable {
            var allEvents: EdgesEntity?
            var pendingInvites: EdgesEntity?
        }
        struct EdgesEntity: Codable {
            var edges: [EdgeEntity]
            var pageInfo: PageInfo?
        }
        var data: ViewerEntity?
        var error: GenericError.ErrorMessage?
        var errors: [GenericError.ErrorMessage]?
    }
}
