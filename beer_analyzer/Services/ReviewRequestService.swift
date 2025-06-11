//
//  ReviewRequestService.swift
//  beer_analyzer
//
//  Created by Claude Code on 2025/06/11.
//

import Foundation

class ReviewRequestService {
    static let shared = ReviewRequestService()
    
    private let userDefaults = UserDefaults.standard
    private let beerCountKey = "registered_beer_count"
    private let reviewRequestedKey = "review_requested"
    private let neverShowReviewKey = "never_show_review"
    private let lastReviewRequestDateKey = "last_review_request_date"
    
    private init() {}
    
    // MARK: - Beer Count Management
    
    /// 登録されたビールの数を増やす
    func incrementBeerCount() {
        let currentCount = getBeerCount()
        let newCount = currentCount + 1
        userDefaults.set(newCount, forKey: beerCountKey)
        userDefaults.synchronize()
        
        print("Beer count incremented to: \(newCount)")
    }
    
    /// 現在のビール登録数を取得
    func getBeerCount() -> Int {
        return userDefaults.integer(forKey: beerCountKey)
    }
    
    // MARK: - Review Request Logic
    
    /// 評価リクエストを表示すべきかどうかを判定
    func shouldShowReviewRequest() -> Bool {
        // 「今後表示しない」が選択されている場合は表示しない
        if userDefaults.bool(forKey: neverShowReviewKey) {
            return false
        }
        
        // 5個目のビールが登録された場合
        let beerCount = getBeerCount()
        if beerCount == 5 {
            // まだ評価リクエストを表示していない、または前回から十分時間が経過している
            if !hasRequestedReviewRecently() {
                return true
            }
        }
        
        return false
    }
    
    /// 評価リクエストが表示されたことを記録
    func markReviewRequested() {
        userDefaults.set(true, forKey: reviewRequestedKey)
        userDefaults.set(Date(), forKey: lastReviewRequestDateKey)
        userDefaults.synchronize()
    }
    
    /// 「後で評価する」が選択された場合の処理
    func postponeReview() {
        // 現在のカウントを少し減らして、次のタイミングで再度表示されるようにする
        let currentCount = getBeerCount()
        userDefaults.set(currentCount - 2, forKey: beerCountKey) // 3個減らす（次の2個で再表示）
        userDefaults.synchronize()
    }
    
    /// 「今後表示しない」が選択された場合の処理
    func neverShowReview() {
        userDefaults.set(true, forKey: neverShowReviewKey)
        userDefaults.synchronize()
    }
    
    // MARK: - Helper Methods
    
    /// 最近評価リクエストを表示したかどうかをチェック
    private func hasRequestedReviewRecently() -> Bool {
        guard let lastRequestDate = userDefaults.object(forKey: lastReviewRequestDateKey) as? Date else {
            return false
        }
        
        // 30日以内に表示していた場合は「最近」とみなす
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        return lastRequestDate > thirtyDaysAgo
    }
    
    // MARK: - Debug/Test Methods
    
    /// テスト用：カウントをリセット
    func resetBeerCount() {
        userDefaults.removeObject(forKey: beerCountKey)
        userDefaults.removeObject(forKey: reviewRequestedKey)
        userDefaults.removeObject(forKey: neverShowReviewKey)
        userDefaults.removeObject(forKey: lastReviewRequestDateKey)
        userDefaults.synchronize()
    }
    
    /// テスト用：カウントを特定の値に設定
    func setBeerCount(_ count: Int) {
        userDefaults.set(count, forKey: beerCountKey)
        userDefaults.synchronize()
    }
}