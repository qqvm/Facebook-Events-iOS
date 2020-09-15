//
//  NotificationHelper.swift
//  fbevents
//
//  Created by User on 08.07.2020.
//  Copyright © 2020 nonced. All rights reserved.
//

import Foundation
import UserNotifications


func SetNotification(id: String, title: String, subtitle: String, date: Date){
    let center = UNUserNotificationCenter.current()
    let content = UNMutableNotificationContent()
    content.title = title
    content.subtitle = subtitle
    content.sound = UNNotificationSound.default
    let dateComponents = Calendar.current.dateComponents([.year,.day,.month,.hour,.minute,.second],
                                                         from: date)
//    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 4, repeats: false) // NOTE: FOR DEBUG
    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
    let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
    center.getNotificationSettings { settings in
        if settings.authorizationStatus == .authorized {
            center.add(request)
        } else {
            center.requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                if success {
                    center.add(request)
                }
            }
        }
    }
}

func DeleteNotification(id: String){
    let center = UNUserNotificationCenter.current()
    center.getPendingNotificationRequests { (notificationRequests) in
        var identifiers: [String] = []
        for notification:UNNotificationRequest in notificationRequests {
            if notification.identifier == id {
                identifiers.append(notification.identifier)
            }
        }
        if identifiers.count > 0{
            center.removePendingNotificationRequests(withIdentifiers: identifiers)
        }
    }
}

func ProcessNotificationIdentifiers(with completionHandler: @escaping ([String])->()){
    let center = UNUserNotificationCenter.current()
    center.getPendingNotificationRequests { (notificationRequests) in
        completionHandler(notificationRequests.map{$0.identifier})
    }
}
