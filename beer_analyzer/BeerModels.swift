//
//  BeerModels.swift
//  beer_analyzer
//
//  Created by 宮田聖也 on 2025/06/02.
//

import Foundation
import FirebaseFirestore // Firestoreから直接Decodable/Encodableに変換するために必要

// ビール解析結果のモデル
struct BeerAnalysisResult: Codable, Identifiable {
    @DocumentID var id: String? = UUID().uuidString // FirestoreのID
    let brand: String
    let manufacturer: String
    let abv: String
    let hops: String

    // FirestoreのIDを自動生成するためにinitを追加
    init(brand: String, manufacturer: String, abv: String, hops: String) {
        self.brand = brand
        self.manufacturer = manufacturer
        self.abv = abv
        self.hops = hops
    }
}

// 記録されたビールのモデル (Firestore用)
struct BeerRecord: Codable, Identifiable {
    @DocumentID var id: String? // FirestoreのドキュメントID
    let brand: String
    let manufacturer: String
    let abv: String
    let hops: String
    let timestamp: Date // 記録日時
    let userId: String // どのユーザーが記録したか

    // Decodable のカスタムイニシャライザ
    // FirebaseFirestoreSwift で @DocumentID が自動的にIDを注入してくれる
    enum CodingKeys: String, CodingKey {
        case brand
        case manufacturer
        case abv
        case hops
        case timestamp
        case userId
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.brand = try container.decode(String.self, forKey: .brand)
        self.manufacturer = try container.decode(String.self, forKey: .manufacturer)
        self.abv = try container.decode(String.self, forKey: .abv)
        self.hops = try container.decode(String.self, forKey: .hops)
        self.timestamp = try container.decode(Date.self, forKey: .timestamp)
        self.userId = try container.decode(String.self, forKey: .userId)
    }

    // Encodable のカスタムエンコーダ (Firestoreに保存する際に必要)
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(brand, forKey: .brand)
        try container.encode(manufacturer, forKey: .manufacturer)
        try container.encode(abv, forKey: .abv)
        try container.encode(hops, forKey: .hops)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(userId, forKey: .userId)
    }

    // FirebaseのaddDocなどで使用するためのinit (FireStoreServiceで使用)
    init(analysisResult: BeerAnalysisResult, userId: String, timestamp: Date) {
        self.brand = analysisResult.brand
        self.manufacturer = analysisResult.manufacturer
        self.abv = analysisResult.abv
        self.hops = analysisResult.hops
        self.userId = userId
        self.timestamp = timestamp
    }
}

// カスタムエラーの定義
enum BeerError: Error, LocalizedError {
    case networkError(String)
    case jsonParsingError
    case apiError(String)
    case imageConversionFailed
    case unknown

    var errorDescription: String? {
        switch self {
        case .networkError(let message): return "ネットワークエラー: \(message)"
        case .jsonParsingError: return "データ解析エラー: 不正な形式のデータが返されました。"
        case .apiError(let message): return "APIエラー: \(message)"
        case .imageConversionFailed: return "画像変換エラー: 画像データの処理に失敗しました。"
        case .unknown: return "不明なエラーが発生しました。"
        }
    }
}
