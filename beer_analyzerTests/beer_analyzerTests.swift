
//
//  beer_analyzerTests.swift
//  beer_analyzerTests
//
//  Created by 宮田聖也 on 2025/06/02.
//

import Testing
import Foundation
@testable import beer_analyzer

struct beer_analyzerTests {

    @Test func testBeerAnalysisResultInitialization() async throws {
        let result = BeerAnalysisResult(
            brand: "アサヒスーパードライ",
            manufacturer: "アサヒビール",
            abv: "5.0%",
            hops: "不明"
        )
        
        #expect(result.brand == "アサヒスーパードライ")
        #expect(result.manufacturer == "アサヒビール")
        #expect(result.abv == "5.0%")
        #expect(result.hops == "不明")
    }

    @Test func testBeerRecordInitialization() async throws {
        let analysisResult = BeerAnalysisResult(
            brand: "キリン一番搾り",
            manufacturer: "キリンビール",
            abv: "5.0%",
            hops: "ファインアロマホップ"
        )
        
        let record = BeerRecord(
            id: "test-id",
            analysisResult: analysisResult,
            userId: "user-123",
            timestamp: Date(),
            imageUrl: "https://example.com/image.jpg"
        )
        
        #expect(record.id == "test-id")
        #expect(record.brand == "キリン一番搾り")
        #expect(record.manufacturer == "キリンビール")
        #expect(record.abv == "5.0%")
        #expect(record.hops == "ファインアロマホップ")
        #expect(record.userId == "user-123")
        #expect(record.imageUrl == "https://example.com/image.jpg")
    }

    @Test func testBeerErrorTypes() async throws {
        let networkError = BeerError.networkError("Connection failed")
        let jsonError = BeerError.jsonParsingError
        let apiError = BeerError.apiError("Invalid API key")
        let imageError = BeerError.imageConversionFailed
        let unknownError = BeerError.unknown
        
        #expect(networkError.errorDescription?.contains("ネットワークエラー") == true)
        #expect(jsonError.errorDescription?.contains("JSON") == true)
        #expect(apiError.errorDescription?.contains("API") == true)
        #expect(imageError.errorDescription?.contains("画像") == true)
        #expect(unknownError.errorDescription?.contains("不明") == true)
    }

    @Test func testBeerAnalysisResultJSONDecoding() async throws {
        let jsonString = """
        {
            "brand": "サッポロ黒ラベル",
            "manufacturer": "サッポロビール",
            "abv": "5.0%",
            "hops": "アロマホップ"
        }
        """
        
        let jsonData = jsonString.data(using: .utf8)!
        let decoder = JSONDecoder()
        let result = try decoder.decode(BeerAnalysisResult.self, from: jsonData)
        
        #expect(result.brand == "サッポロ黒ラベル")
        #expect(result.manufacturer == "サッポロビール")
        #expect(result.abv == "5.0%")
        #expect(result.hops == "アロマホップ")
    }

    @Test func testBeerAnalysisResultJSONEncoding() async throws {
        let result = BeerAnalysisResult(
            brand: "エビスビール",
            manufacturer: "サッポロビール",
            abv: "5.0%",
            hops: "バイエルン産アロマホップ"
        )
        
        let encoder = JSONEncoder()
        let jsonData = try encoder.encode(result)
        let jsonString = String(data: jsonData, encoding: .utf8)!
        
        #expect(jsonString.contains("エビスビール"))
        #expect(jsonString.contains("サッポロビール"))
        #expect(jsonString.contains("5.0%"))
        #expect(jsonString.contains("バイエルン産アロマホップ"))
    }

    @Test func testEmptyBeerAnalysisResult() async throws {
        let result = BeerAnalysisResult(
            brand: "",
            manufacturer: "",
            abv: "",
            hops: ""
        )
        
        #expect(result.brand.isEmpty)
        #expect(result.manufacturer.isEmpty)
        #expect(result.abv.isEmpty)
        #expect(result.hops.isEmpty)
    }

    @Test func testBeerRecordWithNilImageUrl() async throws {
        let analysisResult = BeerAnalysisResult(
            brand: "テストビール",
            manufacturer: "テスト醸造所",
            abv: "4.5%",
            hops: "テストホップ"
        )
        
        let record = BeerRecord(
            id: "test-id",
            analysisResult: analysisResult,
            userId: "user-123",
            timestamp: Date(),
            imageUrl: nil
        )
        
        #expect(record.imageUrl == nil)
        #expect(record.brand == "テストビール")
    }

    @Test func testBeerRecordTimestampHandling() async throws {
        let now = Date()
        let analysisResult = BeerAnalysisResult(
            brand: "タイムテストビール",
            manufacturer: "時間醸造所",
            abv: "6.0%",
            hops: "時間ホップ"
        )
        
        let record = BeerRecord(
            id: "time-test",
            analysisResult: analysisResult,
            userId: "user-time",
            timestamp: now,
            imageUrl: nil
        )
        
        #expect(abs(record.timestamp.timeIntervalSince(now)) < 1.0)
    }

    @Test func testMultipleBeerRecordsComparison() async throws {
        let result1 = BeerAnalysisResult(brand: "ビール1", manufacturer: "醸造所1", abv: "5%", hops: "ホップ1")
        let result2 = BeerAnalysisResult(brand: "ビール2", manufacturer: "醸造所2", abv: "6%", hops: "ホップ2")
        
        let record1 = BeerRecord(id: "1", analysisResult: result1, userId: "user", timestamp: Date(), imageUrl: nil)
        let record2 = BeerRecord(id: "2", analysisResult: result2, userId: "user", timestamp: Date(), imageUrl: nil)
        
        #expect(record1.id != record2.id)
        #expect(record1.brand != record2.brand)
        #expect(record1.manufacturer != record2.manufacturer)
    }
}
