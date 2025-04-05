//
//  ApiRequest.swift
//  ModernNetworking
//
//  Created by Mark Kazakov on 04/04/2025.
//

import Foundation

protocol APIRequest {
    associatedtype Response: Decodable
    var endpoint: Endpoint { get }
}

extension APIRequest {
    var url: URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "jsonplaceholder.typicode.com"
        components.path = endpoint.path
        return components.url
    }
}

struct GetUsersRequest: APIRequest {
    typealias Response = [User]
    let endpoint: Endpoint = .users
}

struct GetPostsRequest: APIRequest {
    typealias Response = [Post]
    let endpoint: Endpoint = .posts
}

struct GetCommentsRequest: APIRequest {
    typealias Response = [Comment]
    let endpoint: Endpoint = .users
}
