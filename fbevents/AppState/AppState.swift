//
//  AppState.swift
//  FBEvents
//
//  Created by User on 15.07.2020.
//

import SwiftUI
import GRDB
import Network
import SDWebImageSwiftUI
import os.log


enum SelectedView: String, CaseIterable, Codable{
    case events = "Events"
    case favorites = "Favorites"
    case friends = "Friends"
    case birthdays = "Birthdays"
    case pages = "Pages"
    case settings = "Settings"
    case about = "Info"
}

struct Logger{
    private let log: OSLog
    
    init(category: String? = nil){
        if let category = category{
            self.log = OSLog.init(subsystem: Bundle.main.bundleIdentifier!, category: category)
        }
        else{
            self.log = OSLog.init(subsystem: Bundle.main.bundleIdentifier!, category: "main")
        }
    }
    
    func log(_ data: Any, isPublic: Bool = true, type: OSLogType = .default){
        os_log(isPublic ? "%{public}s" : "%{private}s", log: log, type: type, String(describing: data))
    }
    
    func log(isPublic: Bool = true, type: OSLogType = .default, _ data: Any...){
        os_log(isPublic ? "%{public}s" : "%{private}s", log: log, type: type, String(describing: data))
    }
}

struct BackupData: Codable{
    var version: String
    var settings: UserSettings
    var favoriteEvents: [Event]
    var favoriteFriends: [User]
    var favoritePages: [Page]
}

struct NetworkPager{
    var lastCursor = ""{
        didSet{
            loadedCursors.append(lastCursor)
        }
    }
    var endCursor = ""{
        didSet{
            lastCursor = oldValue
        }
    }
    var startCursor = ""
    var hasNext = true
    var hasPrevious = false
    var loadedCursors = [String]()
    
    var canProceed: Bool{
        !loadedCursors.contains(endCursor) && hasNext
    }
    
    mutating func reset(){
        lastCursor = ""
        endCursor = ""
        startCursor = ""
        hasNext = true
        hasPrevious = false
        loadedCursors.removeAll()
    }
}

final class AppState: ObservableObject{
    @Published var settings = UserSettings()
    @Published var networkManager: Networking.Manager?
    @Published var logger = Logger()
    @Published var dbPool: DatabasePool?
    @Published var cacheDbPool: DatabasePool?
    
    @Published var selectedView = SelectedView.favorites{
        didSet{
            previousView = oldValue
        }
    }
    @Published var previousView = SelectedView.favorites
    @Published var showExport = false
    @Published var showImport = false
    @Published var showMenu = false
    @Published var showError = false{
        didSet{
            if oldValue == true && showError == false{ // Reset description.
                self.errorDescription = "Something went wrong."
            }
        }
    }
    @Published var loadComplete = true
    @Published var errorDescription = "Something went wrong."
    
    @Published var searchEvents = [BasicEventData]()
    @Published var showSearchFilter = false
    @Published var showFavoriteFilter = false
    @Published var favoritesSelectedTab = 0
    @Published var favoriteFilterOptions = FilterOptions() // Not in settings, so persists only between views.
    
    @Published var searchPager = NetworkPager() // Declared here to avoid unneeded network refreshes when reentering Events View.
    
    private let networkMonitor = NWPathMonitor()
    @Published var isInternetAvailable = true
    @Published var isInternetExpensive = false
    
    let exportURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("FBEventsBackup.json")
    
    init(){
        networkManager = Networking.Manager(appState: self)
        
        selectedView = settings.startView
        previousView = settings.startView
        
        SDImageCache.shared.config.maxDiskSize = 1024 * 1024 * 100 // 100 MB
        URLCache.shared.diskCapacity = 1024 * 1024 * 100
        
        networkMonitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                if path.status == .satisfied {
                    self.isInternetAvailable = true
                } else {
                    self.isInternetAvailable = false
                }
                self.isInternetExpensive = path.isExpensive
            }
        }
        let queue = DispatchQueue(label: "NetworkMonitor")
        networkMonitor.start(queue: queue)
        
        do {
            self.dbPool = try DatabasePool(path: settings.favoritesDbUrl.absoluteString)
            self.cacheDbPool = try DatabasePool(path: settings.eventCacheDbUrl.absoluteString)
            self.logger.log(settings.favoritesDbUrl, settings.eventCacheDbUrl)
            if settings.deleteCacheOnExit{
                deleteCache()
            }
        }
        catch{
            self.logger.log(error)
        }
        
        deleteEventCacheOverhead()
    }
    
    deinit {
        logger.log("AppState has been destroyed.")
        self.dbPool = nil
        self.cacheDbPool = nil
    }    
    
    func resetState(completion: (()->())? = nil){
        do{
            try dbPool!.erase()
            try cacheDbPool!.erase()
            dbPool!.releaseMemory()
            cacheDbPool!.releaseMemory()
            DispatchQueue.main.async {
                self.showExport = false
                self.showImport = false
                self.showMenu = false
                self.showError = false
                self.loadComplete = true
                self.errorDescription = "Something went wrong."
                self.showSearchFilter = false
                self.showFavoriteFilter = false
                self.searchEvents.removeAll()
                self.favoriteFilterOptions.restore()
                self.searchPager.reset()
                self.logout()
                self.settings.restoreSettings()
            }
            self.settings.migrateDB()
            try dbPool!.vacuum()
            try cacheDbPool!.vacuum()
            URLCache.shared.removeAllCachedResponses()
            SDImageCache.shared.clearMemory()
            SDImageCache.shared.clearDisk(){
                if let completion = completion{
                    completion()
                }
            }
        }
        catch{
            self.logger.log(error)
        }
    }
    
    func deleteCache(completion: (()->())? = nil){
        do{
            try cacheDbPool!.erase()
            cacheDbPool!.releaseMemory()
            self.settings.migrateDB()
            try cacheDbPool!.vacuum()
            URLCache.shared.removeAllCachedResponses()
            SDImageCache.shared.clearMemory()
            SDImageCache.shared.clearDisk(){
                if let completion = completion{
                    completion()
                }
            }
        }
        catch{
            self.logger.log(error)
        }
    }
    
    func deleteEventCacheOverhead(){
        do{
            let events = try self.cacheDbPool!.read(Event.fetchAll)
            if events.count > UserSettings.eventCacheOverheadNumber{
                events.filter{$0.expired}.forEach{_ = $0.delete(dbPool: self.cacheDbPool!)}
            }
        }
        catch{
            self.logger.log(error)
        }
    }
    
    func backupSettings(){
        do{
            let events = try self.dbPool!.read(Event.fetchAll)
            let friends = try self.dbPool!.read(User.fetchAll)
            let pages = try self.dbPool!.read(Page.fetchAll)
            let encoder = JSONEncoder()
            var backupData = BackupData(version: "\(UserSettings.appVersion) (\(UserSettings.appBuildNumber))", settings: self.settings, favoriteEvents: events, favoriteFriends: friends, favoritePages: pages)
            backupData.settings.token = ""
            let jsonData = try encoder.encode(backupData)
            try jsonData.write(to: self.exportURL)
            DispatchQueue.main.async {
                self.showExport = true
            }
        }
        catch{
            self.logger.log(error)
        }
    }
    
    func restoreSettings(from url: URL){
        if !url.absoluteString.contains(".json"){return}
        do {
            let fileData = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let backupData = try decoder.decode(BackupData.self, from: fileData)
            DispatchQueue.main.async {
                let token = self.settings.token
                let uid = self.settings.userId
                let did = self.settings.deviceId
                let aid = self.settings.advId
                self.settings = backupData.settings
                self.settings.token = token
                self.settings.userId = uid
                self.settings.deviceId = did
                self.settings.advId = aid
            }
            for event in backupData.favoriteEvents{
                _ = event.save(dbPool: self.dbPool!)
            }
            for friend in backupData.favoriteFriends{
                _ = friend.save(dbPool: self.dbPool!)
            }
            for page in backupData.favoritePages{
                _ = page.save(dbPool: self.dbPool!)
            }
            UserDefaults.standard.set(true, forKey: "hasBeenLaunchedBefore")
            self.settings.saveAll()
        }
        catch{
            self.logger.log(error)
        }
    }
    
    func logout(){
        let components = URLComponents(url: URL(string: "https://b-api.facebook.com/method/auth.expireSession")!, resolvingAgainstBaseURL: false)!
        networkManager?.getURL(urlComponents: components, withToken: true, noCaching: true, dataPreprocessHadnler: {(data: Data) in
            return "{}".data(using: .utf8)!
        }){(response: Networking.LoginPageResponse) in
            DispatchQueue.main.async {
                self.settings.deleteToken()
            }
        }
    }
}
