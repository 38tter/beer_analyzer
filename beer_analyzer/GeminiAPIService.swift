//
//  GeminiAPIService.swift
//  beer_analyzer
//
//  Created by 宮田聖也 on 2025/06/02.
//

import Foundation

class GeminiAPIService: ObservableObject {
    // Canvas 環境から提供される API キーを使用するか、開発用に直接記述
    // ⚠️ 本番アプリではAPIキーをコードに直接埋め込まず、サーバーサイドや安全な方法で管理してください
    private let apiKey: String = {
        // 環境変数や設定ファイルから読み込むことを推奨
        // Canvas環境の場合は、`__api_key` グローバル変数が設定される可能性があります
        if let key = ProcessInfo.processInfo.environment["GEMINI_API_KEY"] {
            return key
        }
        // または、直接ここにAPIキーを記述 (開発目的のみ)
        return "YOUR_GEMINI_API_KEY" // ここにあなたのGemini APIキーを貼り付けてください
    }()


    private let apiUrl = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent"

    // MARK: - ビール解析API
    func analyzeBeer(imageData: String, imageType: String) async throws -> BeerAnalysisResult {
        let prompt = """
        このビールの銘柄、製造者、アルコール度数（ABV）、使用されているホップを特定し、JSON形式で提供してください。情報が見つからない場合は、対応するフィールドを空の文字列にしてください。
        例:
        {
          "brand": "アサヒスーパードライ",
          "manufacturer": "アサヒビール",
          "abv": "5%",
          "hops": "不明"
        }
        """

        let requestBody: [String: Any] = [
            "contents": [
                [
                    "role": "user",
                    "parts": [
                        ["text": prompt],
                        ["inlineData": ["mimeType": imageType, "data": imageData]]
                    ]
                ]
            ],
            "generationConfig": [
                "responseMimeType": "application/json",
                "responseSchema": [
                    "type": "OBJECT",
                    "properties": [
                        "brand": ["type": "STRING"],
                        "manufacturer": ["type": "STRING"],
                        "abv": ["type": "STRING"],
                        "hops": ["type": "STRING"]
                    ],
                    "propertyOrdering": ["brand", "manufacturer", "abv", "hops"]
                ]
            ]
        ]

        guard let url = URL(string: "\(apiUrl)?key=\(apiKey)") else {
            throw BeerError.networkError("無効なAPI URLです。")
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            let errorData = String(data: data, encoding: .utf8) ?? "不明なエラーデータ"
            throw BeerError.networkError("APIリクエストが失敗しました: HTTP Status \( (response as? HTTPURLResponse)?.statusCode ?? -1), Data: \(errorData)")
        }

        // Gemini APIのレスポンス構造に合わせたデコード
        struct GeminiResponse: Decodable {
            struct Candidate: Decodable {
                struct Content: Decodable {
                    struct Part: Decodable {
                        let text: String? // JSON文字列が含まれる
                    }
                    let parts: [Part]
                }
                let content: Content
            }
            let candidates: [Candidate]
        }

        let geminiResponse = try JSONDecoder().decode(GeminiResponse.self, from: data)

        guard let jsonString = geminiResponse.candidates.first?.content.parts.first?.text,
              let jsonData = jsonString.data(using: .utf8) else {
            throw BeerError.jsonParsingError
        }

        let decoder = JSONDecoder()
        return try decoder.decode(BeerAnalysisResult.self, from: jsonData)
    }

    // MARK: - ペアリング提案API
    func generatePairingSuggestion(for beer: BeerAnalysisResult) async throws -> String {
        let pairingPrompt = """
        以下のビールの情報に基づいて、そのビールに合う食べ物やシーンのペアリングを3つ提案してください。各提案は箇条書きで簡潔に記述し、提案が見つからない場合は「不明」と記述してください。
        ビールの銘柄: \(beer.brand)
        製造者: \(beer.manufacturer)
        アルコール度数 (ABV): \(beer.abv)
        ホップ: \(beer.hops)
        """

        let requestBody: [String: Any] = [
            "contents": [
                [
                    "role": "user",
                    "parts": [
                        ["text": pairingPrompt]
                    ]
                ]
            ],
            "generationConfig": [
                "responseMimeType": "text/plain" // テキスト形式で応答を期待
            ]
        ]

        guard let url = URL(string: "\(apiUrl)?key=\(apiKey)") else {
            throw BeerError.networkError("無効なAPI URLです。")
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            let errorData = String(data: data, encoding: .utf8) ?? "不明なエラーデータ"
            throw BeerError.networkError("APIリクエストが失敗しました: HTTP Status \( (response as? HTTPURLResponse)?.statusCode ?? -1), Data: \(errorData)")
        }

        // Gemini APIのレスポンス構造に合わせたデコード (テキスト用)
        struct GeminiTextResponse: Decodable {
            struct Candidate: Decodable {
                struct Content: Decodable {
                    struct Part: Decodable {
                        let text: String?
                    }
                    let parts: [Part]
                }
                let content: Content
            }
            let candidates: [Candidate]
        }

        let geminiResponse = try JSONDecoder().decode(GeminiTextResponse.self, from: data)

        guard let text = geminiResponse.candidates.first?.content.parts.first?.text else {
            throw BeerError.apiError("Geminiから有効なテキストレスポンスがありませんでした。")
        }

        return text
    }
}
