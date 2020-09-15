//
//  FriendEventsVariables.swift
//  fbevents
//
//  Created by User on 08.08.2020.
//  Copyright © 2020 nonced. All rights reserved.
//

import Foundation


extension Networking {
    struct PageEventsVariables: Codable{
        var pageID: String
        var cursor: String?
        var search: String?
        var count: Int = 10
        
    }
}
