
//
//  BeerRecordRow.swift
//  beer_analyzer
//

import SwiftUI
import Kingfisher
import SafariServices

struct BeerRecordRow: View {
    let beer: BeerRecord
    var onDelete: (String) -> Void
    
    @State private var showingSafari = false

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
            
            // MARK: - 公式サイトリンクアイコン
            VStack {
                if let websiteUrlString = beer.websiteUrl, 
                   !websiteUrlString.isEmpty,
                   let _ = URL(string: websiteUrlString) {
                    Button {
                        showingSafari = true
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: "link.circle.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.blue)
                            Text("公式サイト")
                                .font(.caption2)
                                .foregroundColor(.blue)
                                .fontWeight(.medium)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.blue.opacity(0.1))
                                .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.top, 4)
                }
                Spacer()
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
                        Spacer()
                        HStack {
                            Spacer()
                            Text("🍺")
                                .font(.system(size: 60))
                                .opacity(0.2)
                                .padding(.trailing, 8)
                                .padding(.bottom, 8)
                        }
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
        .sheet(isPresented: $showingSafari) {
            if let websiteUrlString = beer.websiteUrl,
               let url = URL(string: websiteUrlString) {
                SafariView(url: url)
                    .ignoresSafeArea()
            }
        }
    }
}

// MARK: - SafariView（アプリ内ブラウザ）
struct SafariView: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
        // 更新処理は不要
    }
}
