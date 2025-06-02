//
//  AuthService.swift
//  beer_analyzer
//
//  Created by 宮田聖也 on 2025/06/02.
//

import Foundation
import FirebaseAuth

class AuthService: ObservableObject {
    static let shared = AuthService() // シングルトン
    private init() {}

    func signInAnonymously(completion: @escaping (Result<String, Error>) -> Void) {
        Auth.auth().signInAnonymously { authResult, error in
            if let error = error {
                print("Error signing in anonymously: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            guard let user = authResult?.user else {
                completion(.failure(BeerError.unknown))
                return
            }
            print("Signed in anonymously with UID: \(user.uid)")
            completion(.success(user.uid))
        }
    }

    func getCurrentUserId() -> String? {
        return Auth.auth().currentUser?.uid
    }
}
