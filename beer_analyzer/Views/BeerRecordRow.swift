
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
                Text(beer.beerName)
                    .font(.headline)
                    .foregroundColor(.indigo)
                Text("ブランド: \(beer.brand)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text("製造者: \(beer.manufacturer)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text("ABV: \(beer.abv)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text("容量: \(beer.capacity)")
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
        .background(
            ZStack {
                Color.white
                // 飲んだビールの場合は背景にビール絵文字を表示
                if beer.hasDrunk {
                    VStack {
                        HStack {
                            Spacer()
                            Text("🍺")
                                .font(.system(size: 40))
                                .opacity(0.3)
                                .offset(x: -10, y: -10)
                        }
                        Spacer()
                    }
                }
            }
        )
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
