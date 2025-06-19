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
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var firestoreService: FirestoreService
    
    init(beer: BeerRecord) {
        self._beer = State(initialValue: beer)
    }
    
    var body: some View {
        ScrollView {
                VStack(spacing: 24) {
                    // MARK: - カスタムヘッダー
                    HStack {
                        Button(NSLocalizedString("close", comment: "")) {
                            dismiss()
                        }
                        .font(.body)
                        .foregroundColor(.blue)
                        
                        Spacer()
                        
                        Text(beer.beerName)
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                            .lineLimit(1)
                        
                        Spacer()
                        
                        Button(NSLocalizedString("edit", comment: "")) {
                            isEditMode = true
                        }
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
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
                                Text(beer.hasDrunk ? NSLocalizedString("has_drunk", comment: "") : NSLocalizedString("not_drunk_yet", comment: ""))
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(beer.hasDrunk ? .green : .gray)
                                Spacer()
                                if !isUpdatingDrunkStatus {
                                    Text(NSLocalizedString("tap_to_toggle", comment: ""))
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
                            title: NSLocalizedString("beer_name", comment: ""),
                            value: beer.beerName,
                            isHighlighted: true
                        )
                        
                        // ブランド
                        DetailInfoCard(
                            icon: "🏷️",
                            title: NSLocalizedString("brand", comment: ""),
                            value: beer.brand
                        )
                        
                        // レーティング（レーティングが存在する場合のみ）
                        if let rating = beer.rating, rating > 0 {
                            RatingDisplayCard(rating: rating)
                        }
                        
                        // 製造者
                        DetailInfoCard(
                            icon: "🏭",
                            title: NSLocalizedString("manufacturer", comment: ""),
                            value: beer.manufacturer
                        )
                        
                        // アルコール度数
                        DetailInfoCard(
                            icon: "🌡️",
                            title: NSLocalizedString("abv", comment: ""),
                            value: beer.abv
                        )
                        
                        // 容量
                        DetailInfoCard(
                            icon: "📏",
                            title: NSLocalizedString("capacity", comment: ""),
                            value: beer.capacity
                        )
                        
                        // ホップ
                        DetailInfoCard(
                            icon: "🌿",
                            title: NSLocalizedString("hops", comment: ""),
                            value: beer.hops
                        )
                        
                        // 公式サイト（URLが存在する場合のみ）
                        if let websiteUrl = beer.websiteUrl, !websiteUrl.isEmpty {
                            DetailInfoCard(
                                icon: "🌐",
                                title: NSLocalizedString("official_website", comment: ""),
                                value: websiteUrl,
                                isURL: true
                            )
                        }
                        
                        // 記録日時
                        DetailInfoCard(
                            icon: "📅",
                            title: NSLocalizedString("recorded_date", comment: ""),
                            value: formatTimestamp(beer.timestamp)
                        )
                        
                        // メモ（メモが存在する場合のみ）
                        if let memo = beer.memo, !memo.isEmpty {
                            DetailInfoCard(
                                icon: "📝",
                                title: NSLocalizedString("memo", comment: ""),
                                value: memo
                            )
                        }
                    }
                    
                    Spacer(minLength: 20)
                }
                .padding()
            }
            .background(
                LinearGradient(
                    gradient: Gradient(colors: colorScheme == .dark ? [
                        Color(red: 0.2, green: 0.1, blue: 0.05), // ダークブラウン
                        Color(red: 0.15, green: 0.08, blue: 0.03), // より深いブラウン
                        Color(red: 0.1, green: 0.05, blue: 0.02), // ほぼ黒
                        Color.black.opacity(0.9)
                    ] : [
                        Color(red: 1.0, green: 0.75, blue: 0.3), // ゴールド
                        Color(red: 0.95, green: 0.65, blue: 0.2), // アンバー
                        Color(red: 0.9, green: 0.55, blue: 0.15), // より深いアンバー
                        Color(red: 0.85, green: 0.5, blue: 0.1).opacity(0.8) // 銅色がかったアンバー
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
        .sheet(isPresented: $isEditMode) {
            BeerEditView(beer: beer)
                .environmentObject(firestoreService)
        }
    }
    
    // MARK: - 日時フォーマット関数
    private func formatTimestamp(_ timestamp: Date) -> String {
        let formatter = DateFormatter()
        if Locale.current.language.languageCode?.identifier == "ja" {
            formatter.dateFormat = "yyyy年MM月dd日 HH:mm"
        } else {
            formatter.dateFormat = "MMM dd, yyyy HH:mm"
        }
        formatter.locale = Locale.current
        return formatter.string(from: timestamp)
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
                    websiteUrl: beer.websiteUrl,
                    memo: beer.memo,
                    rating: beer.rating
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

// MARK: - レーティング表示カードコンポーネント
struct RatingDisplayCard: View {
    let rating: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("⭐")
                    .font(.title2)
                Text(NSLocalizedString("rating", comment: ""))
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                Spacer()
                Text(String(format: "%.1f", rating))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.orange)
            }
            
            HStack(spacing: 4) {
                ForEach(1...5, id: \.self) { star in
                    Image(systemName: rating >= Double(star) ? "star.fill" : 
                          rating >= Double(star) - 0.5 ? "star.leadinghalf.filled" : "star")
                        .foregroundColor(.orange)
                        .font(.title3)
                }
                Spacer()
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
                    LinearGradient(colors: [Color.orange.opacity(0.3), Color.yellow.opacity(0.2)], startPoint: .leading, endPoint: .trailing),
                    lineWidth: 1
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
        websiteUrl: "https://www.sapporobeer.jp",
        memo: "とても美味しいビールでした！",
        rating: 4.5
    ))
    .environmentObject(FirestoreService())
}