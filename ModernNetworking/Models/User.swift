//
//  User.swift
//  ModernNetworking
//
//  Created by Mark Kazakov on 04/04/2025.
//

struct User: Codable, Identifiable {
    let id: Int
    let name: String
    let username: String
    let email: String
}
