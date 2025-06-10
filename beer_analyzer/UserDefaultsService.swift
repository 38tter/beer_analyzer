//
//  UserDefaultsService.swift
//  beer_analyzer
//
//  Created by Claude Code on 2025/06/11.
//

import Foundation

class UserDefaultsService {
    private static let termsAcceptedKey = "terms_accepted"
    
    /// 利用規約への同意状態を確認
    static func hasAcceptedTerms() -> Bool {
        return UserDefaults.standard.bool(forKey: termsAcceptedKey)
    }
    
    /// 利用規約への同意状態を設定
    static func setTermsAccepted(_ accepted: Bool) {
        UserDefaults.standard.set(accepted, forKey: termsAcceptedKey)
        UserDefaults.standard.synchronize()
    }
    
    /// 利用規約の同意状態をリセット（デバッグ用）
    static func resetTermsAcceptance() {
        UserDefaults.standard.removeObject(forKey: termsAcceptedKey)
        UserDefaults.standard.synchronize()
    }
}