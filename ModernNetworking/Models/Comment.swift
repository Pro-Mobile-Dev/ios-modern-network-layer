//
//  Comment.swift
//  ModernNetworking
//
//  Created by Mark Kazakov on 04/04/2025.
//

struct Comment: Codable, Identifiable {
    let id: Int
    let postId: Int
    let name: String
    let email: String
    let body: String
}
