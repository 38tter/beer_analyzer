//
//  BeerDetailView.swift
//  beer_analyzer
//
//  Created by Claude Code on 2025/06/11.
//

import SwiftUI
import Kingfisher

struct BeerDetailView: View {
    @State private var beer: BeerRecord
    @State private var isEditMode: Bool = false
    @State private var isUpdatingDrunkStatus: Bool = false
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var firestoreService: FirestoreService
    
    init(beer: BeerRecord) {
        self._beer = State(initialValue: beer)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // MARK: - ビール画像
                    VStack(spacing: 16) {
                        if let imageUrlString = beer.imageUrl, let imageUrl = URL(string: imageUrlString) {
                            KFImage(imageUrl)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 250, height: 250)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.gray.opacity(0.3), lineWidth: 1))
                                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                        } else {
                            Image(systemName: "photo.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 250, height: 250)
                                .foregroundColor(.gray)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(20)
                        }
                        
                        // 飲んだかどうかのステータス（タップで切り替え可能）
                        Button {
                            toggleDrunkStatus()
                        } label: {
                            HStack {
                                if isUpdatingDrunkStatus {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                        .foregroundColor(beer.hasDrunk ? .green : .gray)
                                } else {
                                    Image(systemName: beer.hasDrunk ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(beer.hasDrunk ? .green : .gray)
                                        .font(.title2)
                                }
                                Text(beer.hasDrunk ? "飲みました！🍺" : "まだ飲んでいません")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(beer.hasDrunk ? .green : .gray)
                                Spacer()
                                if !isUpdatingDrunkStatus {
                                    Text("タップして切り替え")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .disabled(isUpdatingDrunkStatus)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(beer.hasDrunk ? Color.green.opacity(0.1) : Color.gray.opacity(0.1))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(beer.hasDrunk ? Color.green.opacity(0.3) : Color.gray.opacity(0.3), lineWidth: 1)
                        )
                    }
                    
                    // MARK: - ビール情報詳細
                    VStack(spacing: 16) {
                        // ビール名
                        DetailInfoCard(
                            icon: "🍺",
                            title: "銘柄",
                            value: beer.beerName,
                            isHighlighted: true
                        )
                        
                        // ブランド
                        DetailInfoCard(
                            icon: "🏷️",
                            title: "ブランド",
                            value: beer.brand
                        )
                        
                        // 製造者
                        DetailInfoCard(
                            icon: "🏭",
                            title: "製造者",
                            value: beer.manufacturer
                        )
                        
                        // アルコール度数
                        DetailInfoCard(
                            icon: "🌡️",
                            title: "アルコール度数",
                            value: beer.abv
                        )
                        
                        // 容量
                        DetailInfoCard(
                            icon: "📏",
                            title: "容量",
                            value: beer.capacity
                        )
                        
                        // ホップ
                        DetailInfoCard(
                            icon: "🌿",
                            title: "ホップ",
                            value: beer.hops
                        )
                        
                        // 公式サイト（URLが存在する場合のみ）
                        if let websiteUrl = beer.websiteUrl, !websiteUrl.isEmpty {
                            DetailInfoCard(
                                icon: "🌐",
                                title: "公式サイト",
                                value: websiteUrl,
                                isURL: true
                            )
                        }
                        
                        // 記録日時
                        DetailInfoCard(
                            icon: "📅",
                            title: "記録日時",
                            value: beer.timestamp.formatted(date: .abbreviated, time: .shortened)
                        )
                    }
                    
                    Spacer(minLength: 20)
                }
                .padding()
            }
            .background(BeerGradientBackgroundView())
            .navigationTitle(beer.beerName)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("閉じる") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("編集") {
                        isEditMode = true
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .sheet(isPresented: $isEditMode) {
            BeerEditView(beer: beer)
                .environmentObject(firestoreService)
        }
    }
    
    // MARK: - 飲んだかどうかのステータスを切り替える
    private func toggleDrunkStatus() {
        guard let beerId = beer.id else { return }
        
        isUpdatingDrunkStatus = true
        let newStatus = !beer.hasDrunk
        
        Task {
            do {
                // 更新されたビールレコードを作成
                let updatedBeer = BeerRecord(
                    analysisResult: BeerAnalysisResult(
                        beerName: beer.beerName,
                        brand: beer.brand,
                        manufacturer: beer.manufacturer,
                        abv: beer.abv,
                        capacity: beer.capacity,
                        hops: beer.hops,
                        isNotBeer: beer.isNotBeer,
                        websiteUrl: beer.websiteUrl
                    ),
                    userId: beer.userId,
                    timestamp: beer.timestamp,
                    imageUrl: beer.imageUrl ?? "",
                    hasDrunk: newStatus,
                    websiteUrl: beer.websiteUrl
                )
                
                try await firestoreService.updateBeer(documentId: beerId, beer: updatedBeer)
                
                DispatchQueue.main.async {
                    self.beer = updatedBeer
                    self.isUpdatingDrunkStatus = false
                }
            } catch {
                DispatchQueue.main.async {
                    print("Error updating drunk status: \(error.localizedDescription)")
                    self.isUpdatingDrunkStatus = false
                }
            }
        }
    }
}

// MARK: - 詳細情報カードコンポーネント
struct DetailInfoCard: View {
    let icon: String
    let title: String
    let value: String
    let isHighlighted: Bool
    let isURL: Bool
    
    init(icon: String, title: String, value: String, isHighlighted: Bool = false, isURL: Bool = false) {
        self.icon = icon
        self.title = title
        self.value = value
        self.isHighlighted = isHighlighted
        self.isURL = isURL
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(icon)
                    .font(.title2)
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                Spacer()
            }
            
            if isURL {
                if let url = URL(string: value) {
                    Link(destination: url) {
                        HStack {
                            Text(value)
                                .font(isHighlighted ? .title3 : .body)
                                .fontWeight(isHighlighted ? .bold : .medium)
                                .foregroundColor(.blue)
                                .multilineTextAlignment(.leading)
                            Image(systemName: "arrow.up.right.square")
                                .foregroundColor(.blue)
                                .font(.caption)
                        }
                    }
                } else {
                    Text(value)
                        .font(isHighlighted ? .title3 : .body)
                        .fontWeight(isHighlighted ? .bold : .medium)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                }
            } else {
                Text(value)
                    .font(isHighlighted ? .title3 : .body)
                    .fontWeight(isHighlighted ? .bold : .medium)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.regularMaterial)
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    isHighlighted ? 
                    LinearGradient(colors: [Color(red: 1.0, green: 0.75, blue: 0.3), Color(red: 0.85, green: 0.5, blue: 0.1)], startPoint: .leading, endPoint: .trailing) :
                    LinearGradient(colors: [Color.clear], startPoint: .leading, endPoint: .trailing),
                    lineWidth: isHighlighted ? 2 : 0
                )
        )
    }
}

#Preview {
    BeerDetailView(beer: BeerRecord(
        analysisResult: BeerAnalysisResult(
            beerName: "サッポロ黒ラベル",
            brand: "サッポロビール",
            manufacturer: "サッポロビール株式会社",
            abv: "5.0%",
            capacity: "350ml",
            hops: "ホップ",
            isNotBeer: false,
            websiteUrl: "https://www.sapporobeer.jp"
        ),
        userId: "test-user",
        timestamp: Date(),
        imageUrl: "",
        hasDrunk: true,
        websiteUrl: "https://www.sapporobeer.jp"
    ))
    .environmentObject(FirestoreService())
}