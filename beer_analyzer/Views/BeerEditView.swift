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
    
    // サービスへのアクセス
    @EnvironmentObject var firestoreService: FirestoreService
    // ビューを閉じるための環境変数
    @Environment(\.dismiss) var dismiss
    
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
    }

    var body: some View {
        NavigationView { // このビュー自体をNavigationStackまたはNavigationViewでラップする
            ScrollView {
                VStack(spacing: 20) {
                    Text("ビール情報を編集")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.bottom, 10)

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
                        TextField("銘柄", text: $beerName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                        TextField("ブランド", text: $brand)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                        TextField("製造者", text: $manufacturer)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                        TextField("アルコール度数 (ABV)", text: $abv)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                        TextField("容量", text: $capacity)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                        TextField("ホップ", text: $hops)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                        TextField("公式サイトURL (任意)", text: $websiteUrl)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.URL)
                            .autocapitalization(.none)
                            .padding(.horizontal)
                    }
                    .autocorrectionDisabled() // 自動修正を無効にする（ビール名などに不要な場合）
                    .textInputAutocapitalization(.never) // 自動大文字化を無効にする

                    // MARK: - 飲んだかどうかのトグル
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("飲んだかどうか")
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
                                Text("飲みました！🍺")
                                    .font(.subheadline)
                                    .foregroundColor(.green)
                                Spacer()
                            }
                            .padding(.horizontal)
                        } else {
                            HStack {
                                Image(systemName: "circle")
                                    .foregroundColor(.gray)
                                Text("まだ飲んでいません")
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
                            Text(isLoadingSave ? "保存中..." : "変更を保存")
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
                .background(Color.white.opacity(0.8))
                .cornerRadius(20)
                .shadow(radius: 5)
                .padding(.vertical)
            }
            .navigationTitle("編集") // ナビゲーションバーのタイトル
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
            }
            .alert("保存完了", isPresented: $showingSaveSuccessAlert) {
                Button("OK") {
                    dismiss() // 保存成功後、ビューを閉じる
                }
            } message: {
                Text("ビール情報が正常に更新されました。")
            }
        }
    }

    // MARK: - 変更を保存するロジック
    private func saveChanges() {
        guard let beerId = originalBeer.id else {
            errorMessage = "ビールIDが見つかりません。"
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
                    websiteUrl: websiteUrl.isEmpty ? nil : websiteUrl // 空文字の場合はnilに変換
                )
                
                try await firestoreService.updateBeer(documentId: originalBeer.id ?? "", beer: updatedBeer)
                
                DispatchQueue.main.async {
                    self.showingSaveSuccessAlert = true // 成功アラートを表示
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "情報の保存に失敗しました: \(error.localizedDescription)"
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
