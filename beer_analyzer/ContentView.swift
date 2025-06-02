//
//  ContentView.swift
//  beer_analyzer
//
//  Created by 宮田聖也 on 2025/06/02.
//

import SwiftUI
import PhotosUI // PhotosPickerを使用するために必要
import FirebaseRemoteConfig
import Kingfisher

struct ContentView: View {
    @State private var selectedImage: PhotosPickerItem? // iOS 16+ の PhotosPicker 用
    @State private var uiImage: UIImage? // 選択または撮影した画像を保持
    @State private var analysisResult: BeerAnalysisResult?
    @State private var pairingSuggestion: String?
    @State private var errorMessage: String?
    @State private var isLoadingAnalysis = false
    @State private var isLoadingPairing = false
    @State private var recordedBeers: [BeerRecord] = []

    @StateObject private var geminiService = GeminiAPIService() // APIサービス
    @StateObject private var firestoreService = FirestoreService() // Firestoreサービス

    // Firebase認証とFirestoreリスナーの設定
    // 初期化はAppDelegateで行い、ユーザーIDの取得とFirestoreの購読をここで行う
    @State private var userId: String?

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // MARK: - タイトルロゴ画像を追加
                    Image("AppTitleLogo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 320, height: 180)
                        .padding(.bottom, 10)

                    Text("ユーザーID: \(userId ?? "認証中...")")
                        .font(.caption)
                        .foregroundColor(.gray)

                    // MARK: - 画像選択/撮影
                    VStack(alignment: .leading) {
                        Text("ビールの写真をアップロードまたは撮影")
                            .font(.headline)

                        // iOS 16+ の PhotosPicker
                        PhotosPicker(selection: $selectedImage, matching: .images) {
                            Label("写真を選択", systemImage: "photo")
                                .font(.title3)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue.opacity(0.8))
                                .foregroundColor(.white)
                                .cornerRadius(15)
                        }
                        .onChange(of: selectedImage) { newItem in
                            Task {
                                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                    if let image = UIImage(data: data) {
                                        uiImage = image
                                        analysisResult = nil // 新しい画像で結果をリセット
                                        pairingSuggestion = nil // ペアリングもリセット
                                        errorMessage = nil
                                    }
                                }
                            }
                        }

                        // カメラからの撮影 (簡略化: 実際にはAVFoundationでカメラビューを実装)
                        Button {
                            // TODO: ここにカメラ起動ロジックを追加
                            // UIImagePickerControllerRepresentable を使用するか、AVFoundation でカスタムカメラビューを実装
                            errorMessage = "カメラ機能は現在デモ版では未実装です。写真を選択してください。"
                        } label: {
                            Label("カメラで撮影", systemImage: "camera")
                                .font(.title3)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.green.opacity(0.8))
                                .foregroundColor(.white)
                                .cornerRadius(15)
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(20)
                    .shadow(radius: 5)


                    // MARK: - 画像プレビュー
                    if let uiImage = uiImage {
                        VStack {
                            Text("プレビュー")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .padding(.bottom, 5)
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxHeight: 300)
                                .cornerRadius(10)
                                .shadow(radius: 3)
                        }
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(20)
                        .shadow(radius: 5)
                    }

                    // MARK: - ビール解析ボタン
                    Button {
                        analyzeBeer()
                    } label: {
                        HStack {
                            if isLoadingAnalysis {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(1.2)
                            }
                            Text(isLoadingAnalysis ? "解析中..." : "ビールを解析")
                                .font(.title3)
                                .fontWeight(.semibold)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(isLoadingAnalysis || uiImage == nil ? Color.gray : Color.indigo)
                        .foregroundColor(.white)
                        .cornerRadius(15)
                    }
                    .disabled(isLoadingAnalysis || uiImage == nil)
                    .padding(.horizontal)

                    // MARK: - エラーメッセージ
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(10)
                    }

                    // MARK: - 解析結果表示
                    if let analysisResult = analysisResult {
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
                                generatePairingSuggestion()
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

                    // MARK: - ペアリング提案表示
                    if let pairingSuggestion = pairingSuggestion {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("ペアリング提案")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.bottom, 5)

                            Text(pairingSuggestion)
                                .font(.body)
                                .padding(.horizontal)
                        }
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(20)
                        .shadow(radius: 5)
                    }

                    // MARK: - 記録されたビールリスト
                    VStack(alignment: .leading, spacing: 10) {
                        Text("記録されたビール")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.bottom, 5)

                        if recordedBeers.isEmpty {
                            Text("まだ記録されたビールはありません。")
                                .foregroundColor(.gray)
                                .padding(.horizontal)
                        } else {
                            List{
                                ForEach(recordedBeers.sorted(by: { $0.timestamp > $1.timestamp })) { beer in
                                    BeerRecordRow(beer: beer) { idToDelete in
                                        Task {
                                            await deleteBeerRecord(idToDelete: idToDelete)
                                        }
                                    }
                                    // List のスタイルをリセットして、既存の BeerRecordRow のスタイルを尊重する
                                    .listRowSeparator(.hidden) // 区切り線を非表示
                                    .listRowBackground(Color.clear) // 背景を透明にして、BeerRecordRow の背景が見えるようにする
                                    .listRowInsets(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0)) // 行の余白を調整
                                }
                            }
                            .listStyle(.plain) // iOS 15+ 推奨: デフォルトのリストスタイルを無効化
                            .frame(height: min(CGFloat(recordedBeers.count) * 100 + 20, 400)) // リストの高さを調整 (内容に応じて)
                            // List を ScrollView 内に入れる場合は、高さの指定が重要
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(20)
                    .shadow(radius: 5)

                }
                .padding()
                .onAppear {
                    // ユーザー認証の試行
                    authenticateAnonymously()
                    // Firestoreの購読を開始
                    observeRecordedBeers()
                }
            }
            .navigationBarHidden(true) // トップのナビゲーションバーを隠す
            .background(LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.indigo.opacity(0.2)]), startPoint: .topLeading, endPoint: .bottomTrailing).ignoresSafeArea())
        }
    }
    
    // MARK: - 削除ヘルパー関数
    private func deleteBeerRecord(idToDelete: String) async {
        guard let currentUserId = userId else {
            errorMessage = "ユーザーが認証されていないため、ビールを削除できません。"
            return
        }

        do {
            // FirestoreService の削除メソッドを呼び出す
            try await firestoreService.deleteBeer(id: idToDelete, userId: currentUserId)
            print("Successfully deleted beer record with ID: \(idToDelete)")
            // observeBeers() がリアルタイムリスナーなので、自動的にリストが更新されるはず
        } catch {
            errorMessage = "ビールの削除に失敗しました: \(error.localizedDescription)"
            print("Error deleting beer record: \(error.localizedDescription)")
        }
    }

    // MARK: - ヘルパー関数
    private func analyzeBeer() {
        guard let uiImage = uiImage else {
            errorMessage = "解析する画像がありません。"
            return
        }
        guard let currentUserId = userId else {
            errorMessage = "ユーザーが認証されていません。しばらくお待ちください。"
            return
        }

        isLoadingAnalysis = true
        errorMessage = nil
        analysisResult = nil
        pairingSuggestion = nil

        Task {
            do {
                // まずは画像を Storage にアップロードする
                // ユニークなIDを生成 (FirestoreのドキュメントIDとして使われる可能性のあるUUID)
                let tempBeerId = UUID().uuidString
                let uploadedImageUrl = try await firestoreService.uploadImage(image: uiImage, userId: currentUserId, beerId: tempBeerId)
                print("Image uploaded. URL: \(uploadedImageUrl)")

                if let base64String = uiImage.toBase64() {
                    let result = try await geminiService.analyzeBeer(imageData: base64String, imageType: uiImage.toMimeType())
                    DispatchQueue.main.async { // UI更新はメインスレッドで
                        self.analysisResult = result
                        Task { // Firestoreに保存
                            await firestoreService.saveBeerRecord(result, imageUrl: uploadedImageUrl)
                        }
                    }
                } else {
                    throw BeerError.imageConversionFailed
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "ビールの解析に失敗しました: \(error.localizedDescription)"
                }
            }
            DispatchQueue.main.async {
                self.isLoadingAnalysis = false
            }
        }
    }

    private func generatePairingSuggestion() {
        guard let analysisResult = analysisResult else {
            errorMessage = "まずビールを解析してください。"
            return
        }

        isLoadingPairing = true
        errorMessage = nil

        Task {
            do {
                let suggestion = try await geminiService.generatePairingSuggestion(for: analysisResult)
                DispatchQueue.main.async {
                    self.pairingSuggestion = suggestion
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "ペアリングの提案に失敗しました: \(error.localizedDescription)"
                }
            }
            DispatchQueue.main.async {
                self.isLoadingPairing = false
            }
        }
    }

    private func authenticateAnonymously() {
        AuthService.shared.signInAnonymously { result in
            switch result {
            case .success(let uid):
                self.userId = uid
            case .failure(let error):
                self.errorMessage = "認証エラー: \(error.localizedDescription)"
            }
        }
    }

    private func observeRecordedBeers() {
        firestoreService.observeBeers { result in
            switch result {
            case .success(let beers):
                self.recordedBeers = beers
            case .failure(let error):
                self.errorMessage = "記録されたビールの読み込みエラー: \(error.localizedDescription)"
            }
        }
    }
}

// MARK: - ヘルパービュー (UIコンポーネント)
struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text("\(label):")
                .fontWeight(.semibold)
                .foregroundColor(.indigo)
            Spacer()
            Text(value)
                .foregroundColor(.gray)
        }
        .font(.body)
    }
}

struct BeerRecordRow: View {
    let beer: BeerRecord
    // 削除アクションを親ビューに通知するためのクロージャ
    var onDelete: (String) -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            // MARK: - ビール画像を表示
            if let imageUrlString = beer.imageUrl, let imageUrl = URL(string: imageUrlString) {
                KFImage(imageUrl) // URL を渡すだけで Kingfisher が処理
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    // MARK: - キャッシュのオプション（必要に応じて）
                    // .cacheOriginalImage() // オリジナル画像をキャッシュする（デフォルトで有効）
                    // .fade(duration: 0.2) // フェードイン効果
            } else {
                Image(systemName: "photo.fill") // 画像がない場合のプレースホルダー
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80)
                    .foregroundColor(.gray)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(beer.brand)
                    .font(.headline)
                    .foregroundColor(.indigo)
                Text("製造者: \(beer.manufacturer)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text("ABV: \(beer.abv)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text("ホップ: \(beer.hops)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text("記録日時: \(beer.timestamp.formatted())")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
        .contentShape(Rectangle())
        // スワイプ削除アクション
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                if let id = beer.id {
                    onDelete(id)
                }
            } label: {
                Label("削除", systemImage: "trash")
            }
        }
    }
}


// MARK: - UIImage の拡張 (Base64変換用)
extension UIImage {
    func toBase64() -> String? {
        // 画像データをJPEG形式で圧縮
        // 圧縮品質を調整して、APIリクエストのサイズを最適化できます (例: 0.8)
        guard let imageData = self.jpegData(compressionQuality: 0.8) else { return nil }
        return imageData.base64EncodedString()
    }

    func toMimeType() -> String {
        // 一般的な画像形式に対応
        if let _ = self.pngData() { // PNGの場合
            return "image/png"
        } else { // デフォルトはJPEG
            return "image/jpeg"
        }
    }
}
#Preview {
    ContentView()
}
