
//
//  PairingSuggestionView.swift
//  beer_analyzer
//

import SwiftUI

struct PairingSuggestionView: View {
    let pairingSuggestion: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("ペアリング提案")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.bottom, 5)

            Text(pairingSuggestion)
                .font(.body)
                .padding(.horizontal)
        }
        .padding()
        .background(Color.white.opacity(0.8))
        .cornerRadius(20)
        .shadow(radius: 5)
    }
}
