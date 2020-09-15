//
//  AppState+getIdFromFbString.swift
//  fbevents
//
//  Created by User on 11.09.2020.
//  Copyright © 2020 nonced. All rights reserved.
//

import Foundation


extension AppState{
    func getIdFromFbString(_ str: String) -> Int{
        var id = 0
        if let num = Int(str){id = num}
        else if let decoded = String(data: Data(base64Encoded: str)!, encoding: .utf8){
            if decoded.contains("_"){
                if let num = Int(String(decoded.split(separator: "_").last!)){
                    id = num
                }
                else{
                    id = Int(String(decoded.split(separator: ":").last!))!
                }
            }
            else{
                id = Int(String(decoded.split(separator: ":").last!))!
            }
        }
        return id
    }
}
