//
//  FriendListPageVariables.swift
//  fbevents
//
//  Created by User on 08.08.2020.
//  Copyright © 2020 nonced. All rights reserved.
//

import Foundation


extension Networking {
    struct CalendarVariables: Codable{
        var count: Int = 8
        var cursor: String?
        var scale: Int = 2
        //var search: String?
        var id: String? // For past events
    }
}
