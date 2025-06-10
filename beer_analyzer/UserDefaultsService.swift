//
//  UserDefaultsService.swift
//  beer_analyzer
//
//  Created by Jules on 2023/10/27. // Placeholder for actual date
//

import Foundation

struct UserDefaultsService {

    private static let termsAcceptedKey = "hasAcceptedTermsOfUse"

    static func hasAcceptedTerms() -> Bool {
        return UserDefaults.standard.bool(forKey: termsAcceptedKey)
    }

    static func setTermsAccepted(_ accepted: Bool) {
        UserDefaults.standard.set(accepted, forKey: termsAcceptedKey)
    }

    // Optional: A function to reset for testing purposes
    static func resetTermsAcceptedStatus() {
        UserDefaults.standard.removeObject(forKey: termsAcceptedKey)
    }
}
