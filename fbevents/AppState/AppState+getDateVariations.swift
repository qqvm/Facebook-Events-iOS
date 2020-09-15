//
//  AppState+DateManipulation.swift
//  fbevents
//
//  Created by User on 12.09.2020.
//  Copyright © 2020 nonced. All rights reserved.
//

import Foundation


extension AppState{
    static func getDate(from interval: Int) -> Date {
        return Date(timeIntervalSince1970: Double(interval))
    }
    
    static func getTimeOfTheDay(from interval: Int) -> String{
        let date = AppState.getDate(from: interval)
        let hour = Calendar.current.component(.hour, from: date)
        if Calendar.current.compare(date, to: Date(), toGranularity: .hour) == .orderedSame{
            return "Now"
        }
        else if hour >= 6 && hour < 19{
            return "Daytime"
        }
        else if hour >= 19 && hour < 22{
            return "Evening"
        }
        else {
            return "Late Night"
        }
    }
    
    static func getWeekDay(from interval: Int) -> Int{
        let date = AppState.getDate(from: interval)
        var weekday = Calendar.current.component(.weekday, from: date) - 1
        if weekday == 0 {weekday = 7}
        return weekday
    }
}
