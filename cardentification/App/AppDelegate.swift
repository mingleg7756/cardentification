//
//  AppDelegate.swift
//  cardentification
//
//  Created by Anthony Jerez on 5/8/25.
//

import Firebase
import GoogleSignIn

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {

        GIDSignIn.sharedInstance.handle(url)
    }
}
