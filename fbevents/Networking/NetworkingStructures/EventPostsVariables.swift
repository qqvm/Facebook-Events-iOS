//
//  EventPostsVariables.swift
//  fbevents
//
//  Created by User on 07.08.2020.
//  Copyright © 2020 nonced. All rights reserved.
//

import Foundation


extension Networking {
    struct EventPostsVariables: Codable{
        var eventID: String
        var orderBy: String?
        var pinnedOrderBy: String?
        var pixelRatio = 2.5
    }
}
