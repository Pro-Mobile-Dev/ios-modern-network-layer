//
//  KeychainService.swift
//  ModernNetworking
//
//  Created by Mark Kazakov on 24/12/2025.
//

import Foundation
import Security

/// A simple helper for storing and retrieving data from the Keychain.
/// This stores and retrieves a single `TokenBundle` under a fixed key.
/// You can generalize it if you need to store more items.
enum KeychainService {

    enum KeychainError: Error {
        case unhandled(status: OSStatus)
    }

    private static let service = "pro.mobile.dev.ModernNetworking"
    private static let account = "authTokens"

    /// Saves the given token bundle to the keychain, overwriting any existing value.
    static func save(_ tokens: TokenBundle) throws {
        let data = try JSONEncoder().encode(tokens)
        // First delete any existing item
        try? delete()
        // Then add the new item
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data
        ]
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.unhandled(status: status)
        }
    }

    /// Loads the token bundle from the keychain, or returns nil if not present.
    static func load() throws -> TokenBundle? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var item: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        if status == errSecItemNotFound {
            return nil
        }
        guard status == errSecSuccess, let data = item as? Data else {
            throw KeychainError.unhandled(status: status)
        }
        return try JSONDecoder().decode(TokenBundle.self, from: data)
    }

    /// Removes the token bundle from the keychain.
    static func delete() throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unhandled(status: status)
        }
    }
}
