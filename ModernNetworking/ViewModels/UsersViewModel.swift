//
//  UsersViewModel.swift
//  ModernNetworking
//
//  Created by Mark Kazakov on 05/04/2025.
//

import SwiftUI

@MainActor
class UsersViewModel: ObservableObject {
    @Published var users: [User] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let client = NetworkClient()

    func loadUsers() async {
        isLoading = true
        errorMessage = nil

        do {
            let users = try await client.send(GetUsersRequest())
            self.users = users
        } catch {
            errorMessage = "Failed to load users: \(error.localizedDescription)"
        }

        isLoading = false
    }
}
