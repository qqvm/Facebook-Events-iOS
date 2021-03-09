//
//  BirthdayFriendsVariables.swift
//  fbevents
//
//  Created by User on 08.08.2020.
//  Copyright © 2020 nonced. All rights reserved.
//

import Foundation


extension Networking {
    struct BirthdayFriendsVariables: Codable{
        var scale: Int?
        var offsetMonth: Int = 0
        var count: Int?
        var cursor: String?
    }
}
