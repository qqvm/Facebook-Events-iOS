//
//  FriendEventsResponse.swift
//  fbevents
//
//  Created by User on 08.08.2020.
//  Copyright © 2020 nonced. All rights reserved.
//

import Foundation


extension Networking {
    struct PageEventsResponse: Codable, ResponseData{
        struct PageEntity: Codable {
            struct PageInfo: Codable{
                var startCursor: String?
                var endCursor: String?
                var hasNextPage: Bool
                var hasPreviousPage: Bool?
            }
            struct UpcomingEvents: Codable {
                struct Edge: Codable {
                    struct EdgeNode: Codable {
                        struct TextContainer: Codable {
                            var text: String
                        }
                        var id: String
                        var shortTimeLabel: String // camelCase
                        var name: String
                        var suggestedEventContextSentence: TextContainer
                        
                    }
                    var node: EdgeNode
                }
                var edges: [Edge]
                var pageInfo: PageInfo?
            }
            struct RecurringEvents: Codable {
                struct Edge: Codable {
                    struct EdgeNode: Codable {
                        struct TextContainer: Codable {
                            var text: String
                        }
                        var id: String
                        var timeContext: String // camelCase
                        var name: String
                    }
                    var node: EdgeNode
                }
                var edges: [Edge]
                var pageInfo: PageInfo?
            }
            var upcomingEvents: UpcomingEvents?
            var upcomingRecurringEvents: RecurringEvents? // camelCase
        }
        struct DataEntity: Codable {
            var page: PageEntity?
        }
        var data: DataEntity?
        var error: GenericError.ErrorMessage?
        var errors: [GenericError.ErrorMessage]?
    }
}
