//
//  LaunchScreenView.swift
//  beer_analyzer
//
//  Created by Claude Code on 2025/06/11.
//

import SwiftUI

struct LaunchScreenView: View {
    @State private var isRotating = false
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0.0
    
    var body: some View {
        ZStack {
            // 背景グラデーション
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.blue.opacity(0.1),
                    Color.indigo.opacity(0.2),
                    Color.purple.opacity(0.1)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // アプリタイトルロゴ（もしあれば）
                VStack(spacing: 20) {
                    // 回転するビール絵文字
                    Text("🍺")
                        .font(.system(size: 80))
                        .rotationEffect(.degrees(isRotating ? 360 : 0))
                        .scaleEffect(scale)
                        .opacity(opacity)
                        .animation(
                            Animation.linear(duration: 2.0)
                                .repeatForever(autoreverses: false),
                            value: isRotating
                        )
                        .animation(
                            Animation.easeInOut(duration: 1.0),
                            value: scale
                        )
                        .animation(
                            Animation.easeInOut(duration: 0.8),
                            value: opacity
                        )
                    
                    // アプリ名
                    VStack(spacing: 8) {
                        Text("Beer Analyzer")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.blue, .indigo],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .opacity(opacity)
                        
                        Text("ビール解析アプリ")
                            .font(.title3)
                            .foregroundColor(.secondary)
                            .opacity(opacity)
                    }
                }
                
                // ローディングインジケーター
                VStack(spacing: 12) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                        .scaleEffect(1.2)
                        .opacity(opacity)
                    
                    Text("読み込み中...")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .opacity(opacity)
                }
            }
        }
        .onAppear {
            // アニメーション開始
            withAnimation(.easeInOut(duration: 0.8)) {
                opacity = 1.0
                scale = 1.0
            }
            
            // 回転アニメーション開始（少し遅らせて）
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isRotating = true
            }
        }
    }
}

#Preview {
    LaunchScreenView()
}