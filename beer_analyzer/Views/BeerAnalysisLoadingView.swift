//
//  BeerAnalysisLoadingView.swift
//  beer_analyzer
//
//  Created by Claude Code on 2025/06/11.
//

import SwiftUI

struct BeerAnalysisLoadingView: View {
    @State private var rotationAngle: Double = 0
    @State private var scale: CGFloat = 1.0
    @State private var opacity: Double = 0.3
    @State private var currentMessageIndex = 0
    
    private let analysisMessages = [
        "🔍 ビールの画像を解析しています...",
        "🤖 AIがビールの種類を判別中...",
        "📋 銘柄情報を検索しています...",
        "🌡️ アルコール度数を分析中...",
        "🌿 ホップの特徴を調べています...",
        "🏭 製造者情報を取得中...",
        "✨ 詳細な解析結果を準備中...",
        "🎯 もう少しお待ちください..."
    ]
    
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
            
            VStack(spacing: 40) {
                // タイトル
                VStack(spacing: 16) {
                    Text("🍺 ビール解析中 🍺")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .indigo],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    Text("AIがあなたのビールを詳しく分析しています")
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                // メインアニメーション
                VStack(spacing: 30) {
                    // 回転するビール絵文字
                    ZStack {
                        // 背景円
                        Circle()
                            .fill(Color.blue.opacity(0.1))
                            .frame(width: 150, height: 150)
                            .scaleEffect(scale)
                            .opacity(opacity)
                            .animation(
                                Animation.easeInOut(duration: 2.0)
                                    .repeatForever(autoreverses: true),
                                value: scale
                            )
                        
                        // 回転するビール絵文字
                        Text("🍺")
                            .font(.system(size: 80))
                            .rotationEffect(.degrees(rotationAngle))
                            .animation(
                                Animation.linear(duration: 3.0)
                                    .repeatForever(autoreverses: false),
                                value: rotationAngle
                            )
                    }
                    
                    // プログレスリング
                    ZStack {
                        Circle()
                            .stroke(Color.blue.opacity(0.3), lineWidth: 8)
                            .frame(width: 60, height: 60)
                        
                        Circle()
                            .trim(from: 0, to: 0.7)
                            .stroke(
                                LinearGradient(
                                    colors: [.blue, .indigo, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                style: StrokeStyle(lineWidth: 8, lineCap: .round)
                            )
                            .frame(width: 60, height: 60)
                            .rotationEffect(.degrees(rotationAngle))
                            .animation(
                                Animation.linear(duration: 2.0)
                                    .repeatForever(autoreverses: false),
                                value: rotationAngle
                            )
                    }
                }
                
                // 動的メッセージ
                VStack(spacing: 16) {
                    Text(analysisMessages[currentMessageIndex])
                        .font(.headline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .animation(.easeInOut(duration: 0.5), value: currentMessageIndex)
                    
                    // ドット アニメーション
                    HStack(spacing: 8) {
                        ForEach(0..<3) { index in
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 8, height: 8)
                                .scaleEffect(scale)
                                .opacity(opacity)
                                .animation(
                                    Animation.easeInOut(duration: 0.6)
                                        .repeatForever(autoreverses: true)
                                        .delay(Double(index) * 0.2),
                                    value: scale
                                )
                        }
                    }
                }
                
                // 励ましメッセージ
                VStack(spacing: 12) {
                    Text("✨ 高精度なAI解析を実行中 ✨")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                    
                    Text("ビールの詳細情報とペアリング提案をお楽しみに！")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    // 期待感を醸成するメッセージ
                    VStack(spacing: 6) {
                        Text("🍻 間もなく判明します...")
                            .font(.caption)
                            .foregroundColor(.blue)
                            .fontWeight(.medium)
                        
                        HStack(spacing: 4) {
                            Text("• 銘柄名")
                            Text("• 製造者")
                            Text("• ABV")
                            Text("• ホップ")
                        }
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    }
                    .padding(.top, 8)
                }
                .padding(.horizontal)
            }
            .padding()
        }
        .onAppear {
            startAnimations()
            startMessageRotation()
        }
    }
    
    private func startAnimations() {
        // 回転アニメーション開始
        rotationAngle = 360
        
        // スケール＆透明度アニメーション開始
        scale = 1.2
        opacity = 0.8
    }
    
    private func startMessageRotation() {
        Timer.scheduledTimer(withTimeInterval: 2.5, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.8)) {
                currentMessageIndex = (currentMessageIndex + 1) % analysisMessages.count
            }
        }
    }
}

#Preview {
    BeerAnalysisLoadingView()
}