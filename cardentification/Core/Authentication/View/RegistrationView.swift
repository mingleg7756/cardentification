//
//  RegistrationView.swift
//  cardentification
//
//  Created by Anthony Jerez on 4/18/25.
//

import SwiftUI

struct RegistrationView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var fullName = ""
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        VStack {
            
            VStack(spacing: 24) {
                InputView(text: $email, title: "Email Address", placeholder: "example@gmail.com")
                    .autocapitalization(.none)
                
                InputView(text: $fullName, title: "Full Name", placeholder: "Enter your name")
                
                InputView(text: $password, title: "Password", placeholder: "Enter password", isSecureField: true)
                
                ZStack(alignment: .trailing) {
                    InputView(text: $confirmPassword, title: "Confirm Password", placeholder: "Enter password again", isSecureField: true)
                        
                    if !password.isEmpty && !confirmPassword.isEmpty {
                        if password == confirmPassword {
                            Image(systemName: "checkmark.circle.fill").imageScale(.large).fontWeight(.bold).foregroundColor(Color(.systemBlue))
                        } else {
                            Image(systemName: "xmark.circle.fill").imageScale(.large).fontWeight(.bold).foregroundColor(Color(.systemRed))
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 80)
            
            Button {
                Task {
                    try await viewModel.createUser(withEmail: email, password: password, fullName: fullName)
                }
            } label: {
                HStack {
                    Text("SIGN UP")
                        .fontWeight(.semibold)
                    Image(systemName: "arrow.right")
                }
                .foregroundColor(.white)
                .frame(width: UIScreen.main.bounds.width - 32, height: 40)
            }
            .background(Color(.systemBlue))
            .disabled(!formIsValid)
            .opacity(formIsValid ? 1.0 : 0.5)
            .cornerRadius(10)
            .padding(.top, 24)
            
            Spacer()
            
            Button {
                dismiss()
            } label: {
                HStack(spacing: 3) {
                    Text("Already have an account?")
                    Text("Sign in")
                        .fontWeight(.bold)
                }
                .font(.system(size: 14))
            }
        }
    }
}

extension RegistrationView: AuthenticationFormProtocol {
    var formIsValid: Bool {
        return !email.isEmpty
        && email.contains("@")
        && !password.isEmpty
        && password.count > 5
        && confirmPassword == password
        && !fullName.isEmpty
    }
}

#Preview {
    RegistrationView()
}
