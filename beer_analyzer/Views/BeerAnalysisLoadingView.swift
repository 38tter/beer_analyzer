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
            // ブラー背景
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .background(.ultraThinMaterial)
            
            // メインコンテンツ
            VStack(spacing: 40) {
                
                // メインアニメーション
                VStack(spacing: 30) {
                    
                    // 多層プログレススピナー
                    ZStack {
                        // 外側のリング
                        Circle()
                            .stroke(Color.blue.opacity(0.2), lineWidth: 12)
                            .frame(width: 120, height: 120)
                        
                        Circle()
                            .trim(from: 0, to: 0.8)
                            .stroke(
                                LinearGradient(
                                    colors: [Color(red: 1.0, green: 0.75, blue: 0.3), Color(red: 0.95, green: 0.65, blue: 0.2), Color(red: 1.0, green: 0.75, blue: 0.3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                style: StrokeStyle(lineWidth: 12, lineCap: .round)
                            )
                            .frame(width: 120, height: 120)
                            .rotationEffect(.degrees(rotationAngle))
                            .animation(
                                Animation.linear(duration: 1.5)
                                    .repeatForever(autoreverses: false),
                                value: rotationAngle
                            )
                        
                        // 中間のリング
                        Circle()
                            .stroke(Color.indigo.opacity(0.3), lineWidth: 8)
                            .frame(width: 80, height: 80)
                        
                        Circle()
                            .trim(from: 0, to: 0.6)
                            .stroke(
                                LinearGradient(
                                    colors: [Color(red: 0.9, green: 0.55, blue: 0.15), Color(red: 0.85, green: 0.5, blue: 0.1), Color(red: 0.9, green: 0.55, blue: 0.15)],
                                    startPoint: .bottomTrailing,
                                    endPoint: .topLeading
                                ),
                                style: StrokeStyle(lineWidth: 8, lineCap: .round)
                            )
                            .frame(width: 80, height: 80)
                            .rotationEffect(.degrees(-rotationAngle * 1.2))
                            .animation(
                                Animation.linear(duration: 2.0)
                                    .repeatForever(autoreverses: false),
                                value: rotationAngle
                            )
                        
                        // 内側のリング
                        Circle()
                            .stroke(Color.purple.opacity(0.4), lineWidth: 6)
                            .frame(width: 40, height: 40)
                        
                        Circle()
                            .trim(from: 0, to: 0.4)
                            .stroke(
                                LinearGradient(
                                    colors: [Color(red: 0.85, green: 0.5, blue: 0.1), Color(red: 0.8, green: 0.45, blue: 0.05), Color(red: 0.85, green: 0.5, blue: 0.1)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                style: StrokeStyle(lineWidth: 6, lineCap: .round)
                            )
                            .frame(width: 40, height: 40)
                            .rotationEffect(.degrees(rotationAngle * 1.5))
                            .animation(
                                Animation.linear(duration: 1.0)
                                    .repeatForever(autoreverses: false),
                                value: rotationAngle
                            )
                    }
                }
                
                // 動的メッセージ
                VStack(spacing: 16) {
                    Text(analysisMessages[currentMessageIndex])
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.ultraThinMaterial)
                                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                        )
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
