//
//  TootRainKeychain.swift
//  TootRain
//
//  Created by b123400 on 2026/10/27.
//

import Foundation
import Security

/// Internet-password storage for the TootRain server secrets, filed the same way
/// the Mastodon / Misskey / IRC accounts file theirs: one item per
/// (server, account) pair, tagged 'otok'.
enum TootRainKeychain {

    private static let tokenType = NSNumber(value: UInt32(0x6f746f6b)) // 'otok'

    static func string(server: String, account: String) -> String? {
        var query = identity(server: server, account: account)
        query[kSecReturnData as String] = kCFBooleanTrue
        var result: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess, let data = result as? Data else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }

    static func setString(_ value: String?, server: String, account: String) {
        let identity = self.identity(server: server, account: account)
        guard let data = value?.data(using: .utf8) else {
            SecItemDelete(identity as CFDictionary)
            return
        }
        let attributes = [kSecValueData as String: data] as CFDictionary
        let updateStatus = SecItemUpdate(identity as CFDictionary, attributes)
        if updateStatus == errSecItemNotFound {
            var item = identity
            item[kSecValueData as String] = data
            let addStatus = SecItemAdd(item as CFDictionary, nil)
            if addStatus != errSecSuccess {
                NSLog("TootRainKeychain: failed to add %@: %d", account, Int(addStatus))
            }
        } else if updateStatus != errSecSuccess {
            NSLog("TootRainKeychain: failed to update %@: %d", account, Int(updateStatus))
        }
    }

    static func remove(server: String, account: String) {
        setString(nil, server: server, account: account)
    }

    private static func identity(server: String, account: String) -> [String: Any] {
        [
            kSecClass as String: kSecClassInternetPassword,
            kSecAttrServer as String: server,
            kSecAttrType as String: tokenType,
            kSecAttrAccount as String: account,
        ]
    }
}
