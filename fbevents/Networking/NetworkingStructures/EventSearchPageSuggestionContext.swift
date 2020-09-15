//
//  SuggestionContext.swift
//  fbevents
//
//  Created by User on 07.08.2020.
//  Copyright © 2020 nonced. All rights reserved.
//

import Foundation


extension Networking {
    struct EventSearchPageSuggestionContext: Codable{
        struct SuggestionData: Codable{
            struct LatLon: Codable{
                var latitude: Double
                var longitude: Double
            }
            var city: String?
            var latLon: LatLon?
            var timezone: String
            var time: String?
            var timeOfTheDay: String?
            var sort: String?
            var eventFlags: [String]?
            var eventCustomFilters: [String]?
            var eventCategories: [Int]?
        }
        var suggestionContext: SuggestionData
        var eventsConnectionFirst: Int
        var eventsConnectionAtStreamUseCustomizedBatch: Bool
        var eventsConnectionAfterCursor: String?
    }
}
