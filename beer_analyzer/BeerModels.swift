//
//  BeerModels.swift
//  beer_analyzer
//
//  Created by 宮田聖也 on 2025/06/02.
//

import Foundation
import FirebaseFirestore // Firestoreから直接Decodable/Encodableに変換するために必要

// ビール解析結果のモデル
struct BeerAnalysisResult: Codable {
    let beerName: String
    let brand: String
    let manufacturer: String
    let abv: String
    let capacity: String
    let hops: String
    let isNotBeer: Bool
    let websiteUrl: String?

    // FirestoreのIDを自動生成するためにinitを追加
    init(beerName: String, brand: String, manufacturer: String, abv: String, capacity: String, hops: String, isNotBeer: Bool, websiteUrl: String? = nil) {
        self.beerName = beerName
        self.brand = brand
        self.manufacturer = manufacturer
        self.abv = abv
        self.capacity = capacity
        self.hops = hops
        self.isNotBeer = isNotBeer
        self.websiteUrl = websiteUrl
    }
}

// 記録されたビールのモデル (Firestore用)
struct BeerRecord: Codable, Identifiable {
    @DocumentID var id: String? // FirestoreのドキュメントID
    let beerName: String
    let brand: String
    let manufacturer: String
    let abv: String
    let capacity: String
    let hops: String
    let isNotBeer: Bool
    let timestamp: Date // 記録日時
    let userId: String // どのユーザーが記録したか
    // MARK: - 画像URLを追加
    let imageUrl: String?
    // MARK: - 飲んだかどうかのフラグを追加
    let hasDrunk: Bool
    // MARK: - 公式サイトURLを追加
    let websiteUrl: String?
    // MARK: - メモを追加
    let memo: String?

    // Encodable のカスタムエンコーダ (Firestoreに保存する際に必要)
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(beerName, forKey: .beerName)
        try container.encode(brand, forKey: .brand)
        try container.encode(manufacturer, forKey: .manufacturer)
        try container.encode(abv, forKey: .abv)
        try container.encode(capacity, forKey: .capacity)
        try container.encode(hops, forKey: .hops)
        try container.encode(isNotBeer, forKey: .isNotBeer)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(userId, forKey: .userId)
        try container.encode(imageUrl, forKey: .imageUrl)
        try container.encode(hasDrunk, forKey: .hasDrunk)
        try container.encode(websiteUrl, forKey: .websiteUrl)
        try container.encode(memo, forKey: .memo)
    }

    // FirebaseのaddDocなどで使用するためのinit (FireStoreServiceで使用)
    init(analysisResult: BeerAnalysisResult, userId: String, timestamp: Date, imageUrl: String, hasDrunk: Bool = false, websiteUrl: String? = nil, memo: String? = nil) {
        self.beerName = analysisResult.beerName
        self.brand = analysisResult.brand
        self.manufacturer = analysisResult.manufacturer
        self.abv = analysisResult.abv
        self.capacity = analysisResult.capacity
        self.hops = analysisResult.hops
        self.isNotBeer = analysisResult.isNotBeer
        self.userId = userId
        self.timestamp = timestamp
        self.imageUrl = imageUrl
        self.hasDrunk = hasDrunk
        self.websiteUrl = websiteUrl
        self.memo = memo
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
