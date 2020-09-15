//
//  EventWorker+Codable.swift
//  fbevents
//
//  Created by User on 04.07.2020.
//  Copyright © 2020 nonced. All rights reserved.
//

import Foundation


extension Networking{
    struct MeResponse: Codable, ResponseData{
        var id: String?
        var error: GenericError.ErrorMessage?
        var errors: [GenericError.ErrorMessage]?
    }
}
