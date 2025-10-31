
//
//  SnapCarPhotoView.swift
//  cardentification
//
//  Created by Anthony Jerez on 4/18/25.
//

import SwiftUI
import UIKit

struct SnapCarPhotoView: View {
    @EnvironmentObject var auth: AuthViewModel
    @StateObject private var vm = SnapCarPhotoViewModel()

    var body: some View {
        ZStack {
            Theme.backgroundGradient.ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Text("Snap")
                        .font(.system(size: 34, weight: .heavy))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.25), radius: 3, x: 0, y: 1)
                    Spacer()
                }
                .padding(.top, 8)
                .padding(.horizontal, 20)

                ZStack {
                    Color.white
                        .clipShape(RoundedCorner(radius: 28, corners: [.topLeft, .topRight]))
                        .ignoresSafeArea(edges: .bottom)
                        .overlay(
                            RoundedCorner(radius: 28, corners: [.topLeft, .topRight])
                                .stroke(Theme.cardStroke, lineWidth: 1.2)
                                .ignoresSafeArea(edges: .bottom)
                        )

                    ScrollView {
                        VStack(spacing: 20) {
                            // preview card
                            VStack(spacing: 12) {
                                if let img = vm.image {
                                    Image(uiImage: img)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(height: 260)
                                        .clipped()
                                        .clipShape(RoundedRectangle(cornerRadius: 18))
                                } else {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 18).fill(.gray.opacity(0.12))
                                        VStack(spacing: 8) {
                                            Image(systemName: "camera.viewfinder")
                                                .font(.system(size: 36))
                                                .foregroundColor(.secondary)
                                            Text("No photo selected").foregroundColor(.secondary)
                                        }
                                    }
                                    .frame(height: 220)
                                }
                                Text("Tip: take the photo head-on and fill the frame with the car.")
                                    .font(.footnote).foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .padding(14)
                            .background(Theme.glassCard)
                            .cornerRadius(22)
                            .overlay(RoundedRectangle(cornerRadius: 22).stroke(Theme.cardStroke, lineWidth: 1.1))
                            .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
                            .padding(.top, 16)
                            .padding(.horizontal, 16)

                            HStack(spacing: 12) {
                                Button { vm.choose(.camera) } label: {
                                    Label("Camera", systemImage: "camera.fill").frame(maxWidth: .infinity)
                                }
                                .buttonStyle(OutlineRedButton())
                                .disabled(!UIImagePickerController.isSourceTypeAvailable(.camera))

                                Button { vm.choose(.photoLibrary) } label: {
                                    Label("Photo Library", systemImage: "photo.on.rectangle.angled")
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(OutlineRedButton())
                            }
                            .padding(.horizontal, 16)

                            Button {
                                if let uid = auth.userSession?.uid {
                                    Task { await vm.identifyAndSave(for: uid) }
                                }
                            } label: {
                                Label(vm.isIdentifying ? "Identifying…" : "Identify Car",
                                      systemImage: "magnifyingglass")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(PrimaryRedButton())
                            .disabled(vm.image == nil || vm.isIdentifying)
                            .opacity(vm.image == nil ? 0.55 : 1.0)
                            .padding(.horizontal, 16)

                            Spacer(minLength: 20)
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $vm.showPicker) {
            ImagePicker(sourceType: vm.pickerSource, selectedImage: $vm.image)
        }
    }
}
