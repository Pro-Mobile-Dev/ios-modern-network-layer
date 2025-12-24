//
//  AuthManager.swift
//  ModernNetworking
//
//  Created by Mark Kazakov on 24/12/2025.
//

import Foundation

/// Manages access and refresh tokens.
/// Uses an actor to serialize token access and refresh operations safely.
actor AuthManager {
    private var refreshTask: Task<TokenBundle, Error>?
    private var currentTokens: TokenBundle?

    init() {
        // Load any persisted tokens from the keychain
        currentTokens = try? KeychainService.load()
    }

    /// Returns a valid token bundle, refreshing if necessary.
    /// Throws if no tokens are available or if refresh fails.
    func validTokenBundle() async throws -> TokenBundle {
        // If there is an in‑flight refresh, await its result.
        if let task = refreshTask {
            return try await task.value
        }

        // No tokens saved? User must log in first.
        guard let tokens = currentTokens else {
            throw AuthError.noCredentials
        }

        // If token is still valid, return it.
        if !tokens.isExpired {
            return tokens
        }

        // Otherwise refresh the token.
        return try await refreshTokens()
    }

    /// Forces a refresh regardless of expiration status.
    func refreshTokens() async throws -> TokenBundle {
        // If a refresh is already happening, await it.
        if let task = refreshTask {
            return try await task.value
        }

        // No saved refresh token? User must log in again.
        guard let tokens = currentTokens else {
            throw AuthError.noCredentials
        }

        // Start a refresh task
        let task = Task { () throws -> TokenBundle in
            defer { refreshTask = nil }

            // Build a request to your auth server’s refresh endpoint.
            var components = URLComponents()
            components.scheme = "https"
            components.host = "api.example.com"     // change to your auth server
            components.path = "/oauth/token"
            var request = URLRequest(url: components.url!)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let body: [String: String] = ["refresh_token": tokens.refreshToken]
            request.httpBody = try JSONEncoder().encode(body)

            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse,
                  (200..<300).contains(httpResponse.statusCode) else {
                throw AuthError.invalidCredentials
            }
            // Decode the response into a new TokenBundle.
            let newTokens = try JSONDecoder().decode(TokenBundle.self, from: data)

            // Persist and cache the new tokens.
            try KeychainService.save(newTokens)
            currentTokens = newTokens
            return newTokens
        }

        // Store the in‑flight task so concurrent calls share it.
        refreshTask = task
        return try await task.value
    }

    /// Clears stored tokens from memory and keychain.
    func clearTokens() async throws {
        currentTokens = nil
        try KeychainService.delete()
    }
}

/// Errors thrown by `AuthManager`.
enum AuthError: Error {

    /// No tokens exist; the user must log in.
    case noCredentials

    /// Refresh failed or credentials are invalid.
    case invalidCredentials
}
