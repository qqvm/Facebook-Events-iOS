//
//  EventDetailsRequestVars.swift
//  fbevents
//
//  Created by User on 07.08.2020.
//  Copyright © 2020 nonced. All rights reserved.
//

import Foundation


extension Networking {
    struct EventDetailsVariables: Codable{
        struct EventDetailsNtContext: Codable{
            var usingWhiteNavbar: Bool
            var stylesId: String
            var pixelRatio: Int
        }
        var profileImageSize: Int
        var eventId:String
        var scale: String
        var ntContext: EventDetailsNtContext
        var profilePicSizePx: Int
        var shouldFetchInlineSingleStepConfig: Bool
        var profileFacepileImageSize: Int
        var surface: String
    }
}
