//
//  LoginModel.swift
//  fbevents
//
//  Created by User on 03.07.2020.
//  Copyright © 2020 nonced. All rights reserved.
//

import SwiftUI


extension LoginView{
    func loginFirstFactor(email: String, password: String) {
        var components = URLComponents(url: URL(string: "https://b-api.facebook.com/method/auth.login")!, resolvingAgainstBaseURL: false)!
        components.queryItems = [
            URLQueryItem(name: "adid", value: self.appState.settings.advId),
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "device_id", value: self.appState.settings.deviceId),
            URLQueryItem(name: "email", value: email),
            URLQueryItem(name: "password", value: password),
            URLQueryItem(name: "generate_analytics_claim", value: "1"),
            URLQueryItem(name: "community_id", value: ""),
            URLQueryItem(name: "cpl", value: "true"),
            URLQueryItem(name: "try_num", value: "1"),
            URLQueryItem(name: "family_device_id", value: self.appState.settings.deviceId),
            URLQueryItem(name: "credentials_type", value: "password"),
            URLQueryItem(name: "generate_session_cookies", value: "1"),
            URLQueryItem(name: "error_detail_type", value: "button_with_disabled"),
            URLQueryItem(name: "source", value: "login"),
            URLQueryItem(name: "generate_machine_id", value: "1"),
            URLQueryItem(name: "meta_inf_fbmeta", value: ""),
            URLQueryItem(name: "advertiser_id", value: self.appState.settings.advId),
            URLQueryItem(name: "encrypted_msisdn", value: ""),
            URLQueryItem(name: "currently_logged_in_userid", value: "0"),
            URLQueryItem(name: "locale", value: self.appState.settings.locale),
            URLQueryItem(name: "client_country_code", value: self.appState.settings.locale),
            URLQueryItem(name: "method", value: "auth.login"),
            URLQueryItem(name: "fb_api_req_friendly_name", value: "authenticate"),
            URLQueryItem(name: "fb_api_caller_class", value: "com.facebook.account.login.protocol.Fb4aAuthHandler"),
            URLQueryItem(name: "api_key", value: "882a8490361da98702bf97a021ddc14d"),
            URLQueryItem(name: "access_token", value: "350685531728|62f8ce9f74b12f84c123cc23437a4a32")
        ]
        appState.networkManager?.postURL(urlComponents: components, withToken: false, noCaching: true){(response: Networking.LoginPageResponse) in
            do{
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                if let token = response.accessToken{
                    DispatchQueue.main.async {
                        self.appState.settings.token = token
                        self.appState.settings.userId = response.uid ?? 0
                        guard KeychainWrapper.SetPassword(password: self.appState.settings.token, key: "authToken") else {
                            self.appState.loadComplete = true
                            fatalError("Cannot save token")
                        }
                    }
                }
                else if let errorCode = response.errorCode{
                    let errData = try decoder.decode(Networking.LoginPageResponse.ErrorData.self, from: (response.errorData?.data(using: .utf8))!)
                    if errorCode == 406 { // second factor is on, proceed to second stage
                        DispatchQueue.main.async {
                            self.appState.loadComplete = true
                            self.firstStageAuthResponse = (errData.machineId, String(errData.uid!), errData.loginFirstFactor!)
                        }
                    }
                    else{
                        DispatchQueue.main.async {
                            self.appState.loadComplete = true
                            self.appState.errorDescription = errData.errorMessage
                            self.appState.showError = true
                        }
                        self.appState.logger.log(errData.errorMessage)
                    }
                }
            }
            catch{
                self.appState.logger.log(error)
                DispatchQueue.main.async {
                    self.appState.loadComplete = true
                    self.appState.errorDescription = error.localizedDescription
                    self.appState.showError = true
                }
            }
        }
    }
    
    func loginSecondFactor(code: String, machineId: String, userId: String, firstFactor: String) {
        var components = URLComponents(url: URL(string: "https://b-api.facebook.com/method/auth.login")!, resolvingAgainstBaseURL: false)!
        components.queryItems = [
            URLQueryItem(name: "adid", value: self.appState.settings.advId),
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "device_id", value: self.appState.settings.deviceId),
            URLQueryItem(name: "email", value: email),
            URLQueryItem(name: "password", value: code),
            URLQueryItem(name: "generate_analytics_claim", value: "1"),
            URLQueryItem(name: "community_id", value: ""),
            URLQueryItem(name: "cpl", value: "true"),
            URLQueryItem(name: "try_num", value: "1"),
            URLQueryItem(name: "family_device_id", value: self.appState.settings.deviceId),
            URLQueryItem(name: "credentials_type", value: "two_factor"),
            URLQueryItem(name: "generate_session_cookies", value: "1"),
            URLQueryItem(name: "error_detail_type", value: "button_with_disabled"),
            URLQueryItem(name: "source", value: "login"),
            URLQueryItem(name: "machine_id", value: machineId),
            URLQueryItem(name: "meta_inf_fbmeta", value: ""),
            URLQueryItem(name: "twofactor_code", value: code),
            URLQueryItem(name: "userid", value: userId),
            URLQueryItem(name: "first_factor", value: firstFactor),
            URLQueryItem(name: "advertiser_id", value: self.appState.settings.advId),
            URLQueryItem(name: "encrypted_msisdn", value: ""),
            URLQueryItem(name: "currently_logged_in_userid", value: "0"),
            URLQueryItem(name: "locale", value: self.appState.settings.locale),
            URLQueryItem(name: "client_country_code", value: self.appState.settings.locale),
            URLQueryItem(name: "method", value: "auth.login"),
            URLQueryItem(name: "fb_api_req_friendly_name", value: "authenticate"),
            URLQueryItem(name: "fb_api_caller_class", value: "com.facebook.account.login.protocol.Fb4aAuthHandler"),
            URLQueryItem(name: "api_key", value: "882a8490361da98702bf97a021ddc14d"),
            URLQueryItem(name: "access_token", value: "350685531728|62f8ce9f74b12f84c123cc23437a4a32")
        ]
        appState.networkManager?.postURL(urlComponents: components, withToken: false, noCaching: true){(response: Networking.LoginPageResponse) in
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                if let token = response.accessToken{
                    DispatchQueue.main.async {
                        self.appState.settings.token = token
                        self.appState.settings.userId = response.uid ?? 0
                        self.firstStageAuthResponse = nil
                        guard KeychainWrapper.SetPassword(password: self.appState.settings.token, key: "authToken") else {
                            self.appState.loadComplete = true
                            self.appState.errorDescription = "Cannot save authToken"
                            self.appState.showError = true
                            self.appState.logger.log(self.appState.errorDescription)
                            return
                        }
                        self.appState.loadComplete = true
                    }
                }
                else if response.errorCode != nil{
                    let errData = try decoder.decode(Networking.LoginPageResponse.ErrorData.self, from: (response.errorData?.data(using: .utf8))!)
                    self.appState.logger.log(errData.errorMessage)
                    DispatchQueue.main.async {
                        self.appState.loadComplete = true
                        self.appState.errorDescription = errData.errorMessage
                        self.appState.showError = true
                    }
                }
            }
            catch{
                self.appState.logger.log(error)
                DispatchQueue.main.async {
                    self.appState.loadComplete = true
                    self.appState.errorDescription = error.localizedDescription
                    self.appState.showError = true
                }
            }
        }
    }
}
