//
//  beer_analyzerApp.swift
//  beer_analyzer
//
//  Created by 宮田聖也 on 2025/06/02.
//

import UIKit
import SwiftUI
import FirebaseCore


class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    
    return true
  }
}

@main
struct beer_analyzerApp: App {
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var firestoreService = FirestoreService()
    @State private var isLoading = true
    @State private var hasAcceptedTerms = UserDefaultsService.hasAcceptedTerms()
    
    var body: some Scene {
        WindowGroup {
            Group {
                if isLoading {
                    LaunchScreenView()
                        .onAppear {
                            // スプラッシュスクリーン表示時間（2.5秒）
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    isLoading = false
                                }
                            }
                        }
                } else if !hasAcceptedTerms {
                    TermsOfUseView(
                        onAccept: {
                            UserDefaultsService.setTermsAccepted(true)
                            hasAcceptedTerms = true
                        },
                        isPresentedForAcceptance: true
                    )
                    .transition(.opacity)
                } else {
                    ContentView()
                        .environmentObject(firestoreService)
                        .transition(.opacity)
                }
            }
        }
    }
}
