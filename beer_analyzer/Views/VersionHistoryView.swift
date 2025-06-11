//
//  VersionHistoryView.swift
//  beer_analyzer
//
//  Created by Claude Code on 2025/06/11.
//

import SwiftUI

struct VersionHistoryView: View {
    @Environment(\.dismiss) private var dismiss
    
    private let versionHistory = [
        VersionInfo(
            version: "1.0.0",
            date: "2025年6月11日",
            changes: [
                "🎉 Beer Analyzerの初回リリース",
                "🤖 Google Gemini AIによるビール画像解析機能",
                "📋 ビール情報の詳細表示（銘柄、製造者、ABV、ホップなど）",
                "💾 ビール記録の保存・管理機能",
                "🔄 記録リストの無限スクロール対応",
                "📅 タイムスタンプによるソート機能",
                "🍺 飲酒ステータスの記録機能",
                "🌐 公式サイトリンクの表示・アプリ内ブラウザ対応",
                "🔗 URLの自動抽出機能",
                "🚀 アニメーション付きローディング画面",
                "📜 利用規約の実装",
                "⚙️ 設定画面とハンバーガーメニュー",
                "✉️ お問い合わせ機能"
            ]
        )
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // ヘッダー
                    VStack(spacing: 12) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 50))
                            .foregroundColor(.blue)
                        
                        Text("バージョン更新履歴")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Beer Analyzerの進化の軌跡")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)
                    
                    // バージョン履歴リスト
                    LazyVStack(spacing: 16) {
                        ForEach(versionHistory, id: \.version) { version in
                            VersionCard(version: version)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // フッター
                    VStack(spacing: 8) {
                        Text("今後も機能改善を続けてまいります")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Text("ご要望やバグ報告は設定の「お問い合わせ」からお送りください")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("更新履歴")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
}

struct VersionCard: View {
    let version: VersionInfo
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // バージョン情報ヘッダー
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Version \(version.version)")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    
                    Text(version.date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "star.fill")
                    .font(.title2)
                    .foregroundColor(.yellow)
            }
            
            // 更新内容
            VStack(alignment: .leading, spacing: 8) {
                Text("更新内容")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                ForEach(version.changes, id: \.self) { change in
                    HStack(alignment: .top, spacing: 8) {
                        Text("•")
                            .foregroundColor(.blue)
                            .fontWeight(.bold)
                        
                        Text(change)
                            .font(.body)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.regularMaterial)
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
    }
}

struct VersionInfo {
    let version: String
    let date: String
    let changes: [String]
}

#Preview {
    VersionHistoryView()
}