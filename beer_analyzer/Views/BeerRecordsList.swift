
//
//  BeerRecordsList.swift
//  beer_analyzer
//

import SwiftUI

struct BeerRecordsList: View {
    let recordedBeers: [BeerRecord]
    let onDelete: (String) -> Void
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 10) {
                Text("記録されたビール")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.bottom, 5)

                if recordedBeers.isEmpty {
                    Text("まだ記録されたビールはありません。")
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                } else {
                    List {
                        ForEach(recordedBeers.sorted(by: { $0.timestamp > $1.timestamp })) { beer in
                            BeerRecordRow(beer: beer) { idToDelete in
                                onDelete(idToDelete)
                            }
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .listRowInsets(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
                        }
                    }
                    .listStyle(.plain)
                    .frame(height: min(CGFloat(recordedBeers.count) * 100 + 20, 400))
                }
            }
            .padding()
            .background(Color.white.opacity(0.8))
            .cornerRadius(20)
            .shadow(radius: 5)
        }
    }
}
