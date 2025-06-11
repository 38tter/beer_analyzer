//
//  BeerGradientBackgroundView.swift
//  beer_analyzer
//
//  Created by Claude Code on 2025/06/11.
//

import SwiftUI

struct BeerGradientBackgroundView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        if colorScheme == .dark {
            // ダークモード: 黒ビールのようなブラウンからダークへ
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.2, green: 0.1, blue: 0.05), // ダークブラウン
                    Color(red: 0.15, green: 0.08, blue: 0.03), // より深いブラウン
                    Color(red: 0.1, green: 0.05, blue: 0.02), // ほぼ黒
                    Color.black.opacity(0.9)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        } else {
            // ライトモード: ビールのようなアンバーからゴールドへ
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 1.0, green: 0.75, blue: 0.3), // ゴールド
                    Color(red: 0.95, green: 0.65, blue: 0.2), // アンバー
                    Color(red: 0.9, green: 0.55, blue: 0.15), // より深いアンバー
                    Color(red: 0.85, green: 0.5, blue: 0.1).opacity(0.8) // 銅色がかったアンバー
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        }
    }
}

#Preview {
    BeerGradientBackgroundView()
}