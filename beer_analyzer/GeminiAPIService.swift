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
            let errorData = String(data: data, encoding: .utf8) ?? NSLocalizedString("unknown_error_data", comment: "")
            throw BeerError.networkError("APIリクエストが失敗しました: HTTP Status \( (response as? HTTPURLResponse)?.statusCode ?? -1), Data: \(errorData)")
        }
        return data
    }

    private let apiUrl = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent"

    // MARK: - response 型定義
    // レスポンスの 'parts' 配列内の各要素
    struct GeminiResponsePart: Codable {
        let text: String? // テキスト内容
    }

    // レスポンスの 'content' オブジェクト
    struct GeminiResponseContent: Codable {
        let parts: [GeminiResponsePart] // parts 配列
        // 他にも "role" などがある場合がありますが、今回は抽出に不要なので省略
    }

    // レスポンスの 'candidates' 配列内の各要素
    struct GeminiResponseCandidate: Codable {
        let content: GeminiResponseContent // content オブジェクト
        // 他にも "finishReason", "groundingMetadata" などがある場合がありますが、今回は抽出に不要なので省略
    }

    // Gemini API の最上位レスポンス構造
    struct GeminiAPIResponse: Codable {
        let candidates: [GeminiResponseCandidate] // candidates 配列
        // 他にも "usageMetadata", "modelVersion", "responseId" などがある場合がありますが、今回は抽出に不要なので省略
    }

    // MARK: - ビール解析API
    func analyzeBeer(imageData: String, imageType: String) async throws -> BeerAnalysisResult {
        // 現在の言語設定を取得
        let currentLanguage = Locale.current.language.languageCode?.identifier ?? "ja"
        
        // 言語に応じてプロンプトを構築
        let basePrompt = """
        この画像には、ビールが映っています。ビールの名称、製造者、アルコール度数（ABV）、容量、使用されているホップを特定してください。
        もし画像から特定できない場合は、与えられたキーワード（ビールの名称、製造者、アルコール度数、容量）を元に以下を参照し、情報を検索して整理して出力してください。

        ## 要件
        - ブルワリー名は通称とする。
        - 本社の住所を採用する。
        - JSON 形式でまとめてください。
        - 情報が存在しない場合は "不明" とする。
        - ホップについては「ホップ」のみの回答は避ける。それ以上わからない場合は "不明" と返す。
        - 複数のビールが映っている場合は、画像の中心に最も近いビールのみを対象とする。
        - もしビールが映っていない場合は、is_not_beer を true と返す。それ以外は false と返す。

        ## 参照する情報の優先順位
        1. クラビ連サイト: https://0423craft.beer/expo2025/?id=brewery で探す
        2. 日本産ホップ推進委員会サイト: https://japanhop.jp/brewery/ で探す
        3. 公式ホームページを探す
        4. facebook または instagram の公式アカウントを探す
        5. Wikipedia で探す

        ## 取得する情報
        - ビールの名称: beer_name
        - ブルワリーの名称: brand
        - 企業の名称: manufacturer
        - 企業の住所: address
        - 国名: country
        - 公式ホームページURL: url
        - instagramアカウント: instagram_account
        - Xアカウント: x_account
        - ビールのアルコール度数 : abv
        - ビールの容量 : capacity
        - ホップ : hops
        - 画像にビールが映ってない : is_not_beer
        """
        
        // 英語設定の場合は英語での回答を要求
        let languageInstruction = currentLanguage == "en" ? "\n\n## 言語設定\n- 結果は英語で返してください。" : ""
        
        let prompt = basePrompt + languageInstruction

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
            "tools": [
                [
                    "googleSearch": [:]
                ]
            ],
        ]

        guard let url = URL(string: "\(apiUrl)?key=\(self.apiKey?.description ?? "")") else {
            throw BeerError.networkError("無効なAPI URLです。")
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])

        let (data, response) = try await URLSession.shared.data(for: request)
        
        print(String(data: data, encoding: .utf8) ?? NSLocalizedString("unknown_error_data", comment: ""))

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            let errorData = String(data: data, encoding: .utf8) ?? NSLocalizedString("unknown_error_data", comment: "")
            throw BeerError.networkError("APIリクエストが失敗しました: HTTP Status \( (response as? HTTPURLResponse)?.statusCode ?? -1), Data: \(errorData)")
        }
        
        let detailedBreweryInfo = try parseGeminiBreweryResponse(jsonData: data)
        
        return BeerAnalysisResult(
            beerName: detailedBreweryInfo.beerName ?? NSLocalizedString("unknown", comment: ""),
            brand: detailedBreweryInfo.brand ?? NSLocalizedString("unknown", comment: ""),
            manufacturer: detailedBreweryInfo.manufacturer ?? NSLocalizedString("unknown", comment: ""),
            abv: detailedBreweryInfo.abv ?? NSLocalizedString("unknown", comment: ""),
            capacity: detailedBreweryInfo.capacity ?? NSLocalizedString("unknown", comment: ""),
            hops: detailedBreweryInfo.hops ?? NSLocalizedString("unknown", comment: ""),
            isNotBeer: detailedBreweryInfo.isNotBeer ?? false,
            websiteUrl: detailedBreweryInfo.url?.absoluteString
        )
    }
    
    // MARK: - 2. 抽出する JSON データの構造を定義 (より詳細なブルワリー情報)

    // Gemini が返した JSON コードブロック内のデータ構造
    struct DetailedBreweryInfo: Codable {
        let beerName: String?
        let brand: String?
        let manufacturer: String?
        let address: String?
        let country: String?
        let countryEn: String? // country_en に対応
        let countryCode: String? // country_code に対応
        let url: URL? // URL型にパース
        let facebookAccount: URL? // facebook_account に対応
        let instagramAccount: URL? // instagram_account に対応
        let xAccount: URL? // x_account に対応
        let beerBreweryNameEn: String? // beer_brewery_name_en に対応
        let companyNameEn: String? // company_name_en に対応
        let abv: String?
        let capacity: String?
        let hops: String? // JSONではnullなのでOptional String
        let isNotBeer: Bool?

        // JSONのキー名とSwiftのプロパティ名が異なる場合にマッピング
        private enum CodingKeys: String, CodingKey {
            case beerName = "beer_name"
            case brand
            case manufacturer
            case address
            case country
            case countryEn = "country_en"
            case countryCode = "country_code"
            case url
            case facebookAccount = "facebook_account"
            case instagramAccount = "instagram_account"
            case xAccount = "x_account"
            case beerBreweryNameEn = "beer_brewery_name_en"
            case companyNameEn = "company_name_en"
            case abv
            case capacity
            case hops
            case isNotBeer = "is_not_beer"
        }
    }
    
    func parseGeminiBreweryResponse(jsonData: Data) throws -> DetailedBreweryInfo {
        let decoder = JSONDecoder()

        // 1. レスポンス全体の構造をデコード
        let apiResponse = try decoder.decode(GeminiAPIResponse.self, from: jsonData)

        print("before getting: \(String(data: jsonData, encoding: .utf8) ?? "(JSONデータが正しく解釈できませんでした)")")
        
        // 2. 必要な 'parts' 配列の3番目の要素 (インデックス2) を取得
        guard let candidate = apiResponse.candidates.first else {
            throw ParsingError.invalidResponseStructure("candidate がありません")
        }
        var jsonCodeBlockText = ""
        if let matchingPart = candidate.content.parts.first(where: { part in
            // part.text が nil でない場合に contains(_:) を実行
            part.text?.contains("json") ?? false
        }) {
            jsonCodeBlockText = matchingPart.text!
        } else {
            print("first(where:) 結果: JSONコードブロックは見つかりませんでした。")
            throw ParsingError.invalidResponseStructure("必要なJSONコードブロックが見つかりませんでした。")
        }
        
        print("before fixing: \(jsonCodeBlockText)")

        // 3. Markdown コードブロックのデリミタを削除して、純粋な JSON 文字列を抽出
        let cleanedJsonString = jsonCodeBlockText
            .replacingOccurrences(of: "```json\n", with: "")
            .replacingOccurrences(of: "\n```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines) // 前後の空白や改行を削除

        guard let extractedJsonData = cleanedJsonString.data(using: .utf8) else {
            throw ParsingError.invalidJsonString("抽出された文字列をデータに変換できませんでした。")
        }
        
        print("before parsing: \(String(data: extractedJsonData, encoding: .utf8))")

        // 4. 抽出した JSON データを DetailedBreweryInfo 構造体にパース
        return try decoder.decode(DetailedBreweryInfo.self, from: extractedJsonData)
    }

    // カスタムエラーの定義 (オプション)
    enum ParsingError: Error, LocalizedError {
        case invalidResponseStructure(String)
        case invalidJsonString(String)
        case decodingFailed(Error)

        var errorDescription: String? {
            switch self {
            case .invalidResponseStructure(let message): return "レスポンス構造が不正です: \(message)"
            case .invalidJsonString(let message): return "抽出されたJSON文字列が不正です: \(message)"
            case .decodingFailed(let underlyingError): return "JSONのデコードに失敗しました: \(underlyingError.localizedDescription)"
            }
        }
    }


    // MARK: - ペアリング提案API
    func generatePairingSuggestion(for beer: BeerAnalysisResult) async throws -> String {
        // 現在の言語設定を取得
        let currentLanguage = Locale.current.language.languageCode?.identifier ?? "ja"
        
        let basePairingPrompt = """
        以下のビールの情報に基づいて、そのビールに合う料理を検索し、最大で3つ提案してください。各提案は箇条書きで簡潔に記述し、提案が見つからない場合は「不明」と記述してください。
        ビールの名称: \(beer.beerName)
        ビールの銘柄: \(beer.brand)
        製造者: \(beer.manufacturer)
        アルコール度数 (ABV): \(beer.abv)
        容量: \(beer.capacity)
        ホップ: \(beer.hops)
        
        ## 要件
        - それぞれの料理について「料理名」をタイトルとし、「理由」「おすすめのシーン」を箇条書きで書いてください。
        """
        
        // 英語設定の場合は英語での回答を要求
        let languageInstruction = currentLanguage == "en" ? "\n\n## 言語設定\n- 結果は英語で返してください。" : ""
        
        let pairingPrompt = basePairingPrompt + languageInstruction

        let requestBody: [String: Any] = [
            "contents": [
                [
                    "role": "user",
                    "parts": [
                        ["text": pairingPrompt]
                    ]
                ]
            ],
            "tools": [
                [
                    "googleSearch": [:]
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
            let errorData = String(data: data, encoding: .utf8) ?? NSLocalizedString("unknown_error_data", comment: "")
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
