//
//  FirestoreService.swift
//  beer_analyzer
//
//  Created by 宮田聖也 on 2025/06/02.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth // userId取得のため
import FirebaseStorage

class FirestoreService: ObservableObject {
    private let db = Firestore.firestore()
    private var listenerRegistration: ListenerRegistration? // リアルタイムリスナーを保持
    private let storage = Storage.storage() // MARK: - Storage インスタンスを追加

    // MARK: - Firestore からの更新を自動的にビューに通知
    @Published var recordedBeers: [BeerRecord] = []
    
    // アプリIDは、Canvas 環境で提供されるものを想定
    // または、Xcodeプロジェクトのビルド設定やInfo.plistから取得
    private let appId = "default-app-id" // 必要に応じて適切なIDを設定
    
    // MARK: - 画像を Storage にアップロードするメソッド
    func uploadImage(image: UIImage, userId: String, beerId: String) async throws -> String {
        // 画像データを JPEG または PNG に変換
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw BeerError.imageConversionFailed
        }

        // Storage の参照を作成: 例 users/{userId}/beers/{beerId}.jpg
        let storageRef = storage.reference().child("users/\(userId)/beers/\(beerId).jpg")

        // メタデータ (Optional)
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg" // または image/png

        do {
            // 画像データをアップロード
            let uploadTask = try await storageRef.putDataAsync(imageData, metadata: metadata)
            print("Storage: Image uploaded successfully.")

            // ダウンロードURLを取得
            let downloadURL = try await storageRef.downloadURL()
            print("Storage: Download URL: \(downloadURL.absoluteString)")
            return downloadURL.absoluteString // URL を文字列として返す
        } catch {
            print("Storage: Error uploading image: \(error.localizedDescription)")
            throw error
        }
    }

    // ビール記録を保存する
    func saveBeerRecord(_ result: BeerAnalysisResult, imageUrl: String?) async {
        guard let userId = AuthService.shared.getCurrentUserId() else {
            print("Error: User not authenticated for Firestore saving.")
            return
        }

        let beerRecord = BeerRecord(analysisResult: result, userId: userId, timestamp: Date(), imageUrl: imageUrl ?? "")
        
        print("Saving beer record to Firestore: \(beerRecord)")

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
            self.recordedBeers.removeAll()
            return
        }

        // 既存のリスナーがあれば削除してメモリリークを防ぐ
        listenerRegistration?.remove()

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
    
    // MARK: - ビールレコードを更新するメソッド (新規追加)
    func updateBeer(documentId: String, beer: BeerRecord) async throws {
        guard let userId = AuthService.shared.getCurrentUserId() else {
            print("Error: Cannot update beer. User not authenticated.")
            throw BeerError.apiError("ユーザーが認証されていないため、ビールを更新できません。")
        }
//        guard let documentId = id else {
//            print("Error: Cannot update beer. Document ID is missing.")
//            throw BeerError.apiError("ドキュメントIDがないため、ビールを更新できません。")
//        }

        let documentRef = db.collection("artifacts").document(appId)
            .collection("users").document(userId)
            .collection("beers").document(documentId)

        do {
            // setDoc(from:) を使用して、既存のドキュメントを更新（または存在しない場合は新規作成）
            try await documentRef.setData(from: beer)
            print("Firestore: Document successfully updated for ID: \(documentId)")
        } catch {
            print("Firestore: Error updating document \(documentId): \(error.localizedDescription)")
            throw error
        }
    }
    
    // MARK: - 新しいビール削除メソッド
    func deleteBeer(id documentId: String, userId: String) async throws {
        // ドキュメントのパスを構築
        let documentRef = db.collection("artifacts").document(appId)
            .collection("users").document(userId)
            .collection("beers").document(documentId)

        do {
            // ドキュメントを削除
            try await documentRef.delete()
            print("Firestore: Document successfully deleted for ID: \(documentId)")
        } catch {
            print("Firestore: Error deleting document \(documentId): \(error.localizedDescription)")
            throw error // エラーを呼び出し元に伝播させる
        }
    }

    // リスナーを手動で停止する
    func stopObservingBeers() {
        listenerRegistration?.remove()
        listenerRegistration = nil
    }
    
    // リスナーを停止する（アプリ終了時などにメモリリーク防止のため）
    deinit {
        listenerRegistration?.remove()
    }
}
