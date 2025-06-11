//
//  AppStoreReviewRequestView.swift
//  beer_analyzer
//
//  Created by Claude Code on 2025/06/11.
//

import SwiftUI
import StoreKit
import AppStore

struct AppStoreReviewRequestView: View {
    let onDismiss: () -> Void
    let onReviewLater: () -> Void
    let onNeverAsk: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            // ブラー背景
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .background(.ultraThinMaterial)
            
            // メインコンテンツ
            VStack(spacing: 24) {
                // アニメーション付きアイコン
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color(red: 1.0, green: 0.75, blue: 0.3), Color(red: 0.85, green: 0.5, blue: 0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 80, height: 80)
                            .scaleEffect(isAnimating ? 1.1 : 1.0)
                            .animation(
                                Animation.easeInOut(duration: 2.0)
                                    .repeatForever(autoreverses: true),
                                value: isAnimating
                            )
                        
                        Image(systemName: "star.fill")
                            .font(.system(size: 35))
                            .foregroundColor(.white)
                    }
                    
                    Text("🎉")
                        .font(.system(size: 40))
                }
                
                // メッセージ
                VStack(spacing: 12) {
                    Text("おめでとうございます！")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("5個目のビールを登録されました")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text("Beer Analyzerをお楽しみいただき\nありがとうございます！")
                        .font(.body)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
                
                // 評価依頼メッセージ
                VStack(spacing: 8) {
                    Text("⭐ App Storeで評価をお願いします ⭐")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(red: 0.85, green: 0.5, blue: 0.1))
                    
                    Text("あなたの評価が今後の開発の励みになります")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                // ボタン群
                VStack(spacing: 12) {
                    // 評価するボタン
                    Button {
                        requestAppStoreReview()
                        onDismiss()
                    } label: {
                        HStack {
                            Image(systemName: "star.fill")
                                .font(.headline)
                            Text("App Storeで評価する")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [Color(red: 1.0, green: 0.75, blue: 0.3), Color(red: 0.85, green: 0.5, blue: 0.1)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                    }
                    
                    // 後でボタン
                    Button {
                        onReviewLater()
                    } label: {
                        Text("後で評価する")
                            .font(.headline)
                            .fontWeight(.medium)
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(12)
                    }
                    
                    // 今後表示しないボタン
                    Button {
                        onNeverAsk()
                    } label: {
                        Text("今後表示しない")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.regularMaterial)
                    .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
            )
            .padding(.horizontal, 20)
        }
        .onAppear {
            isAnimating = true
        }
    }
    
    private func requestAppStoreReview() {
        // iOS 18以降では新しいAppStore.requestReviewを使用
        if #available(iOS 18.0, *) {
            Task {
                do {
                    try await AppStore.requestReview()
                } catch {
                    print("App Store review request failed: \(error.localizedDescription)")
                    // フォールバック: 古いメソッドを使用
                    fallbackToLegacyReviewRequest()
                }
            }
        } else {
            // iOS 18未満では従来のメソッドを使用
            fallbackToLegacyReviewRequest()
        }
    }
    
    private func fallbackToLegacyReviewRequest() {
        // iOS 14-17でStoreKitを使用してApp Store評価をリクエスト
        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }
}

#Preview {
    AppStoreReviewRequestView(
        onDismiss: {},
        onReviewLater: {},
        onNeverAsk: {}
    )
}