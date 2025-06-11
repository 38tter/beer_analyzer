//
//  LogoBubbleEffectView.swift
//  beer_analyzer
//
//  Created by Claude Code on 2025/06/11.
//

import SwiftUI

struct LogoBubbleEffectView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var logoBubbles: [LogoBubbleData] = []
    
    let logoPosition: CGPoint
    let logoSize: CGSize
    let bubbleCount: Int
    let isEnhanced: Bool
    
    init(logoPosition: CGPoint, logoSize: CGSize, bubbleCount: Int = 20, isEnhanced: Bool = false) {
        self.logoPosition = logoPosition
        self.logoSize = logoSize
        self.bubbleCount = bubbleCount
        self.isEnhanced = isEnhanced
    }
    
    var body: some View {
        ZStack {
            // ロゴ周辺の特別なバブル
            ForEach(logoBubbles) { bubble in
                LogoBubbleView(
                    size: bubble.size,
                    opacity: bubble.opacity,
                    color: bubble.color,
                    isEnhanced: isEnhanced
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
            generateLogoBubbles()
            animateLogoBubbles()
        }
    }
    
    // ロゴ周辺のバブル生成
    private func generateLogoBubbles() {
        let logoRadius = max(logoSize.width, logoSize.height) / 2 + 60
        
        logoBubbles = (0..<bubbleCount).map { i in
            // ロゴ周辺の円形エリアに配置
            let angle = CGFloat.random(in: 0...(2 * .pi))
            let radius = CGFloat.random(in: 30...logoRadius)
            let x = logoPosition.x + cos(angle) * radius
            let y = logoPosition.y + sin(angle) * radius
            
            return LogoBubbleData(
                position: CGPoint(x: x, y: y),
                size: CGFloat.random(in: isEnhanced ? 8...30 : 6...24),
                opacity: Double.random(in: isEnhanced ? 0.6...1.0 : 0.4...0.8),
                duration: Double.random(in: isEnhanced ? 3...6 : 4...8),
                color: randomLogoBubbleColor(),
                angle: angle,
                radius: radius,
                speed: CGFloat.random(in: isEnhanced ? 1.5...3.0 : 1.0...2.5)
            )
        }
    }
    
    // ロゴ周辺バブルのアニメーション
    private func animateLogoBubbles() {
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            for i in 0..<logoBubbles.count {
                // 円形軌道での回転
                logoBubbles[i].angle += logoBubbles[i].speed * 0.01
                
                // ゆっくりと上昇
                logoBubbles[i].position.y -= logoBubbles[i].speed * 0.3
                
                // 半径の微細な変化（呼吸するような効果）
                let breathingRadius = logoBubbles[i].radius + sin(logoBubbles[i].angle * 3) * 5
                
                // 新しい位置を計算
                logoBubbles[i].position.x = logoPosition.x + cos(logoBubbles[i].angle) * breathingRadius
                
                // ロゴ周辺エリアを超えたらリセット
                let maxRadius = max(logoSize.width, logoSize.height) / 2 + 80
                let distance = sqrt(
                    pow(logoBubbles[i].position.x - logoPosition.x, 2) +
                    pow(logoBubbles[i].position.y - logoPosition.y, 2)
                )
                
                if distance > maxRadius || logoBubbles[i].position.y < logoPosition.y - logoSize.height {
                    // バブルを下部からリセット
                    let newAngle = CGFloat.random(in: 0...(2 * .pi))
                    let newRadius = CGFloat.random(in: 30...maxRadius - 20)
                    
                    logoBubbles[i].position = CGPoint(
                        x: logoPosition.x + cos(newAngle) * newRadius,
                        y: logoPosition.y + logoSize.height / 2 + 30
                    )
                    logoBubbles[i].size = CGFloat.random(in: isEnhanced ? 8...30 : 6...24)
                    logoBubbles[i].opacity = Double.random(in: isEnhanced ? 0.6...1.0 : 0.4...0.8)
                    logoBubbles[i].color = randomLogoBubbleColor()
                    logoBubbles[i].angle = newAngle
                    logoBubbles[i].radius = newRadius
                    logoBubbles[i].speed = CGFloat.random(in: isEnhanced ? 1.5...3.0 : 1.0...2.5)
                }
            }
        }
    }
    
    // ロゴ周辺バブルの色（より鮮やかに）
    private func randomLogoBubbleColor() -> Color {
        if colorScheme == .dark {
            let colors: [Color] = [
                Color.white.opacity(0.9),
                Color(red: 1.0, green: 0.9, blue: 0.7).opacity(0.8), // 明るいゴールド
                Color(red: 0.9, green: 0.8, blue: 0.6).opacity(0.7), // アンバー
                Color(red: 1.0, green: 0.85, blue: 0.6).opacity(0.6), // 薄いゴールド
                Color.yellow.opacity(0.5) // 薄い黄色
            ]
            return colors.randomElement() ?? Color.white.opacity(0.9)
        } else {
            let colors: [Color] = [
                Color.white.opacity(1.0),
                Color(red: 1.0, green: 0.95, blue: 0.8).opacity(0.9), // クリーム
                Color(red: 0.95, green: 0.85, blue: 0.7).opacity(0.8), // ベージュ
                Color(red: 1.0, green: 0.85, blue: 0.6).opacity(0.7), // ゴールド
                Color.yellow.opacity(0.6) // 黄色
            ]
            return colors.randomElement() ?? Color.white.opacity(1.0)
        }
    }
}

// ロゴ専用バブルビュー
struct LogoBubbleView: View {
    let size: CGFloat
    let opacity: Double
    let color: Color
    let isEnhanced: Bool
    @State private var isPulsing = false
    @State private var isGlowing = false
    
    var body: some View {
        ZStack {
            // 外側のグロー効果
            if isEnhanced {
                Circle()
                    .fill(color)
                    .frame(width: size * 1.8, height: size * 1.8)
                    .opacity(isGlowing ? 0.3 : 0.1)
                    .blur(radius: 8)
                    .animation(
                        Animation.easeInOut(duration: Double.random(in: 1...2))
                            .repeatForever(autoreverses: true),
                        value: isGlowing
                    )
            }
            
            // メインのバブル
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            color,
                            color.opacity(0.8),
                            color.opacity(isEnhanced ? 0.5 : 0.3),
                            Color.clear
                        ],
                        center: .topLeading,
                        startRadius: size * 0.1,
                        endRadius: size * 0.9
                    )
                )
                .frame(width: size, height: size)
                .opacity(opacity)
                .scaleEffect(isPulsing ? (isEnhanced ? 1.3 : 1.2) : (isEnhanced ? 0.9 : 1.0))
                .animation(
                    Animation.easeInOut(duration: Double.random(in: isEnhanced ? 0.8...1.5 : 1.5...3))
                        .repeatForever(autoreverses: true),
                    value: isPulsing
                )
            
            // 光の反射ハイライト（拡張版）
            Circle()
                .fill(Color.white.opacity(isEnhanced ? 0.8 : 0.6))
                .frame(width: size * 0.4, height: size * 0.4)
                .offset(x: -size * 0.2, y: -size * 0.2)
                .blur(radius: isEnhanced ? 0.5 : 1)
            
            // 追加の光の輪（拡張版のみ）
            if isEnhanced {
                Circle()
                    .stroke(Color.white.opacity(0.5), lineWidth: 2)
                    .frame(width: size * 1.4, height: size * 1.4)
                    .scaleEffect(isPulsing ? 1.2 : 0.8)
                    .opacity(isPulsing ? 0.3 : 0.7)
                    .animation(
                        Animation.easeInOut(duration: Double.random(in: 1...2))
                            .repeatForever(autoreverses: true),
                        value: isPulsing
                    )
                
                // さらに外側の光の輪
                Circle()
                    .stroke(color.opacity(0.4), lineWidth: 1)
                    .frame(width: size * 1.8, height: size * 1.8)
                    .scaleEffect(isGlowing ? 1.1 : 0.9)
                    .opacity(isGlowing ? 0.2 : 0.4)
                    .animation(
                        Animation.easeInOut(duration: Double.random(in: 2...3))
                            .repeatForever(autoreverses: true),
                        value: isGlowing
                    )
            }
        }
        .shadow(
            color: color.opacity(isEnhanced ? 0.7 : 0.5), 
            radius: isEnhanced ? 8 : 5, 
            x: 0, 
            y: 0
        )
        .onAppear {
            isPulsing = true
            isGlowing = true
        }
    }
}

// ロゴバブルデータ構造
struct LogoBubbleData: Identifiable {
    let id = UUID()
    var position: CGPoint
    var size: CGFloat
    var opacity: Double
    var duration: Double
    var color: Color
    var angle: CGFloat
    var radius: CGFloat
    var speed: CGFloat
}

#Preview {
    LogoBubbleEffectView(
        logoPosition: CGPoint(x: 200, y: 300),
        logoSize: CGSize(width: 240, height: 135),
        bubbleCount: 20,
        isEnhanced: true
    )
}