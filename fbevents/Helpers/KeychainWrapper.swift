//
//  KeychainWrapper.swift
//  fbevents
//
//  Created by User on 03.07.2020.
//  Copyright © 2020 nonced. All rights reserved.
//

import Foundation


internal class KeychainWrapper {
    static func SetPassword(username: String = "default", password: String, key: String, access: CFString = kSecAttrAccessibleWhenUnlocked) -> Bool {
        let logger = Logger()
        let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                    kSecAttrAccount as String: username,
                                    kSecAttrServer as String: key,
                                    kSecAttrAccessible as String: access,
                                    kSecValueData as String: password.data(using: String.Encoding.utf8)!]
        let status = SecItemAdd(query as CFDictionary, nil)
        if status == errSecDuplicateItem {logger.log("KeychainWrapper: Item already exists"); return false}
        guard status == errSecSuccess else { logger.log("KeychainWrapper: Status ", status); return false }
        return true
    }
    
    static func GetPassword(key: String) -> (account: String, password: String)? {
        let logger = Logger()
        let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                    kSecAttrServer as String: key,
                                    kSecMatchLimit as String: kSecMatchLimitOne,
                                    kSecReturnAttributes as String: true,
                                    kSecReturnData as String: true]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item) // Searching Keychain for an item.
        guard status != errSecItemNotFound else { logger.log("KeychainWrapper: Password was not found"); return nil }
        guard status == errSecSuccess else { logger.log("KeychainWrapper: Status ", status); return nil }
        guard let existingItem = item as? [String : Any],
            let passwordData = existingItem[kSecValueData as String] as? Data,
            let password = String(data: passwordData, encoding: String.Encoding.utf8),
            let account = existingItem[kSecAttrAccount as String] as? String
        else {
            logger.log("Unexpected Password Data")
            return nil
        }
        return (account, password)
    }
    
    static func UpdatePassword(username: String = "default", password: String, key: String, access: CFString = kSecAttrAccessibleWhenUnlocked) -> Bool {
        let logger = Logger()
        let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                    kSecAttrServer as String: key]
        let attributes: [String: Any] = [kSecAttrAccount as String: username,
                                         kSecAttrAccessible as String: access,
                                         kSecValueData as String: password.data(using: String.Encoding.utf8)!]
        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        guard status != errSecItemNotFound else { logger.log("KeychainWrapper: Password was not found"); return false }
        guard status == errSecSuccess else { logger.log("KeychainWrapper: Status ", status); return false }
        return true
    }

    static func DeletePassword(key: String) -> Bool {
        let logger = Logger()
        let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                    kSecAttrServer as String: key]
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else { logger.log("KeychainWrapper: Status ", status); return false }
        return true
    }
}
