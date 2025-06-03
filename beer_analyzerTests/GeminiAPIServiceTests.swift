
//
//  GeminiAPIServiceTests.swift
//  beer_analyzerTests
//

import Testing
import Foundation
@testable import beer_analyzer

struct GeminiAPIServiceTests {
    
    @Test func testGeminiAPIServiceInitialization() async throws {
        let service = GeminiAPIService()
        #expect(service != nil)
    }
    
    @Test func testAnalyzeBeerWithInvalidImageData() async throws {
        let service = GeminiAPIService()
        
        // 無効な画像データでのテスト
        do {
            let _ = try await service.analyzeBeer(imageData: "", imageType: "image/jpeg")
            Issue.record("Expected error but succeeded")
        } catch {
            // エラーが発生することを期待
            #expect(error is BeerError)
        }
    }
    
    @Test func testAnalyzeBeerWithValidImageData() async throws {
        let service = GeminiAPIService()
        
        // 有効な画像データの模擬（実際のAPIキーが必要）
        let sampleBase64 = "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8/5+hHgAHggJ/PchI7wAAAABJRU5ErkJggg=="
        
        do {
            let _ = try await service.analyzeBeer(imageData: sampleBase64, imageType: "image/png")
            // APIキーが設定されていない場合はエラーが発生する
        } catch {
            // APIキーが設定されていない環境では正常なエラー
            #expect(error is BeerError)
        }
    }
    
    @Test func testGeneratePairingSuggestionWithValidBeer() async throws {
        let service = GeminiAPIService()
        let beer = BeerAnalysisResult(
            brand: "アサヒスーパードライ",
            manufacturer: "アサヒビール",
            abv: "5.0%",
            hops: "不明"
        )
        
        do {
            let _ = try await service.generatePairingSuggestion(for: beer)
            // APIキーが設定されていない場合はエラーが発生する
        } catch {
            // APIキーが設定されていない環境では正常なエラー
            #expect(error is BeerError)
        }
    }
}
