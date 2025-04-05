//
//  NetworkClient.swift
//  ModernNetworking
//
//  Created by Mark Kazakov on 04/04/2025.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case decodingError
    case serverError(statusCode: Int)
    case unknown(Error)
}

enum HTTPMethod: String {
    case GET, POST, PUT, DELETE
}


enum Endpoint {
    case users
    case posts
    case comments(postId: Int)

    var path: String {
        switch self {
        case .users: return "/users"
        case .posts: return "/posts"
        case .comments(let postId): return "/posts/\(postId)/comments"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .users, .posts, .comments:
            return .GET
        }
    }
}

final class NetworkClient {
    func send<T: APIRequest>(_ request: T) async throws -> T.Response {
        guard let url = request.url else {
            throw NetworkError.invalidURL
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.endpoint.method.rawValue

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await URLSession.shared.data(for: urlRequest)
        } catch {
            throw NetworkError.unknown(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.unknown(NSError(domain: "Invalid response", code: 0))
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            throw NetworkError.serverError(statusCode: httpResponse.statusCode)
        }

        do {
            return try JSONDecoder().decode(T.Response.self, from: data)
        } catch {
            throw NetworkError.decodingError
        }
    }
}
