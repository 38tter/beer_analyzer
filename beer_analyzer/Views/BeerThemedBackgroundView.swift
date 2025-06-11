//
//  BeerThemedBackgroundView.swift
//  beer_analyzer
//
//  Created by Claude Code on 2025/06/11.
//

import SwiftUI

struct BeerThemedBackgroundView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var animatedBubbles: [BubbleData] = []
    
    private let bubbleCount = 15
    
    var body: some View {
        ZStack {
            // ビールテーマのグラデーション背景
            beerGradientBackground
                .ignoresSafeArea()
            
            // 浮遊するバブルエフェクト
            ForEach(animatedBubbles) { bubble in
                BubbleView(
                    size: bubble.size,
                    opacity: bubble.opacity,
                    color: bubble.color
                )
                .position(bubble.position)
                .animation(
                    Animation.linear(duration: bubble.duration)
                        .repeatForever(autoreverses: false),
                    value: bubble.position
                )
            }
        }
        .onAppear {
            generateBubbles()
            animateBubbles()
        }
    }
    
    // ライト/ダークモードに応じたビールグラデーション
    private var beerGradientBackground: some View {
        if colorScheme == .dark {
            // ダークモード: 黒ビールのようなブラウンからダークへ
            return LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.2, green: 0.1, blue: 0.05), // ダークブラウン
                    Color(red: 0.15, green: 0.08, blue: 0.03), // より深いブラウン
                    Color(red: 0.1, green: 0.05, blue: 0.02), // ほぼ黒
                    Color.black.opacity(0.9)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            // ライトモード: ビールのようなアンバーからゴールドへ
            return LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 1.0, green: 0.75, blue: 0.3), // ゴールド
                    Color(red: 0.95, green: 0.65, blue: 0.2), // アンバー
                    Color(red: 0.9, green: 0.55, blue: 0.15), // より深いアンバー
                    Color(red: 0.85, green: 0.5, blue: 0.1).opacity(0.8) // 銅色がかったアンバー
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    // バブルデータの生成
    private func generateBubbles() {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        animatedBubbles = (0..<bubbleCount).map { _ in
            BubbleData(
                position: CGPoint(
                    x: CGFloat.random(in: 0...screenWidth),
                    y: screenHeight + 50 // 画面下から開始
                ),
                size: CGFloat.random(in: 3...12),
                opacity: Double.random(in: 0.1...0.4),
                duration: Double.random(in: 8...15),
                color: randomBubbleColor()
            )
        }
    }
    
    // バブルアニメーションの開始
    private func animateBubbles() {
        let screenHeight = UIScreen.main.bounds.height
        
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            for i in 0..<animatedBubbles.count {
                // バブルを上に移動
                animatedBubbles[i].position.y -= CGFloat.random(in: 0.5...2.0)
                
                // 横方向の微細な動き
                animatedBubbles[i].position.x += CGFloat.random(in: -0.5...0.5)
                
                // バブルが画面上部に到達したら下部にリセット
                if animatedBubbles[i].position.y < -50 {
                    animatedBubbles[i].position.y = screenHeight + 50
                    animatedBubbles[i].position.x = CGFloat.random(in: 0...UIScreen.main.bounds.width)
                    animatedBubbles[i].size = CGFloat.random(in: 3...12)
                    animatedBubbles[i].opacity = Double.random(in: 0.1...0.4)
                    animatedBubbles[i].color = randomBubbleColor()
                }
            }
        }
    }
    
    // バブルの色をランダムに選択
    private func randomBubbleColor() -> Color {
        if colorScheme == .dark {
            // ダークモードでは薄い色のバブル
            let colors: [Color] = [
                Color.white.opacity(0.3),
                Color(red: 0.9, green: 0.8, blue: 0.6).opacity(0.3), // 薄いゴールド
                Color(red: 0.8, green: 0.7, blue: 0.5).opacity(0.3)  // 薄いアンバー
            ]
            return colors.randomElement() ?? Color.white.opacity(0.3)
        } else {
            // ライトモードでは薄い白やゴールド系
            let colors: [Color] = [
                Color.white.opacity(0.6),
                Color(red: 1.0, green: 0.95, blue: 0.8).opacity(0.5), // 薄いクリーム
                Color(red: 0.95, green: 0.85, blue: 0.7).opacity(0.4)  // 薄いベージュ
            ]
            return colors.randomElement() ?? Color.white.opacity(0.6)
        }
    }
}

// バブルビュー
struct BubbleView: View {
    let size: CGFloat
    let opacity: Double
    let color: Color
    
    var body: some View {
        Circle()
            .fill(color)
            .frame(width: size, height: size)
            .opacity(opacity)
            .blur(radius: 1)
    }
}

// バブルデータ構造
struct BubbleData: Identifiable {
    let id = UUID()
    var position: CGPoint
    var size: CGFloat
    var opacity: Double
    var duration: Double
    var color: Color
}

#Preview {
    BeerThemedBackgroundView()
}