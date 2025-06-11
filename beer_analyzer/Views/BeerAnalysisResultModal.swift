//
//  BeerAnalysisResultModal.swift
//  beer_analyzer
//
//  Created by Claude Code on 2025/06/11.
//

import SwiftUI
import Kingfisher

struct BeerAnalysisResultModal: View {
    let analysisResult: BeerAnalysisResult
    let beerImage: UIImage?
    let onDismiss: () -> Void
    let onGeneratePairing: (@escaping (String?) -> Void) -> Void
    
    @State private var pairingSuggestion: String?
    @State private var isLoadingPairing = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // 成功メッセージ
                    VStack(spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.green)
                        
                        Text("🎉 解析完了！")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.green, .blue],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        
                        Text("ビール情報の解析が完了しました")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)
                    
                    // ビール画像
                    if let beerImage = beerImage {
                        Image(uiImage: beerImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 200, height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                    }
                    
                    // 解析結果
                    VStack(spacing: 16) {
                        Text("解析結果")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        VStack(spacing: 12) {
                            ResultRow(icon: "🍺", title: "銘柄", value: analysisResult.beerName)
                            ResultRow(icon: "🏷️", title: "ブランド", value: analysisResult.brand)
                            ResultRow(icon: "🏭", title: "製造者", value: analysisResult.manufacturer)
                            ResultRow(icon: "🌡️", title: "アルコール度数", value: analysisResult.abv)
                            ResultRow(icon: "🥂", title: "容量", value: analysisResult.capacity)
                            ResultRow(icon: "🌿", title: "ホップ", value: analysisResult.hops)
                            
                            if let websiteUrl = analysisResult.websiteUrl, !websiteUrl.isEmpty {
                                ResultRow(icon: "🌐", title: "公式サイト", value: "リンクあり")
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.regularMaterial)
                            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                    )
                    
                    // ペアリング提案ボタン
//                    if pairingSuggestion == nil {
//                        Button {
//                            generatePairingSuggestion()
//                        } label: {
//                            HStack {
//                                if isLoadingPairing {
//                                    ProgressView()
//                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
//                                        .scaleEffect(0.8)
//                                }
//                                Text(isLoadingPairing ? "提案を生成中..." : "🍽️ ペアリング提案を見る")
//                                    .font(.headline)
//                                    .fontWeight(.semibold)
//                            }
//                            .padding()
//                            .frame(maxWidth: .infinity)
//                            .background(Color.orange)
//                            .foregroundColor(.white)
//                            .cornerRadius(12)
//                        }
//                        .disabled(isLoadingPairing)
//                        .padding(.horizontal)
//                    }
//                    
//                    // ペアリング提案結果
//                    if let pairingSuggestion = pairingSuggestion {
//                        VStack(spacing: 12) {
//                            Text("🍽️ ペアリング提案")
//                                .font(.title3)
//                                .fontWeight(.bold)
//                                .foregroundColor(.orange)
//                            
//                            Text(pairingSuggestion)
//                                .font(.body)
//                                .foregroundColor(.primary)
//                                .multilineTextAlignment(.leading)
//                                .padding()
//                                .background(
//                                    RoundedRectangle(cornerRadius: 12)
//                                        .fill(.thinMaterial)
//                                )
//                        }
//                        .padding(.horizontal)
//                    }
                    
                    // 保存通知
                    VStack(spacing: 8) {
                        HStack {
                            Image(systemName: "checkmark.circle")
                                .foregroundColor(.green)
                            Text("自動保存完了")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.green)
                        }
                        
                        Text("この解析結果は「記録されたビール」タブに保存されました")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.green.opacity(0.1))
                            .stroke(Color.green.opacity(0.3), lineWidth: 1)
                    )
                    .padding(.horizontal)
                    
                    // 閉じるボタン
                    Button {
                        onDismiss()
                    } label: {
                        Text("結果を確認しました")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("解析結果")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        onDismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
    
    private func generatePairingSuggestion() {
        isLoadingPairing = true
        onGeneratePairing { suggestion in
            DispatchQueue.main.async {
                self.isLoadingPairing = false
                self.pairingSuggestion = suggestion
            }
        }
    }
}

struct ResultRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(icon)
                .font(.title3)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fontWeight(.medium)
                
                Text(value)
                    .font(.body)
                    .foregroundColor(.primary)
                    .fontWeight(.semibold)
            }
            
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.ultraThinMaterial)
        )
    }
}

#Preview {
    BeerAnalysisResultModal(
        analysisResult: BeerAnalysisResult(
            beerName: "サッポロ黒ラベル",
            brand: "サッポロビール",
            manufacturer: "サッポロビール株式会社",
            abv: "5.0%",
            capacity: "350ml",
            hops: "ファインアロマホップ",
            isNotBeer: false,
            websiteUrl: "https://www.sapporobeer.jp"
        ),
        beerImage: nil,
        onDismiss: {},
        onGeneratePairing: { _ in }
    )
}
