
//
//  AnalysisResultView.swift
//  beer_analyzer
//

import SwiftUI

struct AnalysisResultView: View {
    let analysisResult: BeerAnalysisResult
    let isLoadingPairing: Bool
    let onGeneratePairing: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("解析結果")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.bottom, 5)

            InfoRow(label: "銘柄", value: analysisResult.brand)
            InfoRow(label: "製造者", value: analysisResult.manufacturer)
            InfoRow(label: "ABV", value: analysisResult.abv)
            InfoRow(label: "ホップ", value: analysisResult.hops)

            // MARK: - ペアリング提案ボタン
            Button {
                onGeneratePairing()
            } label: {
                HStack {
                    if isLoadingPairing {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.0)
                    }
                    Text(isLoadingPairing ? "提案生成中..." : "ペアリングを提案 ✨")
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(isLoadingPairing ? Color.gray : Color.purple)
                .foregroundColor(.white)
                .cornerRadius(15)
            }
            .disabled(isLoadingPairing)
            .padding(.top, 10)
        }
        .padding()
        .background(Color.white.opacity(0.8))
        .cornerRadius(20)
        .shadow(radius: 5)
    }
}
