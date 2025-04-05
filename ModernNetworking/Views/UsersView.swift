//
//  UsersView.swift
//  ModernNetworking
//
//  Created by Mark Kazakov on 04/04/2025.
//

import SwiftUI

struct UsersView: View {
    @StateObject private var viewModel = UsersViewModel()

    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading...")
                } else if let error = viewModel.errorMessage {
                    Text(error).foregroundColor(.red)
                } else {
                    List(viewModel.users) { user in
                        VStack(alignment: .leading) {
                            Text(user.name).bold()
                            Text(user.email).font(.subheadline).foregroundColor(.gray)
                        }
                    }
                }
            }
            .navigationTitle("Users")
            .task {
                await viewModel.loadUsers()
            }
        }
    }
}
