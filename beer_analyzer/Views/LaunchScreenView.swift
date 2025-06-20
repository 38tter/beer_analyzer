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
    
    var body: some View {
        ZStack {
            // ビールテーマの背景
            BeerThemedBackgroundView()
            
            VStack(spacing: 30) {
                // アプリロゴ
                VStack(spacing: 20) {
                    // アプリのタイトルロゴ
                    Image("AppTitleLogo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 240, height: 135)
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
                }
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

#Preview {
    LaunchScreenView()
}