//
//  AppState+isTokenValid.swift
//  fbevents
//
//  Created by User on 11.09.2020.
//  Copyright © 2020 nonced. All rights reserved.
//

import Foundation


extension AppState {
    func isTokenValid(completion: @escaping ((Bool,Bool)->())){
        let components = URLComponents(url: URL(string: "https://graph.facebook.com/me")!, resolvingAgainstBaseURL: false)!
        networkManager?.getURL(urlComponents: components, withToken: true, errorHandler: {_ in
            completion(false, true) // error
        }){(response: Networking.MeResponse) in
            if let id = response.id{
                if let numId = Int(id){
                    self.settings.userId = numId
                    completion(true, false) // success
                    DispatchQueue.main.async {
                        self.loadComplete = true
                    }
                    return
                }
            }
        }
    }
}
