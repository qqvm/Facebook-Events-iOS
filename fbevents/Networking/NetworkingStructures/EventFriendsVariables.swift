//
//  EventFriendsVariables.swift
//  fbevents
//
//  Created by User on 08.08.2020.
//  Copyright © 2020 nonced. All rights reserved.
//

import Foundation


extension Networking {
    struct EventFriendsVariables: Codable{
        // No snake_case for this request.
        var connectionTypes: [String] = ["INTERESED", "GOING"]
        var cursor: String?
        var count: Int = 20
        var eventID: Int
        var isViewerFriend = true
        var scale: Int = 2
        
    }
}
