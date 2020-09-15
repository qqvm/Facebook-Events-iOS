//
//  EventType+Logic.swift
//  fbevents
//
//  Created by User on 22.06.2020.
//  Copyright © 2020 nonced. All rights reserved.
//

import SwiftUI
import SwiftDate


extension Event{
    static func ==(lhs: Event, rhs: Event) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(isFullInfoAvailable ? "_full" : "_part")
    }
    
    var isFullInfoAvailable: Bool{
        return isOnline != nil && hosts.count > 0
    }
    
    var expired: Bool {
        if let endDate = endDate{
            return endDate < Date()
        }
        else{
            return startDate < Date()
        }
    }
    var isMultiYear: Bool{
        if endDate != nil{
            return startDate.year != endDate!.year
        }
        else {return false}
        
    }
    var popularity: Int{
        if let interested = interestedGuests {
            return interested
        }
        else if let num = previewSocialContext.split(separator: ("\u{00b7}")).last?.split(separator: " ").first{
            return Int(String(num)) ?? 0
        }
        else{
            return 0
        }
    }
    var areFriendsInterested: Bool{
        if interestedFriends != nil || goingFriends != nil {
            if interestedFriends! > 0 || goingFriends! > 0{
                return true
            }
        }
        return false
    }
    var timeFrames: [String]{
        var timeFrames = [String]()
        let now = Date()
        var weekdayNow = Calendar.current.component(.weekday, from: now) - 1
        if weekdayNow == 0 {weekdayNow = 7}
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: now)!.dateAt(.endOfDay)
        let thisWorkweekStart: Date? = weekdayNow < 6 ? now : nil
        let thisWorkweekEnd: Date? = weekdayNow < 5 ? now.nextWeekday(.friday).dateAt(.endOfDay) : weekdayNow == 5 ? now.dateAt(.endOfDay) : nil
        let thisWeekendStart: Date = weekdayNow > 5 ? now : now.nextWeekday(.saturday).dateAt(.startOfDay)
        let thisWeekendEnd: Date = weekdayNow < 7 ? now.nextWeekday(.sunday).dateAt(.endOfDay) : now.dateAt(.endOfDay)
        let nextWorkweekStart = now.nextWeekday(.monday).dateAt(.startOfDay)
        let nextWorkweekEnd = nextWorkweekStart.nextWeekday(.friday).dateAt(.endOfDay)
        let nextWeekendStart = nextWorkweekStart.nextWeekday(.saturday).dateAt(.startOfDay)
        let nextWeekendEnd = nextWorkweekStart.nextWeekday(.sunday).dateAt(.endOfDay)
        
        if multiDay{
            if now >= startDate && now <= endDate!  {
                timeFrames.append("Today")
            }
            if tomorrow >= startDate && tomorrow <= endDate!{
                timeFrames.append("Tomorrow")
            }
            if thisWorkweekStart != nil && thisWorkweekEnd != nil{
                if (thisWorkweekStart! >= startDate && thisWorkweekStart! <= endDate!) ||
                    (thisWorkweekEnd! >= startDate && thisWorkweekEnd! <= endDate!) ||
                    (startDate >= thisWorkweekStart! && endDate! <= thisWorkweekEnd!){
                    timeFrames.append("This Week")
                }
            }
            if (thisWeekendStart >= startDate && thisWeekendStart <= endDate!) ||
            (thisWeekendEnd >= startDate && thisWeekendEnd <= endDate!){
                timeFrames.append("This Weekend")
            }
            if (nextWorkweekStart >= startDate && nextWorkweekStart <= endDate!) ||
            (nextWorkweekEnd >= startDate && nextWorkweekEnd <= endDate!) ||
                (startDate >= nextWorkweekStart && endDate! <= nextWorkweekEnd){
                timeFrames.append("Next Week")
            }
            if (nextWeekendStart >= startDate && nextWeekendStart <= endDate!) ||
            (nextWeekendEnd >= startDate && nextWeekendEnd <= endDate!){
                timeFrames.append("Next Weekend")
            }
        }
        else {
            if Calendar.current.dateComponents([.day], from: now, to: startDate).day! == 0 && Calendar.current.component(.day, from: now) == Calendar.current.component(.day, from: startDate){
                timeFrames.append("Today")
            }
            if Calendar.current.dateComponents([.day], from: now, to: startDate).day! <= 1 && Calendar.current.component(.day, from: startDate) - Calendar.current.component(.day, from: now) == 1{
                timeFrames.append("Tomorrow")
            }
            if thisWorkweekStart != nil && thisWorkweekEnd != nil{
                if (startDate >= thisWorkweekStart! && startDate <= thisWorkweekEnd!) {
                    timeFrames.append("This Week")
                }
            }
            if (startDate >= thisWeekendStart && startDate <= thisWeekendEnd){
                timeFrames.append("This Weekend")
            }
            if (startDate >= nextWorkweekStart && startDate <= nextWorkweekEnd){
                timeFrames.append("Next Week")
            }
            if (startDate >= nextWeekendStart && startDate <= nextWeekendEnd){
                timeFrames.append("Next Weekend")
            }
        }
        if timeFrames.count == 0{
            timeFrames.append("All")
        }
        return timeFrames
    }
    
    func getProposedNotificationDate() -> Date{
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.locale = Locale.current
        formatter.dateFormat = startDate.isToday ? "HH:mm" : "E, MMMM d HH:mm"
        var notificationDate: Date? = nil
        if multiDay{
            let now = Date()
            if startDate < now{
                let difference = Calendar.current.dateComponents([.day], from: startDate, to: now).day!
                notificationDate = Date(timeIntervalSince1970: (startDate.timeIntervalSince1970 - UserSettings.notificationInterval)) + difference.days
            }
            else{
                notificationDate = Date(timeIntervalSince1970: (startDate.timeIntervalSince1970 - UserSettings.notificationInterval))
            }
        }
        else{
            notificationDate = Date(timeIntervalSince1970: (startDate.timeIntervalSince1970 - UserSettings.notificationInterval))
        }
        return notificationDate!
    }
    
    func getProposedNotificationSubtitle() -> String{
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.locale = Locale.current
        formatter.dateFormat = startDate.isToday ? "HH:mm" : "E, MMMM d HH:mm"
        let place = eventPlaceName == "Online Event" ? ", Online" : " at \(eventPlaceName)"
        return multiDay ? ("Till " + formatter.string(from: endDate!) + place) : (formatter.string(from: startDate) + place)
    }
    
    func setNotification(date: Date? = nil){
        if !expired{
            let formatter = DateFormatter()
            formatter.timeZone = TimeZone.current
            formatter.locale = Locale.current
            formatter.dateFormat = startDate.isToday ? "HH:mm" : "E, MMMM d HH:mm"
            let place = eventPlaceName == "Online Event" ? ", Online" : " at \(eventPlaceName)"
            let subtitle = multiDay ? ("Till " + formatter.string(from: endDate!) + place) : (formatter.string(from: startDate) + place)
            SetNotification(id: String("event_\(id)"), title: name, subtitle: subtitle, date: date == nil ? getProposedNotificationDate() : date!)
        }
    }
    
    func deleteNotification(){
        DeleteNotification(id: "event_\(id)")
    }
}
