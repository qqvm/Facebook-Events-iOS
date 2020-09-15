//
//  PersistableData.swift
//  fbevents
//
//  Created by User on 12.09.2020.
//  Copyright © 2020 nonced. All rights reserved.
//

import Foundation
import GRDB


protocol PersistableData: FetchableRecord, PersistableRecord{
    var id: Int{get set}
}

extension PersistableData{
    static func exists(id: Int, dbPool: DatabasePool) -> Bool {
        var result = false
        do{
            try dbPool.read{db in
                if try Self.fetchOne(db, key: ["id":String(id)]) != nil{
                    result = true
                }
            }
        }
        catch{
            let logger = Logger()
            logger.log(error)
        }
        return result
    }
    
    static func get(id: Int, dbPool: DatabasePool) -> Self?{
        var data: Self? = nil
        do{
            try dbPool.read{db in
                data = try Self.fetchOne(db, key: ["id":String(id)])
            }
        }
        catch{
            let logger = Logger()
            logger.log(error)
        }
        return data
    }
    
    func exists(dbPool: DatabasePool) -> Bool{
        var result = false
        do{
            try dbPool.read{db in
                if try self.exists(db){
                    result = true
                }
            }
        }
        catch{
            let logger = Logger()
            logger.log(error)
        }
        return result
    }
    
    func fetchAll(dbPool: DatabasePool) -> [Self]{
        var data = [Self]()
        do{
            try dbPool.read{db in
                data.append(contentsOf: try Self.fetchAll(db))
            }
        }
        catch{
            let logger = Logger()
            logger.log(error)
        }
        return data
    }
    
    func save(dbPool: DatabasePool) -> Bool{
        var result = false
        do{
            try dbPool.write{db in
                if try !self.exists(db){
                    try self.insert(db)
                    result = true
                }
            }
        }
        catch{
            let logger = Logger()
            logger.log(error)
        }
        return result
    }
    
    func updateInDB(dbPool: DatabasePool) -> Bool{
        var result = false
        do{
            if self.exists(dbPool: dbPool){
                try dbPool.write{db in
                    try self.update(db)
                    result = true
                }
            }
        }
        catch{
            let logger = Logger()
            logger.log(error)
        }
        return result
    }
    
    mutating func updateFromDB(dbPool: DatabasePool) -> Bool{
        var result = false
        if let data = Self.get(id: self.id, dbPool: dbPool){
            self = data
            result = true
        }
        return result
    }
    
    func delete(dbPool: DatabasePool) -> Bool{
        var result = false
        do{
            try dbPool.write{db in
                if try self.exists(db){
                    result = try self.delete(db)
                }
            }
        }
        catch{
            let logger = Logger()
            logger.log(error)
        }
        return result
    }
}

extension QueryInterfaceRequest where RowDecoder: PersistableData {
    func fetchAll(dbPool: DatabasePool) -> [RowDecoder]{
        var data = [RowDecoder]()
        do{
            try dbPool.read{db in
                data.append(contentsOf: try self.fetchAll(db))
            }
        }
        catch{
            let logger = Logger()
            logger.log(error)
        }
        return data
    }
}
