//
//  ProfileView.swift
//  cardentification
//
//  Created by Anthony Jerez on 4/18/25.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        if let user = viewModel.currentUser {
            List {
                Section {
                    HStack {
                        Text(user.initials)
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(width: 72, height: 72)
                            .background(Color(.systemGray))
                            .clipShape(Circle())
                        
                        VStack (alignment: .leading, spacing: 4){
                            Text(user.fullName)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .padding(.top, 4)
                            
                            Text(user.email)
                                .font(.footnote)
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                Section("Account") {
                    Button {
                        viewModel.signOut()
                    } label: {
                        SettingsRowView(imageName: "arrow.left.circle.fill", title: "Sign out", tintColor: .red)
                    }
                    
                    Button {
                        Task {
                            await viewModel.deleteAccount()
                        }
                    } label: {
                        SettingsRowView(imageName: "xmark.circle.fill", title: "Delete account", tintColor: .red)
                    }
                }
            }
        }
    }
}

#Preview {
    ProfileView().environmentObject(AuthViewModel())
}
