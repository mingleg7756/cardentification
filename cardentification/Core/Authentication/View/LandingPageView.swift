//
//  LandingPageView.swift
//  cardentification
//
//  Created by Anas Ahmed on 5/2/25.
//


import SwiftUI

struct LandingPageView: View {
    @State private var showCar = false
    @State private var showFlag = false
    @State private var showTitle = false
    @State private var showCurve = false
    @State private var navigateToLogin = false
    @State private var bounce = false

    var body: some View {
        NavigationStack {
            ZStack {
                RadialGradient(
                    gradient: Gradient(colors: [Color(red: 0.929, green: 0.067, blue: 0.012), .black]),
                    center: .center,
                    startRadius: 5,
                    endRadius: 700
                )
                .ignoresSafeArea()
                VStack(spacing: 0) {
                    Spacer()

                    // TITLE
                    ZStack {
                        Text("CAR IQ")
                            .font(.system(size: 60, weight: .heavy))
                            .foregroundColor(.white)
                            .shadow(color: .black, radius: 3)
                            .shadow(color: .white, radius: 6)
                    }
                    .frame(height: 100)
                    .padding(.bottom, -20)
                    .opacity(showTitle ? 1 : 0)
                    .offset(y: showTitle ? 0 : 50)
                    .animation(.easeOut(duration: 1), value: showTitle)

                    // IMAGE
                    Image("landingpageImage")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 250)
                        .padding(.bottom, -40)
                        .opacity(showCar ? 1 : 0)
                        .offset(y: showCar ? 0 : 50)
                        .animation(.easeOut(duration: 1), value: showCar)

                    // CURVED WHITE SHAPE
                    ZStack(alignment: .top) {
                        CurvedBottomShape()
                            .fill(Color.white)
                            .frame(height: 350)
                            .ignoresSafeArea(edges: .bottom)
                            .opacity(showCurve ? 1 : 0)
                            .offset(y: showCurve ? 0 : 50)
                            .animation(.easeOut(duration: 1), value: showCurve)

                        // FLAG on top of white curve
                        RandomText()
                            .font(.system(size: 40, weight: .regular))
                            .foregroundColor(.white)
                            .shadow(color: .black, radius: 3)
                            .shadow(color: .white, radius: 6)
                    .frame(height: 100)
                    .padding(.top, 180)
                    .opacity(showTitle ? 1 : 0)
                    .offset(y: showTitle ? 0 : 50)
                    .animation(.easeOut(duration: 1), value: showTitle)
                    
                    }

                    // SWIPE LEFT TEXT + GESTURE
                    VStack(spacing: 12) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.3), radius: 2)
                            .offset(x: bounce ? -10 : 0)
                            .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: bounce)

                        Text("Swipe left to continue")
                            .font(.title3.bold())
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.3), radius: 1)
                            .offset(x: bounce ? -10 : 0)
                            .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: bounce)
                    }
                    .padding(.top, 24)
                    .gesture(
                        DragGesture(minimumDistance: 20)
                            .onEnded { value in
                                if value.translation.width < -30 {
                                    withAnimation {
                                        navigateToLogin = true
                                    }
                                }
                            }
                    )
                }
            }
            .onAppear {
                showCar = true
                showTitle = true
                showCurve = true
                showFlag = true
                bounce = true
            }
            .navigationDestination(isPresented: $navigateToLogin) {
                LoginView()
                    .navigationBarBackButtonHidden(true)
            }
        }
    }
}

struct CurvedBottomShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.move(to: .zero)
        path.addLine(to: CGPoint(x: 0, y: rect.height * 0.3))
        path.addQuadCurve(to: CGPoint(x: rect.width, y: rect.height * 0.3),
                          control: CGPoint(x: rect.midX, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        path.addLine(to: .zero)
        path.closeSubpath()

        return path
    }
}

struct RandomText: View {
    let messages = [
        "Unlock a car’s info with the snap of a photo",
        "Discover details instantly",
        "Find Similar Cars Today"
    ]

    @State private var currentIndex = 0
    @State private var opacity = 0.0

    var body: some View {
        Text(messages[currentIndex])
            .font(.system(size: 22, weight: .medium))
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 16)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeIn(duration: 1)) {
                    opacity = 1.0
                }

                Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in
                    withAnimation(.easeOut(duration: 0.5)) {
                        opacity = 0.0
                    }

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        currentIndex = (currentIndex + 1) % messages.count

                        withAnimation(.easeIn(duration: 0.8)) {
                            opacity = 1.0
                        }
                    }
                }
            }
    }
}

// PREVIEW
#Preview {
    LandingPageView()
        .environmentObject(AuthViewModel())
}
