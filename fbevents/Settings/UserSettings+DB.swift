//
//  UserSettings+DB.swift
//  fbevents
//
//  Created by User on 06.08.2020.
//  Copyright © 2020 nonced. All rights reserved.
//

import SwiftUI
import GRDB


extension UserSettings {
    fileprivate func checkBundleSubdir() {
        let bundleCacheDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0].appendingPathComponent(Bundle.main.bundleIdentifier!)
        var isDir : ObjCBool = false
        if !FileManager.default.fileExists(atPath: bundleCacheDir.relativePath, isDirectory: &isDir){
            try? FileManager.default.createDirectory(at: bundleCacheDir, withIntermediateDirectories: true)
        }
    }
    
    mutating func migrateDB() {
        let logger = Logger()
        let dbs = ["favorites.db", "eventCache.db"]
        for dbName in dbs{ // Note that migration will be applied to both databases.
            if dbName.contains("Cache"){
                checkBundleSubdir()
            }
            let migrationName = "event_b" + UserSettings.appBuildNumber
            var eventMigrator = DatabaseMigrator()
            do{
                var dbPool: DatabasePool? = dbName.contains("Cache") ? try DatabasePool(path: eventCacheDbUrl.absoluteString)
                    : try DatabasePool(path: favoritesDbUrl.absoluteString)
                try dbPool!.write{db in
                    // To make changes in DB structure without increasing build number place them here.
                }
                if try dbPool!.read({db -> Bool in
                    if try db.tableExists("grdb_migrations"){
                        return try eventMigrator.appliedIdentifiers(db).contains(migrationName) // Was migration applied before?
                    }
                    else{
                        return false // DB doesn't exist.
                    }
                }){
                    continue // Migration already applied.
                }
                else{
                    var loadedEvents = [Event]()
                    try dbPool!.write{db in
                        if try db.tableExists("event"){
                            loadedEvents.append(contentsOf: try Event.fetchAll(db))
                            try db.drop(table: "event")
                            // possibly load and drop other tables here
                        }
                    }
                    eventMigrator.registerMigration(migrationName) { db in
                        if try db.tableExists("event"){
                            loadedEvents.append(contentsOf: try Event.fetchAll(db))
                            try db.drop(table: "event")
                            // possibly load and drop other tables here
                        }
                        if !(try db.tableExists("user")){
                            try db.create(table: "user") { t in
                                t.column("id", .integer).primaryKey().unique().notNull()
                                t.column("name", .text).notNull()
                                t.column("picture", .text).notNull()
                                t.column("isFriend", .boolean).notNull()
                                t.column("birthDay", .integer)
                                t.column("birthMonth", .integer)
                                t.column("birthdate", .text)
                            }
                        }
                        if !(try db.tableExists("page")){
                            try db.create(table: "page") { t in
                                t.column("id", .integer).primaryKey().unique().notNull()
                                t.column("name", .text).notNull()
                                t.column("picture", .text).notNull()
                                t.column("address", .text)
                            }
                        }
                        if !(try db.tableExists("post")){
                            /* This is a table only for Event posts.
                             In case we need to store posts of other types in future, reference mechanism should be redesigned.
                             (Do not forget about cascade deletion, we don't need to store garbage.)*/
                            try db.create(table: "post") { t in
                                t.column("id", .integer).primaryKey().unique().notNull()
                                t.column("parentId", .integer).notNull().references("event", column: "id", onDelete: .cascade, deferred: false)
                                t.column("parentType", .text).notNull()
                                t.column("text", .text).notNull()
                                t.column("time", .integer).notNull()
                                t.column("actors", .blob).notNull()
                                t.column("pinned", .boolean).notNull()
                                t.column("lastUpdate", .datetime).notNull()
                            }
                        }
                       if !(try db.tableExists("comment")){
                            try db.create(table: "comment") { t in
                                t.column("id", .integer).primaryKey().unique().notNull()
                                t.column("parentId", .integer).notNull().references("post", column: "id", onDelete: .cascade, deferred: false)
                                t.column("parentType", .text).notNull()
                                t.column("actor", .blob).notNull()
                                t.column("text", .text).notNull()
                                t.column("comments", .blob)
                                t.column("time", .integer).notNull()
                                t.column("lastUpdate", .datetime).notNull()
                            }
                        }
                        try db.create(table: "event") { t in
                            t.column("id", .integer).primaryKey().unique().notNull()
                            t.column("name", .text).notNull()
                            t.column("coverPhoto", .text).notNull()
                            t.column("startTimestamp", .integer).notNull()
                            t.column("endTimestamp", .integer).notNull()
                            t.column("dayTimeSentence", .text).notNull()
                            t.column("eventPlaceName", .text).notNull()
                            t.column("eventPlaceAddress", .text).notNull()
                            t.column("previewSocialContext", .text).notNull()
                            t.column("eventDescription", .text).notNull()
                            t.column("latitude", .double).notNull()
                            t.column("longitude", .double).notNull()
                            t.column("viewerHasPendingInvite", .boolean)
                            t.column("isChildEvent", .boolean).notNull()
                            t.column("hasChildEvents", .boolean).notNull()
                            t.column("canViewerPurchaseOnsiteTickets", .boolean).notNull()
                            t.column("eventBuyTicketDisplayUrl", .text)
                            
                            t.column("multiDay", .boolean).notNull()
                            t.column("startDate", .datetime).notNull()
                            t.column("endDate", .datetime)
                            t.column("timeOfTheDay", .text).notNull()
                            t.column("weekDay", .integer).notNull()
                            
                            t.column("hosts", .blob)
                            t.column("eventKind", .text)
                            t.column("isOnline", .boolean)
                            t.column("hasStories", .boolean)
                            t.column("onlineUrl", .text)
                            t.column("goingGuests", .integer)
                            t.column("interestedGuests", .integer)
                            t.column("goingFriends", .integer)
                            t.column("interestedFriends", .integer)
                            t.column("maybeFriends", .blob).notNull()
                            t.column("memberFriends", .blob).notNull()
                            t.column("isCanceled", .boolean)
                            t.column("categoryName", .text)
                            t.column("categoryId", .integer)
                            t.column("parentEventId", .integer)
                            t.column("childEvents", .blob)
                            
                            t.column("lastUpdate", .datetime)
                        }
                    }
                    try eventMigrator.migrate(dbPool!)
                    loadedEvents.forEach{
                        _ = $0.save(dbPool: dbPool!)
                    }
                }
                dbPool = nil
            }
            catch{
                logger.log(error)
            }
        }
    }
}
