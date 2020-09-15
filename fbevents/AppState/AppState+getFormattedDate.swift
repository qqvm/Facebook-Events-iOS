//
//  AppState+getFormattedDate.swift
//  fbevents
//
//  Created by User on 11.09.2020.
//  Copyright © 2020 nonced. All rights reserved.
//

import Foundation


extension AppState{
    static func getFormattedDate(_ interval: Int, isLong: Bool = true, withWeekday: Bool = true, withYear: Bool = false) -> String {
        var format = isLong ? (withYear ? "EEEE, MMMM d yyyy, HH:mm" : "EEEE, MMMM d, HH:mm") : "HH:mm"
        if !withWeekday {
            format = format.replacingOccurrences(of: "EEEE, ", with: "")
        }
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.locale = Locale.current
        formatter.dateFormat = format
        return formatter.string(from: Date(timeIntervalSince1970: Double(interval)))
    }
}
