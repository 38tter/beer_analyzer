//
//  GeminiAPIService.swift
//  beer_analyzer
//
//  Created by 宮田聖也 on 2025/06/02.
//

import Foundation
import FirebaseRemoteConfig

class GeminiAPIService: ObservableObject {
    // @Published を追加して、APIキーの変更を監視可能にする
    @Published private(set) var apiKey: String? = nil // 初期値はnil
    private var remoteConfig: RemoteConfig! // RemoteConfigインスタンス

    init() {
        remoteConfig = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()
        
        // Debug モードでは 0 で即時フェッチを許可する
        settings.minimumFetchInterval = 0
        remoteConfig.configSettings = settings
        
        remoteConfig.setDefaults(fromPlist: "RemoteConfigDefaults")
        
        fetchAPIKey()
    }
    
    func fetchAPIKey() {
        remoteConfig.fetchAndActivate { [weak self] (status, error) in
            guard let self = self else { return }
            if let error = error {
                print("Error fetching remote config: \(error.localizedDescription)")
                self.apiKey = self.remoteConfig.configValue(forKey: "gemini_api_key").stringValue
                return
            }
            
            if status == .successFetchedFromRemote || status == .successUsingPreFetchedData {
                // フェッチ成功後、キーを取得
                self.apiKey = self.remoteConfig.configValue(forKey: "gemini_api_key").stringValue
                print("Gemini API Key fetched from Remote Config")
            } else {
                // フェッチに失敗した場合や、未フェッチの場合
                print("Remote Config fetch status: \(status.rawValue)")
                self.apiKey = self.remoteConfig.configValue(forKey: "gemini_api_key").stringValue // フォールバックを使用
            }
        }
    }
    
    private func makeRequest(url: URL, httpBody: Data) async throws -> Data {
        // APIキーが取得されるまで待機する
        guard let validApiKey = await withCheckedContinuation({ continuation in
            // apiKey がすでに存在するか、または変更を監視して取得するまで待つ
            if let key = self.apiKey {
                continuation.resume(returning: key)
            } else {
                // apiKey が設定されるのを待つ (例: @Published の変更を監視)
                // この部分のより堅牢な実装は、Combine を使うか、直接 fetchAPIKey() の完了を待つロジックが必要
                // 簡単なデモでは、nilの場合にエラーをスローするか、数秒待つなど
                // ここでは、fetchAPIKey()がすぐに呼ばれることを前提に、初回の呼び出しでAPIキーがnilの場合はエラーとしています
                print("Waiting for API key to be fetched...")
                // 実際には、非同期でapiKeyが設定されるのを待つメカニズムが必要
                // 例: タイムアウト付きのループや、Combineのsinkなど
                Task { // タイムアウト付きで待機する簡易的な例
                    var attempts = 0
                    while self.apiKey == nil && attempts < 10 { // 最大5秒待つ (0.5秒*10回)
                        try await Task.sleep(nanoseconds: 500_000_000) // 0.5秒待機
                        attempts += 1
                    }
                    continuation.resume(returning: self.apiKey)
                }
            }
        }) else {
            throw BeerError.apiError("Gemini API キーが利用できません。")
        }

        // URLにAPIキーを追加
        guard var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            throw BeerError.networkError("URLの構成に失敗しました。")
        }
        urlComponents.queryItems = [URLQueryItem(name: "key", value: validApiKey)]
        guard let finalUrl = urlComponents.url else {
            throw BeerError.networkError("最終的なURLの生成に失敗しました。")
        }

        var request = URLRequest(url: finalUrl)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = httpBody
    
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            let errorData = String(data: data, encoding: .utf8) ?? "不明なエラーデータ"
            throw BeerError.networkError("APIリクエストが失敗しました: HTTP Status \( (response as? HTTPURLResponse)?.statusCode ?? -1), Data: \(errorData)")
        }
        return data
    }

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

        guard let url = URL(string: "\(apiUrl)?key=\(self.apiKey?.description ?? "")") else {
            throw BeerError.networkError("無効なAPI URLです。")
        }
        
        print("url: \(url)")

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

        guard let url = URL(string: "\(apiUrl)?key=\(self.apiKey?.description ?? "")") else {
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
