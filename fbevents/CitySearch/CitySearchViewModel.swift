//
//  SettingsViewModel+CitySearch.swift
//  fbevents
//
//  Created by User on 10.07.2020.
//  Copyright © 2020 nonced. All rights reserved.
//

import Foundation


extension CitySearchBasicView{
    func tryCitySearch(completion: @escaping ([Networking.CityResponse.Result])->()){
        if let url = URL(string: "https://graph.facebook.com/search?type=place&q=\(self.searchCityName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!))&access_token=350685531728%7c62f8ce9f74b12f84c123cc23437a4a32"){
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
            appState.networkManager?.getURL(urlComponents: components, withToken: true){(response: Networking.CityResponse) in
                if let data = response.data{
                    var result = [Networking.CityResponse.Result]()
                    let cityResult = data.filter({$0.category == "City"})
                    let regionResult = data.filter({$0.category == "Region"})
                    if cityResult.count > 0 {
                        result.append(contentsOf: cityResult)
                    }
                    else if regionResult.count > 0 {
                        result.append(contentsOf: regionResult)
                    }
                    completion(result)
                }
            }
        }
    }
}
