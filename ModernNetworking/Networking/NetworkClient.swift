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
    case unauthorized
    case unknown(Error)
}

enum HTTPMethod: String {
    case GET, POST, PUT, DELETE
}


enum Endpoint {
    case users
    case posts
    case comments(postId: Int)
    case secureEndpoint

    var path: String {
        switch self {
        case .users: return "/users"
        case .posts: return "/posts"
        case .comments(let postId): return "/posts/\(postId)/comments"
        case .secureEndpoint: return "/secure-data" // This is just an example
        }
    }

    var method: HTTPMethod {
        switch self {
        case .users, .posts, .comments, .secureEndpoint:
            return .GET
        }
    }

    var requiresAuthentication: Bool {
        switch self {
        case .secureEndpoint: return true
        default : return false
        }
    }
}

final class NetworkClient {

    private let authManager: AuthManager

    init(authManager: AuthManager = AuthManager()) {
        self.authManager = authManager
    }

    func send<T: APIRequest>(_ request: T, allowRetry: Bool = true) async throws -> T.Response {
        guard let url = request.url else {
            throw NetworkError.invalidURL
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.endpoint.method.rawValue

        if request.endpoint.requiresAuthentication {
            let tokens = try await authManager.validTokenBundle()
            urlRequest.setValue("Bearer \(tokens.accessToken)", forHTTPHeaderField: "Authorization")
        }

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await URLSession.shared.data(for: urlRequest)
        } catch {
            throw NetworkError.unknown(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.unknown(NSError(domain: "Invalid response", code: 0))
        }

        // On 401, refresh and retry once.
        if httpResponse.statusCode == 401 {
            guard allowRetry else {
                throw NetworkError.unauthorized
            }

            do {
                _ = try await authManager.refreshTokens()
                return try await send(request, allowRetry: false)
            } catch {
                // refresh failed -> force re-auth path
                // optionally: try? await authManager.clearTokens()
                throw error
            }
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
