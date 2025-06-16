//
//  LocalizationService.swift
//  beer_analyzer
//
//  Created by Claude Code on 2025/06/16.
//

import Foundation
import CoreLocation

public class LocalizationService: ObservableObject {
    public static let shared = LocalizationService()
    
    @Published public private(set) var currentLanguage: AppLanguage = .japanese
    @Published public private(set) var isLocationBasedLanguageDetected = false
    
    private let locationManager = CLLocationManager()
    private let userDefaults = UserDefaults.standard
    private let languageOverrideKey = "app_language_override"
    
    public enum AppLanguage: String, CaseIterable {
        case japanese = "ja"
        case english = "en"
        
        public var displayName: String {
            switch self {
            case .japanese:
                return "日本語"
            case .english:
                return "English"
            }
        }
    }
    
    private init() {
        setupLocationManager()
        loadLanguagePreference()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
    }
    
    // MARK: - Public Methods
    
    public func detectUserCountryAndSetLanguage() {
        // Check if user has manually set a language preference
        if let savedLanguageRaw = userDefaults.string(forKey: languageOverrideKey),
           let savedLanguage = AppLanguage(rawValue: savedLanguageRaw) {
            currentLanguage = savedLanguage
            return
        }
        
        // Try location-based detection
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
        case .denied, .restricted:
            // Fall back to system locale
            detectLanguageFromSystemLocale()
        @unknown default:
            detectLanguageFromSystemLocale()
        }
    }
    
    public func setLanguage(_ language: AppLanguage, savePreference: Bool = true) {
        currentLanguage = language
        
        if savePreference {
            userDefaults.set(language.rawValue, forKey: languageOverrideKey)
        }
    }
    
    public func resetToAutoDetect() {
        userDefaults.removeObject(forKey: languageOverrideKey)
        detectUserCountryAndSetLanguage()
    }
    
    // MARK: - Private Methods
    
    private func loadLanguagePreference() {
        if let savedLanguageRaw = userDefaults.string(forKey: languageOverrideKey),
           let savedLanguage = AppLanguage(rawValue: savedLanguageRaw) {
            currentLanguage = savedLanguage
        } else {
            detectLanguageFromSystemLocale()
        }
    }
    
    private func detectLanguageFromSystemLocale() {
        let systemLanguage = Locale.current.language.languageCode?.identifier ?? "ja"
        
        if systemLanguage == "ja" {
            currentLanguage = .japanese
        } else {
            currentLanguage = .english
        }
    }
    
    private func handleLocationUpdate(countryCode: String?) {
        guard userDefaults.string(forKey: languageOverrideKey) == nil else {
            return // User has set manual preference
        }
        
        if let countryCode = countryCode, countryCode == "JP" {
            currentLanguage = .japanese
        } else {
            currentLanguage = .english
        }
        
        isLocationBasedLanguageDetected = true
    }
}

// MARK: - CLLocationManagerDelegate
extension LocalizationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            if let placemark = placemarks?.first {
                self?.handleLocationUpdate(countryCode: placemark.isoCountryCode)
            } else {
                // Fallback to system locale if geocoding fails
                self?.detectLanguageFromSystemLocale()
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location detection failed: \(error.localizedDescription)")
        detectLanguageFromSystemLocale()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
        case .denied, .restricted:
            detectLanguageFromSystemLocale()
        case .notDetermined:
            break // Wait for user response
        @unknown default:
            detectLanguageFromSystemLocale()
        }
    }
}

// MARK: - Localized Strings
public extension LocalizationService {
    
    // MARK: - Main Tab Labels
    var addTabLabel: String {
        currentLanguage == .japanese ? "追加" : "Add"
    }
    
    var recordsTabLabel: String {
        currentLanguage == .japanese ? "記録" : "Records"
    }
    
    // MARK: - Content View
    var userId: String {
        currentLanguage == .japanese ? "ユーザーID" : "User ID"
    }
    
    var authenticating: String {
        currentLanguage == .japanese ? "認証中..." : "Authenticating..."
    }
    
    var preview: String {
        currentLanguage == .japanese ? "プレビュー" : "Preview"
    }
    
    var analyzing: String {
        currentLanguage == .japanese ? "解析中..." : "Analyzing..."
    }
    
    var analyzeBeer: String {
        currentLanguage == .japanese ? "ビールを解析" : "Analyze Beer"
    }
    
    var analysisFailed: String {
        currentLanguage == .japanese ? "ビールの解析に失敗しました" : "Beer Analysis Failed"
    }
    
    var beerNotDetected: String {
        currentLanguage == .japanese ? "ビールが検出されない、もしくはビールの解析に失敗しました" : "Beer not detected or analysis failed"
    }
    
    var analyzeFirst: String {
        currentLanguage == .japanese ? "まずビールを解析してください。" : "Please analyze beer first."
    }
    
    var noImageToAnalyze: String {
        currentLanguage == .japanese ? "解析する画像がありません。" : "No image to analyze."
    }
    
    var userNotAuthenticated: String {
        currentLanguage == .japanese ? "ユーザーが認証されていません。しばらくお待ちください。" : "User not authenticated. Please wait."
    }
    
    var cannotDeleteBeer: String {
        currentLanguage == .japanese ? "ユーザーが認証されていないため、ビールを削除できません。" : "Cannot delete beer because user is not authenticated."
    }
    
    var beerDeletionFailed: String {
        currentLanguage == .japanese ? "ビールの削除に失敗しました" : "Failed to delete beer"
    }
    
    var analysisFailedPrefix: String {
        currentLanguage == .japanese ? "ビールの解析に失敗しました: " : "Beer analysis failed: "
    }
    
    var pairingFailedPrefix: String {
        currentLanguage == .japanese ? "ペアリングの提案に失敗しました: " : "Pairing suggestion failed: "
    }
    
    var authError: String {
        currentLanguage == .japanese ? "認証エラー: " : "Authentication error: "
    }
    
    var recordLoadingError: String {
        currentLanguage == .japanese ? "ビールの記録の読み込みエラー: " : "Beer records loading error: "
    }
    
    // MARK: - Beer Records List
    var beerRecords: String {
        currentLanguage == .japanese ? "ビールの記録" : "Beer Records"
    }
    
    var itemsCount: String {
        currentLanguage == .japanese ? "件" : " items"
    }
    
    var sortOrder: String {
        currentLanguage == .japanese ? "並び順:" : "Sort:"
    }
    
    var newest: String {
        currentLanguage == .japanese ? "新しい順" : "Newest"
    }
    
    var oldest: String {
        currentLanguage == .japanese ? "古い順" : "Oldest"
    }
    
    var noRecordsYet: String {
        currentLanguage == .japanese ? "まだビールの記録はありません" : "No beer records yet"
    }
    
    var startRecording: String {
        currentLanguage == .japanese ? "ビールを解析して記録を開始しましょう！" : "Start by analyzing beer to create records!"
    }
    
    var loading: String {
        currentLanguage == .japanese ? "読み込み中..." : "Loading..."
    }
    
    // MARK: - Settings
    var settings: String {
        currentLanguage == .japanese ? "設定" : "Settings"
    }
    
    var termsOfUse: String {
        currentLanguage == .japanese ? "利用規約" : "Terms of Use"
    }
    
    var privacyPolicy: String {
        currentLanguage == .japanese ? "プライバシーポリシー" : "Privacy Policy"
    }
    
    var versionHistory: String {
        currentLanguage == .japanese ? "バージョン更新履歴" : "Version History"
    }
    
    var contact: String {
        currentLanguage == .japanese ? "お問い合わせ" : "Contact"
    }
    
    var developerInfo: String {
        currentLanguage == .japanese ? "開発者情報" : "Developer Info"
    }
    
    var language: String {
        currentLanguage == .japanese ? "言語" : "Language"
    }
    
    var languageAuto: String {
        currentLanguage == .japanese ? "自動" : "Auto"
    }
    
    // MARK: - Close/OK buttons
    var close: String {
        currentLanguage == .japanese ? "閉じる" : "Close"
    }
    
    var ok: String {
        currentLanguage == .japanese ? "OK" : "OK"
    }
    
    // MARK: - Terms of Use specific
    var agreeToTerms: String {
        currentLanguage == .japanese ? "利用規約への同意" : "Terms of Use Agreement"
    }
    
    var agreeAndStart: String {
        currentLanguage == .japanese ? "利用規約に同意してアプリを開始" : "Agree to Terms and Start App"
    }
    
    var mustAgreeMessage: String {
        currentLanguage == .japanese ? "同意いただかない場合、アプリをご利用いただけません。" : "You must agree to the terms to use this app."
    }
    
    var readTermsMessage: String {
        currentLanguage == .japanese ? "Beer Analyzerをご利用いただく前に、利用規約をお読みいただき、同意をお願いいたします。" : "Before using Beer Analyzer, please read and agree to the terms of use."
    }
    
    // MARK: - Terms of Use Content
    var termsOfUseContent: String {
        if currentLanguage == .japanese {
            return """
Beer Analyzer 利用規約

本利用規約（以下「本規約」といいます）は、38tter（以下「当社」といいます）が提供するモバイルアプリケーション「Beer Analyzer」（以下「本アプリ」といいます）の利用に関する条件を定めるものです。本アプリをご利用になる前に、本規約をよくお読みください。本アプリを利用することにより、お客様は本規約の全ての条件に同意したものとみなされます。

第1条（本規約への同意）
お客様は、本規約に同意した場合に限り、本アプリを利用することができます。

お客様が未成年である場合は、親権者その他の法定代理人の同意を得た上で本アプリを利用するものとします。

第2条（本アプリのサービス内容）
本アプリは、お客様が撮影・アップロードしたビールの画像から、銘柄、製造者、アルコール度数、ホップ等の情報をAIが解析・抽出し、記録・管理する機能を提供します。

本アプリは、記録されたビールの情報に基づき、AIがペアリング（料理やシーンなど）の提案を行う機能を提供します。

本アプリは、お客様が記録したビールの記録を保存し、閲覧できる機能を提供します。

第3条（生成AI機能の利用に関する注意）
本アプリは、最新の生成AI技術（Google Gemini等）を活用して画像解析および情報提案を行っています。

生成AIは、高度な技術を用いていますが、その性質上、生成される情報や提案には、誤り、不正確な内容、不適切な表現、または最新ではない情報が含まれる可能性があります。

お客様は、本アプリが提供する情報や提案をご自身の判断と責任において利用するものとし、その正確性、完全性、有用性について、当社はいかなる保証も行いません。

本アプリの利用により生じたいかなる損害についても、当社は一切の責任を負いません。

第4条（著作権および知的財産権）
本アプリに関する著作権、商標権、特許権その他一切の知的財産権は、当社または正当な権利者に帰属します。

お客様は、本アプリを通じて提供される情報やコンテンツを、私的利用の範囲を超えて利用（複製、改変、配布、公開など）することはできません。

お客様が本アプリにアップロードする画像に関する著作権は、お客様または正当な権利者に留保されますが、お客様は当社に対し、本アプリの運営、機能提供および改善のために、当該画像を無償で利用（複製、送信、加工、公開を含む）することを許諾するものとします。

第5条（禁止事項）
お客様は、本アプリの利用にあたり、以下の行為を行ってはなりません。

• 法令または本規約に違反する行為。
• 公序良俗に反する行為。
• 当社または第三者の権利（著作権、商標権、プライバシー権など）を侵害する行為。
• 他のお客様または第三者に不利益、損害、不快感を与える行為。
• 本アプリの運営を妨害する行為、または本アプリの信用を毀損する行為。
• コンピュータウイルス等の有害なプログラムを送信する行為。
• 本アプリを、解析や逆アセンブルするなどのリバースエンジニアリング行為。
• その他、当社が不適切と判断する行為。

第6条（免責事項）
当社は、本アプリの提供に関して、その完全性、正確性、信頼性、特定の目的への適合性、セキュリティなどについて、いかなる保証も行いません。

当社は、本アプリの利用によってお客様に生じた損害（直接的、間接的、偶発的、派生的損害を含むがこれに限られない）について、一切の責任を負いません。

当社は、本アプリの利用に関連して、お客様と第三者との間で生じた紛争について、一切の責任を負いません。

天災地変、システム障害、通信回線の障害その他当社の責に帰さない事由により本アプリの提供が中断または停止した場合でも、当社は責任を負いません。

第7条（本アプリの変更・停止・終了）
当社は、お客様に事前に通知することなく、本アプリのサービス内容を変更、追加、停止または終了することができるものとします。これによりお客様に生じたいかなる損害についても、当社は責任を負いません。

第8条（本規約の変更）
当社は、必要と判断した場合、お客様に事前に通知することなく本規約を変更できるものとします。変更後の規約は、本アプリ内に表示された時点から効力を生じるものとし、お客様は変更後の規約に従うものとします。

第9条（準拠法および管轄）
本規約の解釈にあたっては、日本法を準拠法とします。本規約に関する一切の紛争については、38tterの所在地を管轄する裁判所を第一審の専属的合意管轄裁判所とします。

制定日: 2025年6月11日
"""
        } else {
            return """
Beer Analyzer Terms of Use

These Terms of Use (hereinafter referred to as "these Terms") set forth the terms and conditions for the use of the mobile application "Beer Analyzer" (hereinafter referred to as "this App") provided by 38tter (hereinafter referred to as "the Company"). Please read these Terms carefully before using this App. By using this App, you are deemed to have agreed to all the terms and conditions of these Terms.

Article 1 (Agreement to these Terms)
You may use this App only if you agree to these Terms.

If you are a minor, you must obtain the consent of your parent or other legal guardian before using this App.

Article 2 (Service Content of this App)
This App provides a function that uses AI to analyze and extract information such as brand, manufacturer, alcohol content, and hops from beer images that you take or upload, and records and manages them.

This App provides a function that proposes pairing (dishes, scenes, etc.) based on recorded beer information using AI.

This App provides a function to save and view your recorded beer records.

Article 3 (Notes on the Use of Generative AI Functions)
This App uses the latest generative AI technology (such as Google Gemini) to perform image analysis and information suggestions.

Although generative AI uses advanced technology, due to its nature, the generated information and suggestions may contain errors, inaccurate content, inappropriate expressions, or outdated information.

You shall use the information and suggestions provided by this App at your own judgment and responsibility, and the Company makes no warranty regarding their accuracy, completeness, or usefulness.

The Company shall not be liable for any damages arising from the use of this App.

Article 4 (Copyright and Intellectual Property Rights)
All intellectual property rights, including copyrights, trademark rights, patent rights, and others related to this App belong to the Company or legitimate rights holders.

You may not use the information or content provided through this App beyond the scope of private use (including reproduction, modification, distribution, publication, etc.).

Copyright of images you upload to this App shall remain with you or legitimate rights holders, but you grant the Company the right to use such images free of charge (including reproduction, transmission, processing, and publication) for the operation, function provision, and improvement of this App.

Article 5 (Prohibited Acts)
When using this App, you must not engage in the following acts:

• Acts that violate laws or these Terms.
• Acts against public order and morals.
• Acts that infringe on the rights of the Company or third parties (copyrights, trademark rights, privacy rights, etc.).
• Acts that cause disadvantage, damage, or discomfort to other customers or third parties.
• Acts that interfere with the operation of this App or damage the credibility of this App.
• Acts of transmitting harmful programs such as computer viruses.
• Reverse engineering acts such as analyzing or disassembling this App.
• Other acts that the Company deems inappropriate.

Article 6 (Disclaimer)
The Company makes no warranty regarding the completeness, accuracy, reliability, suitability for specific purposes, security, etc., in relation to the provision of this App.

The Company shall not be liable for any damages (including but not limited to direct, indirect, incidental, and consequential damages) caused to you by the use of this App.

The Company shall not be liable for any disputes that arise between you and third parties in connection with the use of this App.

The Company shall not be liable even if the provision of this App is interrupted or stopped due to natural disasters, system failures, communication line failures, or other reasons not attributable to the Company.

Article 7 (Changes, Suspension, and Termination of this App)
The Company may change, add, suspend, or terminate the service content of this App without prior notice to you. The Company shall not be liable for any damages caused to you as a result.

Article 8 (Changes to these Terms)
The Company may change these Terms without prior notice to you when deemed necessary. The changed terms shall take effect from the time they are displayed in this App, and you shall comply with the changed terms.

Article 9 (Governing Law and Jurisdiction)
These Terms shall be governed by Japanese law. The court having jurisdiction over the location of 38tter shall be the exclusive agreed court of first instance for all disputes related to these Terms.

Effective Date: June 11, 2025
"""
        }
    }
}