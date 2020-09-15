//
//  LoginPageResponse.swift
//  fbevents
//
//  Created by User on 07.08.2020.
//  Copyright © 2020 nonced. All rights reserved.
//

import Foundation


extension Networking {
    struct LoginPageResponse: Codable, ResponseData{
        struct SessionCookie: Codable{
            var name: String
            var value: String
            var expiresTimestamp: Int
            var domain: String
        }
        struct RequestArgument: Codable{
            var key: String
            var value: String
        }
        struct ErrorData: Codable{
            var machineId: String
            var uid: Int?
            var loginFirstFactor: String?
            var authToken: String?
            var cpForNonGmailOauth: [String]?
            var errorTitle: String
            var errorMessage: String
        }
        var sessionKey: String?
        var uid: Int?
        var secret: String?
        var accessToken: String?
        var sessionCookies: [SessionCookie]?
        var analyticsClaim: String?
        var userStorageKey: String?
        
        var errorCode: Int?
        var errorMsg: String?
        var errorData: String?
        var requestArgs: [RequestArgument]?
        
        var error: Networking.GenericError.ErrorMessage?
        var errors: [Networking.GenericError.ErrorMessage]?
    }
}
