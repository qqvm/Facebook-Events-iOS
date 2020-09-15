//
//  EventWorker+Codable.swift
//  fbevents
//
//  Created by User on 04.07.2020.
//  Copyright © 2020 nonced. All rights reserved.
//

import Foundation


struct Networking{
    struct GenericError: Codable{
        var error: ErrorMessage?
        struct ErrorMessage: Codable{
            var message: String
        }
    }
}
