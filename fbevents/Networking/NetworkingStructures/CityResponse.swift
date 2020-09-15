//
//  CityResponse.swift
//  fbevents
//
//  Created by User on 08.08.2020.
//  Copyright © 2020 nonced. All rights reserved.
//

import Foundation


extension Networking{
    struct CityResponse: Codable, ResponseData{
        struct Result: Codable {
            struct CityLocation: Codable {
                var city: String?
                var country: String?
                var latitude: Double
                var longitude: Double
            }
            var category: String
            var location: CityLocation
            var name: String
            var id: String
        }
        var data: [Result]?
        var error: Networking.GenericError.ErrorMessage?
        var errors: [Networking.GenericError.ErrorMessage]?
    }
}
