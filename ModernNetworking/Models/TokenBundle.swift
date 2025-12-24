//
//  TokenBundle.swift
//  ModernNetworking
//
//  Created by Mark Kazakov on 24/12/2025.
//

import Foundation

struct TokenBundle: Codable {
    let accessToken: String
    let refreshToken: String
    let expiresAt: Date

    var isExpired: Bool {
        return expiresAt <= Date()
    }
}
