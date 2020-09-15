//
//  EventType.swift
//  fbevents
//
//  Created by User on 20.06.2020.
//  Copyright © 2020 nonced. All rights reserved.
//

import SwiftUI
import SwiftDate
import GRDB


struct SimpleChildEvent: Codable, Equatable, Hashable{
    var id: Int
    var startTimestamp: Int
    var endTimestamp: Int
    
    static func ==(lhs: SimpleChildEvent, rhs: SimpleChildEvent) -> Bool {
        return lhs.id == rhs.id
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine("_child")
    }
}

protocol BasicEventData{
    var id: Int{get set}
    var name: String{get set}
    var coverPhoto: String{get set}
    var dayTimeSentence: String{get set}
}

struct SimpleEvent: BasicEventData, Equatable, Hashable{
    var id: Int
    var name: String
    var coverPhoto: String
    var dayTimeSentence: String
    
    static func ==(lhs: SimpleEvent, rhs: SimpleEvent) -> Bool {
        return lhs.id == rhs.id
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine("_simple")
    }
}

struct Event: Codable, Equatable, Hashable, PersistableData, BasicEventData {
    var id: Int
    var name: String
    var coverPhoto: String
    var startTimestamp: Int
    var endTimestamp: Int
    var dayTimeSentence: String
    var eventPlaceName: String
    var eventPlaceAddress: String
    var previewSocialContext: String
    var eventDescription: String
    var latitude: Double
    var longitude: Double
    var viewerHasPendingInvite: Bool
    var isChildEvent: Bool
    var hasChildEvents: Bool
    var canViewerPurchaseOnsiteTickets: Bool
    var eventBuyTicketDisplayUrl: String?
    
    var multiDay: Bool
    var startDate: Date
    var endDate: Date?
    var timeOfTheDay: String
    var weekDay: Int
    
    var hosts = [Actor]()
    var eventKind: String?
    var isOnline: Bool?
    var hasStories: Bool?
    var onlineUrl: String?
    var goingGuests: Int?
    var interestedGuests: Int?
    var goingFriends: Int?
    var interestedFriends: Int?
    var maybeFriends = [User]()
    var memberFriends = [User]()
    var isCanceled: Bool?
    var categoryName: String?
    var categoryId: Int?
    var parentEventId: Int?
    var childEvents: [SimpleChildEvent]?
    
    var lastUpdate: Date?
    
    static let posts = hasMany(Post.self)
    var posts: QueryInterfaceRequest<Post> {
        request(for: Event.posts)
    }
}
