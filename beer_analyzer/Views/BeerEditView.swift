//
//  BeerEditView.swift
//  beer_analyzer
//
//  Created by 宮田聖也 on 2025/06/09.
//

import SwiftUI
import Kingfisher // 画像表示のため

struct BeerEditView: View {
    // 編集対象のビールレコード
    let originalBeer: BeerRecord // 元のレコード
    
    // 編集可能なフィールドを保持する @State 変数
    @State private var beerName: String
    @State private var brand: String
    @State private var manufacturer: String
    @State private var abv: String
    @State private var capacity: String
    @State private var hops: String
    @State private var hasDrunk: Bool
    @State private var websiteUrl: String
    @State private var memo: String
    @State private var rating: Double
    
    // サービスへのアクセス
    @EnvironmentObject var firestoreService: FirestoreService
    // ビューを閉じるための環境変数
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    @State private var isLoadingSave: Bool = false
    @State private var errorMessage: String?
    @State private var showingSaveSuccessAlert: Bool = false

    // ビューが表示されたときに初期値を設定
    init(beer: BeerRecord) {
        self.originalBeer = beer
        // @State プロパティは init 内でアンダースコア(_)を付けて初期化
        _beerName = State(initialValue: beer.beerName)
        _brand = State(initialValue: beer.brand)
        _manufacturer = State(initialValue: beer.manufacturer)
        _abv = State(initialValue: beer.abv)
        _capacity = State(initialValue: beer.capacity)
        _hops = State(initialValue: beer.hops)
        _hasDrunk = State(initialValue: beer.hasDrunk)
        _websiteUrl = State(initialValue: beer.websiteUrl ?? "")
        _memo = State(initialValue: beer.memo ?? "")
        _rating = State(initialValue: beer.rating ?? 0.0)
    }

    var body: some View {
        NavigationView { // このビュー自体をNavigationStackまたはNavigationViewでラップする
            ScrollView {
                VStack(spacing: 20) {

                    // MARK: - 画像プレビュー
                    if let imageUrlString = originalBeer.imageUrl, let imageUrl = URL(string: imageUrlString) {
                        KFImage(imageUrl)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 150, height: 150)
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                            .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color.gray.opacity(0.3), lineWidth: 1))
                            .shadow(radius: 5)
                    } else {
                        Image(systemName: "photo.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 150, height: 150)
                            .foregroundColor(.gray)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(15)
                    }

                    // MARK: - 編集フォーム
                    Group {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(String(format: NSLocalizedString("beer_name_label", comment: ""), originalBeer.beerName))
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.horizontal)
                            TextField(NSLocalizedString("beer_name_placeholder", comment: ""), text: $beerName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(.horizontal)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(String(format: NSLocalizedString("brand_label", comment: ""), originalBeer.brand))
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.horizontal)
                            TextField(NSLocalizedString("brand_placeholder", comment: ""), text: $brand)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(.horizontal)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(String(format: NSLocalizedString("manufacturer_label", comment: ""), originalBeer.manufacturer))
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.horizontal)
                            TextField(NSLocalizedString("manufacturer_placeholder", comment: ""), text: $manufacturer)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(.horizontal)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(String(format: NSLocalizedString("abv_label", comment: ""), originalBeer.abv))
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.horizontal)
                            TextField(NSLocalizedString("abv_placeholder", comment: ""), text: $abv)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(.horizontal)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(String(format: NSLocalizedString("capacity_label", comment: ""), originalBeer.capacity))
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.horizontal)
                            TextField(NSLocalizedString("capacity_placeholder", comment: ""), text: $capacity)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(.horizontal)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(String(format: NSLocalizedString("hops_label", comment: ""), originalBeer.hops))
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.horizontal)
                            TextField(NSLocalizedString("hops_placeholder", comment: ""), text: $hops)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(.horizontal)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(String(format: NSLocalizedString("website_url_label", comment: ""), originalBeer.websiteUrl ?? NSLocalizedString("not_set", comment: "")))
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.horizontal)
                            TextField(NSLocalizedString("website_url_placeholder", comment: ""), text: $websiteUrl)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.URL)
                                .autocapitalization(.none)
                                .padding(.horizontal)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(String(format: NSLocalizedString("memo_label", comment: ""), originalBeer.memo ?? NSLocalizedString("not_set", comment: "")))
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.horizontal)
                            TextField(NSLocalizedString("memo_placeholder", comment: ""), text: $memo, axis: .vertical)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .lineLimit(3...6)
                                .padding(.horizontal)
                        }
                    }
                    .autocorrectionDisabled() // 自動修正を無効にする（ビール名などに不要な場合）
                    .textInputAutocapitalization(.never) // 自動大文字化を無効にする
                    
                    // MARK: - レーティングスライダー
                    VStack(alignment: .leading, spacing: 8) {
                        Text(String(format: NSLocalizedString("rating_label", comment: ""), originalBeer.rating != nil ? String(format: "%.1f", originalBeer.rating!) : NSLocalizedString("not_set", comment: "")))
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                        
                        RatingSlider(rating: $rating)
                            .padding(.horizontal)
                    }

                    // MARK: - 飲んだかどうかのトグル
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(NSLocalizedString("drunk_status_label", comment: ""))
                                .font(.headline)
                                .fontWeight(.semibold)
                            Spacer()
                            Toggle("", isOn: $hasDrunk)
                                .toggleStyle(SwitchToggleStyle())
                        }
                        .padding(.horizontal)
                        
                        if hasDrunk {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text(NSLocalizedString("has_drunk", comment: ""))
                                    .font(.subheadline)
                                    .foregroundColor(.green)
                                Spacer()
                            }
                            .padding(.horizontal)
                        } else {
                            HStack {
                                Image(systemName: "circle")
                                    .foregroundColor(.gray)
                                Text(NSLocalizedString("not_drunk_yet", comment: ""))
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                Spacer()
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical, 8)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal)

                    // MARK: - 保存ボタン
                    Button {
                        saveChanges()
                    } label: {
                        HStack {
                            if isLoadingSave {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(1.0)
                            }
                            Text(isLoadingSave ? NSLocalizedString("saving", comment: "") : NSLocalizedString("save_changes", comment: ""))
                                .font(.headline)
                                .fontWeight(.bold)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(isLoadingSave ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(15)
                    }
                    .disabled(isLoadingSave)
                    .padding(.horizontal)

                    if let error = errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(10)
                    }
                }
                .padding()
                .background(.regularMaterial)
                .cornerRadius(20)
                .shadow(radius: 5)
                .padding(.vertical)
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
            .navigationTitle(NSLocalizedString("edit_beer", comment: "")) // ナビゲーションバーのタイトル
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(NSLocalizedString("cancel", comment: "")) {
                        dismiss()
                    }
                }
            }
            .alert(NSLocalizedString("save_success", comment: ""), isPresented: $showingSaveSuccessAlert) {
                Button(NSLocalizedString("ok", comment: "")) {
                    dismiss() // 保存成功後、ビューを閉じる
                }
            } message: {
                Text(NSLocalizedString("save_success_message", comment: ""))
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    // MARK: - 変更を保存するロジック
    private func saveChanges() {
        guard let beerId = originalBeer.id else {
            errorMessage = NSLocalizedString("beer_id_not_found", comment: "")
            return
        }

        isLoadingSave = true
        errorMessage = nil

        Task {
            do {
                // 更新された情報を元に新しい BeerRecord インスタンスを作成
                let updatedBeer = BeerRecord(
                    analysisResult: BeerAnalysisResult(
                        beerName: beerName,
                        brand: brand,
                        manufacturer: manufacturer,
                        abv: abv,
                        capacity: capacity,
                        hops: hops,
                        isNotBeer: originalBeer.isNotBeer,
                        websiteUrl: websiteUrl.isEmpty ? nil : websiteUrl
                    ),
                    userId: originalBeer.userId, // UserIDは元のまま
                    timestamp: originalBeer.timestamp, // タイムスタンプは元のまま
                    imageUrl: originalBeer.imageUrl ?? "",
                    hasDrunk: hasDrunk, // 飲んだかどうかの状態を反映
                    websiteUrl: websiteUrl.isEmpty ? nil : websiteUrl, // 空文字の場合はnilに変換
                    memo: memo.isEmpty ? nil : memo, // 空文字の場合はnilに変換
                    rating: rating > 0 ? rating : nil // 0より大きい場合のみ保存
                )
                
                try await firestoreService.updateBeer(documentId: originalBeer.id ?? "", beer: updatedBeer)
                
                DispatchQueue.main.async {
                    self.showingSaveSuccessAlert = true // 成功アラートを表示
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = String(format: NSLocalizedString("save_failed", comment: ""), error.localizedDescription)
                    print("Error saving beer changes: \(error.localizedDescription)")
                }
            }
            DispatchQueue.main.async
            {
                self.isLoadingSave = false
            }
        }
    }
}
