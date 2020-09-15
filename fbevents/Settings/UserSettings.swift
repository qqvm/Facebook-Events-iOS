//
//  SettingsModel.swift
//  fbevents
//
//  Created by User on 21.06.2020.
//  Copyright © 2020 nonced. All rights reserved.
//

import SwiftUI
import GRDB


struct UserSettings: Codable{
    var timezone: String
    var locale: String
    
    var startView: SelectedView
    
    var cityName: String
    var cityId: Int
    var cityLat: Double
    var cityLon: Double
    
    var downloadImages: Bool
    var useCoordinates: Bool
    var deleteExpired: Bool
    var deleteCacheOnExit: Bool
    var usePagesSearchInsteadOfPlaces: Bool
    var enableBanning: Bool
    
    var bannedWords = [String]()
    
    var filterOptions = FilterOptions() {
        didSet{
            if filterOptions != oldValue{
                filterChanged = true
            }
        }
    }
    var filterChanged = false
    
    internal var token: String
    internal var userId: Int
    var deviceId: String
    var advId: String
    static let appId = 350685531728 // Maybe needed in some requests to Facebook APIs in the future.
    
    var reloadIntervalHours: Int = 1
    var birthdayNotificationIntervalDays: Int = 1
    var birthdayNotificationHour: String = "10"
    var birthdayNotificationMinute: String = "00"
    var notificationIntervalHours: Int = 1{
        didSet{
            UserSettings.notificationInterval = Double((notificationIntervalHours * 3600) + (notificationIntervalMinutes * 60))
        }
    }
    var notificationIntervalMinutes: Int = 0{
        didSet{
            UserSettings.notificationInterval = Double((notificationIntervalHours * 3600) + (notificationIntervalMinutes * 60))
        }
    }
    
    let eventCacheDbUrl = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0].appendingPathComponent(Bundle.main.bundleIdentifier!).appendingPathComponent("eventCache.db")
    let favoritesDbUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("favorites.db")
    
    static let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
    static let appBuildNumber = Bundle.main.infoDictionary!["CFBundleVersion"] as! String
    static let buttonSize: CGFloat = UIScreen.main.bounds.width >= UIScreen.main.bounds.height ? UIScreen.main.bounds.height / 16 : UIScreen.main.bounds.width / 16 // ~24
    static var notificationInterval: Double = 3600
    static var eventCacheOverheadNumber: Int = 100
    
    init(){
        self.timezone = TimeZone.current.identifier
        self.locale = Locale.preferredLanguages[0]
        self.startView = SelectedView(rawValue: UserDefaults.standard.string(forKey: "startView") ?? "") ?? SelectedView.favorites
        self.cityName = UserDefaults.standard.string(forKey: "cityName") ?? "Unknown"
        self.cityId = UserDefaults.standard.integer(forKey: "cityId")
        self.cityLat = UserDefaults.standard.double(forKey: "cityLat")
        self.cityLon = UserDefaults.standard.double(forKey: "cityLon")
        self.downloadImages = UserDefaults.standard.bool(forKey: "downloadImages")
        self.useCoordinates = UserDefaults.standard.bool(forKey: "useCoordinates")
        self.deleteExpired = UserDefaults.standard.bool(forKey: "deleteExpired")
        self.deleteCacheOnExit = UserDefaults.standard.bool(forKey: "deleteCacheOnExit")
        self.usePagesSearchInsteadOfPlaces = UserDefaults.standard.bool(forKey: "usePagesSearchInsteadOfPlaces")
        self.enableBanning = UserDefaults.standard.bool(forKey: "enableBanning")
        self.token = KeychainWrapper.GetPassword(key: "authToken")?.password ?? ""
        self.userId = UserDefaults.standard.integer(forKey: "userId")
        self.deviceId = UserDefaults.standard.string(forKey: "deviceId") ?? UUID().uuidString
        self.advId = UserDefaults.standard.string(forKey: "advId") ?? UUID().uuidString
        self.reloadIntervalHours = UserDefaults.standard.integer(forKey: "reloadIntervalHours")
        self.birthdayNotificationIntervalDays = UserDefaults.standard.integer(forKey: "birthdayNotificationIntervalDays")
        self.birthdayNotificationHour = UserDefaults.standard.string(forKey: "birthdayNotificationHour") ?? "10"
        self.birthdayNotificationMinute = UserDefaults.standard.string(forKey: "birthdayNotificationMinute") ?? "00"
        self.notificationIntervalHours = UserDefaults.standard.integer(forKey: "notificationIntervalHours")
        self.notificationIntervalMinutes = UserDefaults.standard.integer(forKey: "notificationIntervalMinutes")
        let filters = UserDefaults.standard.stringArray(forKey: "customFilters")
        let cats = UserDefaults.standard.stringArray(forKey: "categories")
        let words = UserDefaults.standard.stringArray(forKey: "bannedWords")
        self.filterOptions.sortOrder = UserDefaults.standard.string(forKey: "sortOrder") ?? "Start Time"
        self.filterOptions.timeFrame = UserDefaults.standard.string(forKey: "timeFrame") ?? "All"
        self.filterOptions.timeOfTheDay = UserDefaults.standard.string(forKey: "timeOfTheDay") ?? "Anytime"
        self.filterOptions.customFilters.append(contentsOf: filters ?? [])
        self.filterOptions.categories.append(contentsOf: cats ?? [])
        self.filterChanged = false
        self.bannedWords.append(contentsOf: words ?? [])
        if UserSettings.isFirstLaunch(){
            restoreSettings()
        }
        if cityId == 0 && cityLat != Double(0) && !useCoordinates{
            useCoordinates = true
            cityName = "GPS Location"
        }
        migrateDB()
    }
    
    func saveAll(){
        UserDefaults.standard.set(startView.rawValue, forKey: "startView")
        UserDefaults.standard.set(cityName, forKey: "cityName")
        UserDefaults.standard.set(cityId, forKey: "cityId")
        UserDefaults.standard.set(cityLat, forKey: "cityLat")
        UserDefaults.standard.set(cityLon, forKey: "cityLon")
        UserDefaults.standard.set(downloadImages, forKey: "downloadImages")
        UserDefaults.standard.set(useCoordinates, forKey: "useCoordinates")
        UserDefaults.standard.set(deleteExpired, forKey: "deleteExpired")
        UserDefaults.standard.set(deleteCacheOnExit, forKey: "deleteCacheOnExit")
        UserDefaults.standard.set(usePagesSearchInsteadOfPlaces, forKey: "usePagesSearchInsteadOfPlaces")
        UserDefaults.standard.set(enableBanning, forKey: "enableBanning")
        UserDefaults.standard.set(bannedWords, forKey: "bannedWords")
        UserDefaults.standard.set(filterOptions.sortOrder, forKey: "sortOrder")
        UserDefaults.standard.set(filterOptions.timeFrame, forKey: "timeFrame")
        UserDefaults.standard.set(filterOptions.timeOfTheDay, forKey: "timeOfTheDay")
        UserDefaults.standard.set(userId, forKey: "userId")
        UserDefaults.standard.set(deviceId, forKey: "deviceId")
        UserDefaults.standard.set(advId, forKey: "advId")
        UserDefaults.standard.set(reloadIntervalHours, forKey: "reloadIntervalHours")
        UserDefaults.standard.set(birthdayNotificationIntervalDays, forKey: "birthdayNotificationIntervalDays")
        UserDefaults.standard.set(birthdayNotificationHour, forKey: "birthdayNotificationHour")
        UserDefaults.standard.set(birthdayNotificationMinute, forKey: "birthdayNotificationMinute")
        UserDefaults.standard.set(notificationIntervalHours, forKey: "notificationIntervalHours")
        UserDefaults.standard.set(notificationIntervalMinutes, forKey: "notificationIntervalMinutes")
        UserDefaults.standard.set(filterOptions.customFilters, forKey: "customFilters")
        UserDefaults.standard.set(filterOptions.categories, forKey: "categories")
        UserDefaults.standard.synchronize()
    }
    
    mutating func deleteToken(){
        self.token = ""
        self.userId = 0
        _ = KeychainWrapper.DeletePassword(key: "authToken")
    }
    
    mutating func restoreSettings(){
        self.timezone = TimeZone.current.identifier
        self.locale = Locale.preferredLanguages[0]
        self.cityName = "Unknown"
        self.cityId = 0
        self.cityLat = 0
        self.cityLon = 0
        self.downloadImages = true
        self.useCoordinates = false
        self.deleteExpired = false
        self.deleteCacheOnExit = false
        self.enableBanning = false
        self.filterOptions.sortOrder = "Start Time"
        self.filterOptions.timeFrame = "All"
        self.filterOptions.timeOfTheDay = "Anytime"
        self.reloadIntervalHours = 1
        self.birthdayNotificationIntervalDays = 1
        self.birthdayNotificationHour = "10"
        self.birthdayNotificationMinute = "00"
        self.notificationIntervalHours = 1
        self.notificationIntervalMinutes = 0
        UserSettings.notificationInterval = 3600
        self.filterOptions.customFilters.removeAll()
        self.filterOptions.categories.removeAll()
        self.bannedWords.removeAll()
        self.saveAll()
    }
    
    static func isFirstLaunch() -> Bool {
        let isFirstLaunch = !UserDefaults.standard.bool(forKey: "hasBeenLaunchedBefore")
        if (isFirstLaunch) {
            UserDefaults.standard.set(true, forKey: "hasBeenLaunchedBefore")
            UserDefaults.standard.set(true, forKey: "downloadImages")
            UserDefaults.standard.set(true, forKey: "usePagesSearchInsteadOfPlaces")
            UserDefaults.standard.set(1, forKey: "reloadIntervalHours")
            UserDefaults.standard.synchronize()
        }
        return isFirstLaunch
    }
}
