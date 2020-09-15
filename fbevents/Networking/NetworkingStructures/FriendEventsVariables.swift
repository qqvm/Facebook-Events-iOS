//
//  FriendEventsVariables.swift
//  fbevents
//
//  Created by User on 08.08.2020.
//  Copyright © 2020 nonced. All rights reserved.
//

import Foundation


extension Networking {
    struct FriendEventsVariables: Codable{
        var id: String /* Base64 encoded text:
        app_collection:100000202486987:2344061033:60*/
        var cursor: String?
        var search: String?
        var count: Int = 8
        var scale: Int = 2
        
    }
}
