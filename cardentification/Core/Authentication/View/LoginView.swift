//
//  LoginView.swift
//  cardentification
//
//  Created by Anthony Jerez on 4/18/25.
//

import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @EnvironmentObject var viewModel: AuthViewModel

    var body: some View {
        NavigationStack {
            ZStack {
                // Background image
                Image("steering")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .ignoresSafeArea()

                VStack {
                    VStack(alignment: .leading, spacing: 12) {
                        InputView(text: $email, title: "Email Address", placeholder: "example@gmail.com")
                            .autocapitalization(.none)

                        InputView(text: $password, title: "Password", placeholder: "Enter password", isSecureField: true)

                        Button {
                            Task {
                                try await viewModel.signIn(withEmail: email, password: password)
                            }
                        } label: {
                            HStack {
                                Text("SIGN IN")
                                    .fontWeight(.semibold)
                                Image(systemName: "arrow.right")
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, minHeight: 44)
                        }
                        .background(Color.red)
                        .cornerRadius(10)

                        HStack {
                            Spacer()
                            NavigationLink {
                                RegistrationView()
                                    .navigationBarBackButtonHidden(true)
                            } label: {
                                HStack(spacing: 3) {
                                    Text("Don't have an account?")
                                    Text("Sign up")
                                        .fontWeight(.bold)
                                }
                                .font(.system(size: 14))
                                .foregroundColor(.red)
                            }
                            Spacer()
                        }

                    }
                    .padding(20)
                    .background(Color.white.opacity(0.85))
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.red, lineWidth: 1.5)
                    )
                    .frame(maxWidth: 350)
                }
                .frame(maxHeight: .infinity)
            }
        }
    }
}

// MARK: - Validation
extension LoginView: AuthenticationFormProtocol {
    var formIsValid: Bool {
        return !email.isEmpty &&
               email.contains("@") &&
               !password.isEmpty &&
               password.count > 5
    }
}

// MARK: - Preview
#Preview {
    LoginView()
        .environmentObject(AuthViewModel())
}
