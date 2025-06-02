//
//  FirestoreService.swift
//  beer_analyzer
//
//  Created by 宮田聖也 on 2025/06/02.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth // userId取得のため

class FirestoreService: ObservableObject {
    private let db = Firestore.firestore()
    private var listenerRegistration: ListenerRegistration? // リアルタイムリスナーを保持

    // アプリIDは、Canvas 環境で提供されるものを想定
    // または、Xcodeプロジェクトのビルド設定やInfo.plistから取得
    private let appId = "default-app-id" // 必要に応じて適切なIDを設定

    // ビール記録を保存する
    func saveBeerRecord(_ result: BeerAnalysisResult) async {
        guard let userId = AuthService.shared.getCurrentUserId() else {
            print("Error: User not authenticated for Firestore saving.")
            return
        }

        let beerRecord = BeerRecord(analysisResult: result, userId: userId, timestamp: Date())

        do {
            // DocumentIDはBeerRecordの@DocumentIDプロパティによって自動的に生成/設定される
            try db.collection("artifacts").document(appId)
                .collection("users").document(userId)
                .collection("beers").addDocument(from: beerRecord)
            print("Beer record saved to Firestore successfully!")
        } catch {
            print("Error saving beer record to Firestore: \(error.localizedDescription)")
        }
    }

    // 記録されたビールをリアルタイムで購読する
    func observeBeers(completion: @escaping (Result<[BeerRecord], Error>) -> Void) {
        guard let userId = AuthService.shared.getCurrentUserId() else {
            completion(.failure(BeerError.apiError("ユーザーが認証されていません。"))) // または適切なエラー
            return
        }

        let beersCollectionRef = db.collection("artifacts").document(appId)
            .collection("users").document(userId)
            .collection("beers")
            .order(by: "timestamp", descending: true) // 最新のものを先頭に

        listenerRegistration = beersCollectionRef.addSnapshotListener { querySnapshot, error in
            if let error = error {
                print("Error fetching recorded beers: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }

            guard let documents = querySnapshot?.documents else {
                print("No documents in 'beers' collection")
                completion(.success([]))
                return
            }

            let beers = documents.compactMap { doc -> BeerRecord? in
                do {
                    let beer = try doc.data(as: BeerRecord.self)
                    // ここで id の値を出力して確認します
                    print("Decoded BeerRecord ID: \(beer.id ?? "NIL ID") for brand: \(beer.brand)") // IDとブランド名を出力
                    return beer
                } catch {
                    print("Full decoding error object: \(error)")
                    print("Error decoding beer record: \(error.localizedDescription)")
                    return nil
                }
            }
            completion(.success(beers))
        }
    }

    // リスナーを停止する（アプリ終了時などにメモリリーク防止のため）
    deinit {
        listenerRegistration?.remove()
    }
}
