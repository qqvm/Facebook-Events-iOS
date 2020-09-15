//
//  EventDetailsResponse.swift
//  fbevents
//
//  Created by User on 07.08.2020.
//  Copyright © 2020 nonced. All rights reserved.
//

import Foundation


extension Networking {
    struct EventDetailsResponse: Codable, ResponseData{
        struct EventDataHolder: Codable{
            var event: EventData
        }
        struct EventData: Codable{
            struct EventHosts: Codable{
                struct HostsNode: Codable{
                    struct HostNode: Codable{
                        struct HostProfilePicture: Codable{
                            var uri: String
                        }
                        var __typename: String
                        var id: String
                        var name: String
                        var profilePicture: HostProfilePicture
                    }
                    var node: HostNode
                }
                var edges: [HostsNode]
            }
            struct OnlineEventSetup: Codable{
                var thirdPartyUrl: String?
            }
            struct CountNum: Codable{
                var count: Int
            }
            struct EventCategoryData: Codable{
                var label: String
                var categoryId: String
            }
            struct EventDescription: Codable{
                struct EventDescriptionEntity: Codable{
                    struct EventDescriptionEntityUrl: Codable{
                        var url: String
                    }
                    var offset: Int
                    var length: Int
                    var entity: EventDescriptionEntityUrl
                }
                var text: String
                var ranges: [EventDescriptionEntity]
            }
            struct CoverPhoto: Codable{
                struct PhotoEntity: Codable{
                    struct UriEntiry: Codable{
                        var uri: String
                    }
                    var imageLandscape: UriEntiry
                }
                var photo: PhotoEntity
            }
            struct EventPlace: Codable{
                struct City: Codable{
                    var id: String
                    var contextualName: String
                }
                struct Location: Codable{
                    var latitude: Double
                    var longitude: Double
                }
                struct Address: Codable{
                    var singleLineFullAddress: String
                }
                var name: String
                var id: String?
                var city: City?
                var address: Address?
                var location: Location?
            }
            struct TextEntity: Codable{
                var text: String
            }
            struct EventFriendsEdges: Codable{
                struct EventFriendsEdge: Codable{
                    struct EventFriendsNode: Codable{
                        struct ProfilePicture: Codable{
                            var uri: String
                        }
                        var id: String
                        var name: String
                        var profilePicture: ProfilePicture
                    }
                    var node: EventFriendsNode
                }
                var count: Int
                var edges: [EventFriendsEdge]
            }
            struct TicketingChildEvents: Codable{
                struct Node: Codable{
                    var id: String
                    var currentStartTimestamp: Int
                    var currentEndTimestamp: Int
                }
                var nodes: [Node]
            }
            struct ParentEvent: Codable{
                var id: String
            }
            struct Count: Codable{
                var count: Int
            }
            var id: String
            var name: String
            var coverPhoto: CoverPhoto?
            var startTimestamp: Int
            var endTimestamp: Int
            var dayTimeSentenceMeetUp: String
            var eventPlace: EventPlace?
            var socialContext: TextEntity
            var eventHosts: EventHosts
            var eventKind: String
            var isOnline: Bool
            var eventStories: Count?
            var onlineEventSetup: OnlineEventSetup?
            var totalGoingGuests: CountNum
            var totalInterestedGuests: CountNum
            var goingFriends: CountNum
            var interestedFriends: CountNum
            var eventMaybesFriendFirst5: EventFriendsEdges
            var eventMembersFriendFirst5: EventFriendsEdges
            var viewerHasPendingInvite: Bool
            var isChildEvent: Bool
            var hasChildEvents: Bool
            var canViewerPurchaseOnsiteTickets: Bool
            var eventBuyTicketDisplayUrl: String?
            var isCanceled: Bool
            var eventDescription: EventDescription
            var eventCategoryData: EventCategoryData?
            var ticketingChildEvents: TicketingChildEvents?
            var parentEvent: ParentEvent?
        }
        var data: EventDataHolder?
        var error: GenericError.ErrorMessage?
        var errors: [GenericError.ErrorMessage]?
    }
}
