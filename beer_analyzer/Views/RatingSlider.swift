//
//  RatingSlider.swift
//  beer_analyzer
//
//  Created by 宮田聖也 on 2025/06/18.
//

import SwiftUI

struct RatingSlider: View {
    @Binding var rating: Double
    let maxRating: Double = 5.0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("評価")
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
                Text(String(format: "%.1f", rating))
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.orange)
            }
            
            HStack(spacing: 4) {
                ForEach(1...5, id: \.self) { star in
                    Image(systemName: rating >= Double(star) ? "star.fill" : 
                          rating >= Double(star) - 0.5 ? "star.leadinghalf.filled" : "star")
                        .foregroundColor(.orange)
                        .font(.title2)
                }
            }
            
            Slider(value: $rating, in: 0...maxRating, step: 0.1) {
                Text("Rating")
            }
            .accentColor(.orange)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(.regularMaterial)
                    .frame(height: 40)
            )
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.thinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            LinearGradient(
                                colors: [Color.orange.opacity(0.3), Color.yellow.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
    }
}

#Preview {
    @State var rating: Double = 3.5
    
    return VStack {
        RatingSlider(rating: $rating)
            .padding()
        
        Text("Current Rating: \(String(format: "%.1f", rating))")
            .padding()
    }
    .background(Color.gray.opacity(0.1))
}