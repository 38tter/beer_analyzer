//
//  LaunchScreenView.swift
//  beer_analyzer
//
//  Created by Claude Code on 2025/06/11.
//

import SwiftUI

struct LaunchScreenView: View {
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0.0
    
    private let logoSize = CGSize(width: 240, height: 135)
    
    var body: some View {
        GeometryReader { geometry in
            let logoPosition = CGPoint(
                x: geometry.size.width / 2,
                y: geometry.size.height / 2 - 50
            )
            
            ZStack {
                // ビールテーマの背景（スプラッシュ画面用強化版）
                BeerThemedBackgroundView(
                    logoPosition: logoPosition,
                    logoSize: logoSize,
                    isEnhancedForSplash: true
                )
                
                VStack(spacing: 30) {
                // アプリロゴ
                VStack(spacing: 20) {
                    // アプリのタイトルロゴ
                    Image("AppTitleLogo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: logoSize.width, height: logoSize.height)
                        .scaleEffect(scale)
                        .opacity(opacity)
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
                                    colors: [Color(red: 1.0, green: 0.75, blue: 0.3), Color(red: 0.85, green: 0.5, blue: 0.1)],
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
                        .progressViewStyle(CircularProgressViewStyle(tint: Color(red: 0.85, green: 0.5, blue: 0.1)))
                        .scaleEffect(1.2)
                        .opacity(opacity)
                    
                    Text("読み込み中...")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .opacity(opacity)
                }
            }
            .onAppear {
                // アニメーション開始
                withAnimation(.easeInOut(duration: 0.8)) {
                    opacity = 1.0
                    scale = 1.0
                }
            }
        }
    }
}

#Preview {
    LaunchScreenView()
}