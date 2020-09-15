//
//  EventPageResponse.swift
//  fbevents
//
//  Created by User on 07.08.2020.
//  Copyright © 2020 nonced. All rights reserved.
//

import Foundation


extension Networking {
    struct EventSearchPageResponse: Codable, ResponseData{
        struct EdgeEntity: Codable{
            var node: NodeEntity
        }
        struct NodeEntity: Codable{
            var id: String
            var name: String
            var coverPhoto: PhotoEntity?
            var startTimestamp: Int
            var endTimestamp: Int
            var dayTimeSentence: String
            var eventPlace: EventPlace
            var previewSocialContext: SocialContext
            var eventDescription: Text
            var location: LocationInfo
            var canViewerChangeGuestStatus: Bool
            var viewerHasPendingInvite: Bool
            var isChildEvent: Bool
            var hasChildEvents: Bool
            var canViewerPurchaseOnsiteTickets: Bool
            var eventBuyTicketDisplayUrl: String?
        }
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
        struct EventPlace: Codable{
            var name: String
            var contextualName: String?
            var strongId__: String
        }
        struct Text: Codable{
            var text: String
        }
        struct Id: Codable{
            var id: String
        }
        struct SocialContext: Codable{
            var textWithEntities: Text
            var actors: [Id]
        }
        struct LocationInfo: Codable{
            struct Geocode: Codable{
                var address: String
                var city: String
                var state: String?
            }
            var latitude: Double
            var longitude: Double
            var reverseGeocode: Geocode
        }
        struct PageInfo: Codable{
            var startCursor: String?
            var endCursor: String?
            var hasNextPage: Bool
            var hasPreviousPage: Bool
        }
        struct ViewerEntity: Codable {
            var viewer: SEventsEntity
        }
        struct SEventsEntity: Codable {
            var suggestedEvents: EventsEntity
        }
        struct EventsEntity: Codable {
            var events: EdgesEntity
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
