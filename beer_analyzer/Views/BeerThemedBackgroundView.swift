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
    @State private var logoAreaBubbles: [BubbleData] = []
    
    private let bubbleCount = 25
    private let logoAreaBubbleCount = 15
    let logoPosition: CGPoint?
    let logoSize: CGSize?
    let isEnhancedForSplash: Bool
    
    init(logoPosition: CGPoint? = nil, logoSize: CGSize? = nil, isEnhancedForSplash: Bool = false) {
        self.logoPosition = logoPosition
        self.logoSize = logoSize
        self.isEnhancedForSplash = isEnhancedForSplash
    }
    
    var body: some View {
        ZStack {
            // ビールテーマのグラデーション背景
            beerGradientBackground
                .ignoresSafeArea()
            
            // 背景の通常バブルエフェクト
            ForEach(animatedBubbles) { bubble in
                BubbleView(
                    size: bubble.size,
                    opacity: bubble.opacity * (isEnhancedForSplash ? 1.3 : 1.0),
                    color: bubble.color,
                    isEnhanced: isEnhancedForSplash
                )
                .position(bubble.position)
                .animation(
                    Animation.linear(duration: bubble.duration)
                        .repeatForever(autoreverses: false),
                    value: bubble.position
                )
            }
            
            // ロゴ周辺の特別なバブル
            if logoPosition != nil {
                ForEach(logoAreaBubbles) { bubble in
                    BubbleView(
                        size: bubble.size,
                        opacity: bubble.opacity * (isEnhancedForSplash ? 1.5 : 1.2),
                        color: bubble.color,
                        isEnhanced: true
                    )
                    .position(bubble.position)
                    .animation(
                        Animation.linear(duration: bubble.duration)
                            .repeatForever(autoreverses: false),
                        value: bubble.position
                    )
                }
            }
        }
        .onAppear {
            generateBubbles()
            if logoPosition != nil {
                generateLogoAreaBubbles()
            }
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
                size: CGFloat.random(in: 4...18),
                opacity: Double.random(in: 0.2...0.7),
                duration: Double.random(in: 6...12),
                color: randomBubbleColor()
            )
        }
    }
    
    // ロゴ周辺のバブル生成
    private func generateLogoAreaBubbles() {
        guard let logoPos = logoPosition, let logoSize = logoSize else { return }
        
        let logoArea = CGRect(
            x: logoPos.x - logoSize.width / 2 - 50,
            y: logoPos.y - logoSize.height / 2 - 50,
            width: logoSize.width + 100,
            height: logoSize.height + 100
        )
        
        logoAreaBubbles = (0..<logoAreaBubbleCount).map { _ in
            BubbleData(
                position: CGPoint(
                    x: CGFloat.random(in: logoArea.minX...logoArea.maxX),
                    y: CGFloat.random(in: logoArea.minY...logoArea.maxY)
                ),
                size: CGFloat.random(in: 6...24),
                opacity: Double.random(in: 0.3...0.8),
                duration: Double.random(in: 4...8),
                color: randomBubbleColor()
            )
        }
    }
    
    // バブルアニメーションの開始
    private func animateBubbles() {
        let screenHeight = UIScreen.main.bounds.height
        let screenWidth = UIScreen.main.bounds.width
        
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            // 背景バブルのアニメーション
            for i in 0..<animatedBubbles.count {
                let speedMultiplier = isEnhancedForSplash ? 1.5 : 1.0
                animatedBubbles[i].position.y -= CGFloat.random(in: 0.8...2.5) * speedMultiplier
                animatedBubbles[i].position.x += CGFloat.random(in: -1.0...1.0)
                
                if animatedBubbles[i].position.y < -50 {
                    animatedBubbles[i].position.y = screenHeight + 50
                    animatedBubbles[i].position.x = CGFloat.random(in: 0...screenWidth)
                    animatedBubbles[i].size = CGFloat.random(in: 4...18)
                    animatedBubbles[i].opacity = Double.random(in: 0.2...0.7)
                    animatedBubbles[i].color = randomBubbleColor()
                }
            }
            
            // ロゴ周辺バブルのアニメーション
            if let logoPos = logoPosition, let logoSize = logoSize {
                for i in 0..<logoAreaBubbles.count {
                    let speedMultiplier = isEnhancedForSplash ? 2.0 : 1.5
                    logoAreaBubbles[i].position.y -= CGFloat.random(in: 0.5...1.5) * speedMultiplier
                    
                    // ロゴ周辺での円形動作
                    let centerX = logoPos.x
                    let centerY = logoPos.y
                    let angle = atan2(logoAreaBubbles[i].position.y - centerY, logoAreaBubbles[i].position.x - centerX)
                    let radius = sqrt(pow(logoAreaBubbles[i].position.x - centerX, 2) + pow(logoAreaBubbles[i].position.y - centerY, 2))
                    
                    let newAngle = angle + CGFloat.random(in: -0.1...0.1)
                    logoAreaBubbles[i].position.x = centerX + radius * cos(newAngle)
                    
                    // ロゴ周辺のバブルが範囲外に出たらリセット
                    let logoArea = CGRect(
                        x: logoPos.x - logoSize.width / 2 - 100,
                        y: logoPos.y - logoSize.height / 2 - 100,
                        width: logoSize.width + 200,
                        height: logoSize.height + 200
                    )
                    
                    if !logoArea.contains(logoAreaBubbles[i].position) {
                        logoAreaBubbles[i].position = CGPoint(
                            x: CGFloat.random(in: logoArea.minX...logoArea.maxX),
                            y: logoArea.maxY
                        )
                        logoAreaBubbles[i].size = CGFloat.random(in: 6...24)
                        logoAreaBubbles[i].opacity = Double.random(in: 0.3...0.8)
                        logoAreaBubbles[i].color = randomBubbleColor()
                    }
                }
            }
        }
    }
    
    // バブルの色をランダムに選択
    private func randomBubbleColor() -> Color {
        if colorScheme == .dark {
            // ダークモードでは明るめの色のバブル
            let colors: [Color] = [
                Color.white.opacity(0.6),
                Color(red: 0.9, green: 0.8, blue: 0.6).opacity(0.6), // ゴールド
                Color(red: 0.8, green: 0.7, blue: 0.5).opacity(0.5), // アンバー
                Color(red: 1.0, green: 0.9, blue: 0.7).opacity(0.4)  // 明るいクリーム
            ]
            return colors.randomElement() ?? Color.white.opacity(0.6)
        } else {
            // ライトモードでは明るい白やゴールド系
            let colors: [Color] = [
                Color.white.opacity(0.8),
                Color(red: 1.0, green: 0.95, blue: 0.8).opacity(0.7), // クリーム
                Color(red: 0.95, green: 0.85, blue: 0.7).opacity(0.6), // ベージュ
                Color(red: 1.0, green: 0.85, blue: 0.6).opacity(0.5)   // 薄いゴールド
            ]
            return colors.randomElement() ?? Color.white.opacity(0.8)
        }
    }
}

// バブルビュー
struct BubbleView: View {
    let size: CGFloat
    let opacity: Double
    let color: Color
    let isEnhanced: Bool
    @State private var isAnimating = false
    
    init(size: CGFloat, opacity: Double, color: Color, isEnhanced: Bool = false) {
        self.size = size
        self.opacity = opacity
        self.color = color
        self.isEnhanced = isEnhanced
    }
    
    var body: some View {
        ZStack {
            // メインのバブル
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            color,
                            color.opacity(isEnhanced ? 0.8 : 0.6),
                            color.opacity(isEnhanced ? 0.4 : 0.2)
                        ],
                        center: .topLeading,
                        startRadius: size * 0.1,
                        endRadius: size * 0.8
                    )
                )
                .frame(width: size, height: size)
                .opacity(opacity)
                .scaleEffect(isAnimating ? (isEnhanced ? 1.2 : 1.1) : (isEnhanced ? 0.8 : 0.9))
                .animation(
                    Animation.easeInOut(duration: isEnhanced ? Double.random(in: 1...2) : Double.random(in: 2...4))
                        .repeatForever(autoreverses: true),
                    value: isAnimating
                )
            
            // 光の反射効果（拡張版）
            Circle()
                .fill(Color.white.opacity(isEnhanced ? 0.6 : 0.4))
                .frame(width: size * (isEnhanced ? 0.4 : 0.3), height: size * (isEnhanced ? 0.4 : 0.3))
                .offset(x: -size * 0.2, y: -size * 0.2)
                .blur(radius: isEnhanced ? 0.5 : 1)
            
            // 拡張効果：追加の光の輪
            if isEnhanced {
                Circle()
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    .frame(width: size * 1.2, height: size * 1.2)
                    .scaleEffect(isAnimating ? 1.1 : 0.9)
                    .opacity(isAnimating ? 0.2 : 0.5)
                    .animation(
                        Animation.easeInOut(duration: Double.random(in: 1.5...3))
                            .repeatForever(autoreverses: true),
                        value: isAnimating
                    )
            }
        }
        .shadow(
            color: color.opacity(isEnhanced ? 0.5 : 0.3), 
            radius: isEnhanced ? 5 : 3, 
            x: 0, 
            y: 0
        )
        .onAppear {
            isAnimating = true
        }
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
    BeerThemedBackgroundView(
        logoPosition: CGPoint(x: 200, y: 400),
        logoSize: CGSize(width: 240, height: 135),
        isEnhancedForSplash: true
    )
}