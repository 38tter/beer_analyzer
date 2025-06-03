
//
//  InfoRow.swift
//  beer_analyzer
//

import SwiftUI

struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text("\(label):")
                .fontWeight(.semibold)
                .foregroundColor(.indigo)
            Spacer()
            Text(value)
                .foregroundColor(.gray)
        }
        .font(.body)
    }
}
