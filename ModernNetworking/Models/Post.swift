//
//  Post.swift
//  ModernNetworking
//
//  Created by Mark Kazakov on 04/04/2025.
//

struct Post: Codable, Identifiable {
    let id: Int
    let userId: Int
    let title: String
    let body: String
}
