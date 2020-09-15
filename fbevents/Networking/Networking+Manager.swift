//
//  EventWorker+HTTP.swift
//  fbevents
//
//  Created by User on 04.07.2020.
//  Copyright © 2020 nonced. All rights reserved.
//

import SwiftUI


protocol ResponseData{
    var error: Networking.GenericError.ErrorMessage?{get set}
    var errors: [Networking.GenericError.ErrorMessage]?{get set}
}

extension Networking{
    struct Manager{
        private var appState: AppState
        @State private var inProgress = [UUID:URLComponents]()
        
        init(appState: AppState){
            self.appState = appState
        }
        
        private func canProceed(components: URLComponents) -> (result: Bool, reason: String){
            var result = (true, "")
            if !appState.loadComplete && inProgress.values.contains(components) {result = (false, "Another request is in progress.")}
            else if inProgress.values.filter({$0 == components}).count > 3 {result = (false, "Too many requests.")}
            else {
                
            }
            if !result.0{
                if let queryName = components.queryItems?.first(where: {$0.name == "fb_api_req_friendly_name"})?.value{
                    appState.logger.log("Cannot proceed with \(queryName). Reason: \(result.1)")
                }
                else{
                    appState.logger.log("Cannot proceed with \(String(describing: components.url)). Reason: \(result.1)")
                }
            }
            return result
        }
        
        func getURL<T>(urlComponents: URLComponents, withToken: Bool, noCaching: Bool = false, logNetworkActivity: Bool = false, statusHadnler: ((Int)->(Bool))? = nil, dataPreprocessHadnler: ((Data)->(Data))? = nil, errorHandler: (([String])->())? = nil, responseHandler: @escaping (T)->()) where T : ResponseData, T : Decodable{
            guard urlComponents.url != nil &&
                appState.isInternetAvailable && ((withToken && appState.settings.token != "") || !withToken)
            else {
                return
            }
            let checkResult = canProceed(components: urlComponents)
            if !checkResult.result {
                return
            }
            else if logNetworkActivity && !noCaching{
                appState.logger.log(urlComponents)
            }
            DispatchQueue.main.async {
                self.appState.loadComplete = false
            }
            let requestId = UUID()
            inProgress[requestId] = urlComponents
            getHttp(urlComponents.url!, headers: withToken ? Dictionary(dictionaryLiteral: ("Authorization","OAuth \(appState.settings.token)")) : nil, noCaching: noCaching) {(response: HTTPURLResponse?, data: Data?)  in
                do {
                    guard response != nil && data != nil else {
                        DispatchQueue.main.async {
                            self.appState.loadComplete = true
                            self.appState.errorDescription = response == nil ? "No response" : "\(response.debugDescription)"
                            self.appState.showError = true
                        }
                        self.inProgress.removeValue(forKey: requestId)
                        return
                    }
                    self.inProgress.removeValue(forKey: requestId)
                    if let handler = statusHadnler{
                        if !handler(response!.statusCode){return}
                    }
                    if response?.statusCode == 401 && self.appState.settings.token != "" {self.appState.settings.deleteToken()}
                    if logNetworkActivity && !noCaching{
                        self.appState.logger.log(response?.statusCode as Any, String(data: data!, encoding: .utf8) as Any)
                    }
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    
                    let jsonResponse = try decoder.decode(T.self, from: dataPreprocessHadnler == nil ? data! : dataPreprocessHadnler!(data!))
                    if let errorMessage = jsonResponse.error?.message{
                        if let handler = errorHandler{
                            handler([String](arrayLiteral: errorMessage))
                        }
                        DispatchQueue.main.async {
                            self.appState.loadComplete = true
                            self.appState.errorDescription = errorMessage
                            self.appState.showError = true
                            self.appState.logger.log(errorMessage)
                        }
                    }
                    else if let errors = jsonResponse.errors{
                        let errorMessages = errors.map{$0.message}
                        if let handler = errorHandler{
                            handler(errorMessages)
                        }
                        let errorMessage = errors.map{$0.message}.joined(separator: "\n")
                        DispatchQueue.main.async {
                            self.appState.loadComplete = true
                            self.appState.errorDescription = errorMessage
                            self.appState.showError = true
                        }
                        self.appState.logger.log(errorMessage)
                    }
                    responseHandler(jsonResponse)
                    DispatchQueue.main.async {
                        self.appState.loadComplete = true
                    }
                }
                catch{
                    self.appState.logger.log(error)
                    if let handler = errorHandler{
                        handler([String](arrayLiteral: error.localizedDescription))
                    }
                    DispatchQueue.main.async {
                        self.appState.loadComplete = true
                        self.appState.errorDescription = error.localizedDescription
                        self.appState.showError = true
                    }
                }
            }
        }
        
        func postURL<T>(urlComponents: URLComponents, withToken: Bool, noCaching: Bool = false, logNetworkActivity: Bool = false, statusHadnler: ((Int)->(Bool))? = nil, dataPreprocessHadnler: ((Data)->(Data))? = nil, errorHandler: (([String])->())? = nil, responseHandler: @escaping (T)->()) where T : ResponseData, T : Decodable{
            guard urlComponents.url != nil && urlComponents.url?.query != nil &&
                appState.isInternetAvailable && ((withToken && appState.settings.token != "") || !withToken)
            else {
                return
            }
            let checkResult = canProceed(components: urlComponents)
            if !checkResult.result {
                return
            }
            else if logNetworkActivity && !noCaching{
                appState.logger.log(urlComponents)
            }
            DispatchQueue.main.async {
                self.appState.loadComplete = false
            }
            let requestId = UUID()
            inProgress[requestId] = urlComponents
            postHttp(urlComponents.url!, data: (urlComponents.url?.query?.data(using: .utf8))!, headers: withToken ? Dictionary(dictionaryLiteral: ("Authorization","OAuth \(appState.settings.token)")) : nil, noCaching: noCaching) {(response: HTTPURLResponse?, data: Data?)  in
                do {
                    guard response != nil && data != nil else {
                        DispatchQueue.main.async {
                            self.appState.loadComplete = true
                        }
                        self.appState.logger.log("No response for request \(requestId).")
                        self.inProgress.removeValue(forKey: requestId)
                        return
                    }
                    self.inProgress.removeValue(forKey: requestId)
                    if let handler = statusHadnler{
                        if !handler(response!.statusCode){return}
                    }
                    if response?.statusCode == 401 && self.appState.settings.token != "" {self.appState.settings.deleteToken()}
                    if logNetworkActivity && !noCaching{
                        self.appState.logger.log(response?.statusCode as Any, String(data: data!, encoding: .utf8) as Any)
                    }
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    
                    let jsonResponse = try decoder.decode(T.self, from: dataPreprocessHadnler == nil ? data! : dataPreprocessHadnler!(data!))
                    if let errorMessage = jsonResponse.error?.message{
                        if let handler = errorHandler{
                            handler([String](arrayLiteral: errorMessage))
                        }
                        DispatchQueue.main.async {
                            self.appState.loadComplete  = true
                            self.appState.errorDescription = errorMessage
                            self.appState.showError = true
                        }
                        self.appState.logger.log(errorMessage)
                        return
                    }
                    else if let errors = jsonResponse.errors{
                        let errorMessages = errors.map{$0.message}
                        if let handler = errorHandler{
                            handler(errorMessages)
                        }
                        let errorMessage = errors.map{$0.message}.joined(separator: "\n")
                        DispatchQueue.main.async {
                            self.appState.loadComplete = true
                            self.appState.errorDescription = errorMessage
                            self.appState.showError = true
                        }
                        self.appState.logger.log(errorMessage)
                    }
                    responseHandler(jsonResponse)
                    DispatchQueue.main.async {
                        self.appState.loadComplete  = true
                    }
                }
                catch{
                    DispatchQueue.main.async {
                        self.appState.loadComplete = true
                        self.appState.errorDescription = error.localizedDescription
                        self.appState.showError = true
                    }
                    self.appState.logger.log(error)
                }
            }
        }
        
        private func getHttp(_ url: URL, headers: Dictionary<String,String>? = nil, cachePolicy: URLRequest.CachePolicy = .reloadIgnoringLocalCacheData, noCaching: Bool = false, handler: @escaping (_ response: HTTPURLResponse?, _ data: Data?)->Void) -> Void {
            var request = URLRequest(url: url)
            if let headers = headers {
                for (key,value) in headers{
                    request.setValue(value, forHTTPHeaderField: key)
                }
            }
            request.cachePolicy = cachePolicy
            URLSession.shared.dataTask(with: request,
                completionHandler: { data, response, error in
                if let error = error as NSError? {
                    if error.code == -999 {return}
                    self.appState.logger.log("Network failure: \(error.localizedDescription)")
                    handler(nil, nil)
                } else {
                    handler(response as? HTTPURLResponse, data)
                }
                if noCaching{
                    URLCache.shared.removeCachedResponse(for: request)
                }
            }).resume()
        }
        
        private func postHttp(_ url: URL, data: Data, headers: Dictionary<String,String>? = nil, cachePolicy: URLRequest.CachePolicy = .reloadIgnoringLocalCacheData, noCaching: Bool = false, handler: @escaping (_ response: HTTPURLResponse?, _ data: Data?)->Void) -> Void {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            if let headers = headers {
                for (key,value) in headers{
                    request.setValue(value, forHTTPHeaderField: key)
                }
            }
            request.cachePolicy = cachePolicy
            URLSession.shared.uploadTask(with: request, from: data,
                completionHandler: { data, response, error in
                if let error = error as NSError? {
                    if error.code == -999 {return}
                    self.appState.logger.log("Network failure: \(error.localizedDescription)")
                    handler(nil, nil)
                } else {
                    handler(response as? HTTPURLResponse, data)
                }
                if noCaching{
                    URLCache.shared.removeCachedResponse(for: request)
                }
            }).resume()
        }
    }    
}
