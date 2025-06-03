
//
//  BeerRecordRow.swift
//  beer_analyzer
//

import SwiftUI
import Kingfisher

struct BeerRecordRow: View {
    let beer: BeerRecord
    var onDelete: (String) -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            // MARK: - ビール画像を表示
            if let imageUrlString = beer.imageUrl, let imageUrl = URL(string: imageUrlString) {
                KFImage(imageUrl)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            } else {
                Image(systemName: "photo.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80)
                    .foregroundColor(.gray)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(beer.brand)
                    .font(.headline)
                    .foregroundColor(.indigo)
                Text("製造者: \(beer.manufacturer)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text("ABV: \(beer.abv)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text("ホップ: \(beer.hops)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text("記録日時: \(beer.timestamp.formatted())")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
        .contentShape(Rectangle())
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                if let id = beer.id {
                    onDelete(id)
                }
            } label: {
                Label("削除", systemImage: "trash")
            }
        }
    }
}
