
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
    @State private var showingWebsiteError = false

    var body: some View {
        ZStack {
            // MARK: - 背景画像（ブラー効果付き）
            Group {
                if let imageUrlString = beer.imageUrl, let imageUrl = URL(string: imageUrlString) {
                    KFImage(imageUrl)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .blur(radius: 8)
                        .overlay(
                            Rectangle()
                                .fill(Color.black.opacity(0.3))
                        )
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .overlay(
                            Image(systemName: "photo.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.gray.opacity(0.5))
                        )
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 10))
            
            // MARK: - コンテンツ
            VStack(alignment: .leading, spacing: 12) {
                // MARK: - ビール情報
                VStack(alignment: .leading, spacing: 6) {
                    Text(beer.beerName)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.8), radius: 1, x: 1, y: 1)
                    
                    Text("ブランド: \(beer.brand)")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                        .shadow(color: .black.opacity(0.8), radius: 1, x: 1, y: 1)
                    
                    Text("製造者: \(beer.manufacturer)")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                        .shadow(color: .black.opacity(0.8), radius: 1, x: 1, y: 1)
                    
                    HStack {
                        Text("ABV: \(beer.abv)")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.9))
                            .shadow(color: .black.opacity(0.8), radius: 1, x: 1, y: 1)
                        
                        Spacer()
                        
                        Text("容量: \(beer.capacity)")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.9))
                            .shadow(color: .black.opacity(0.8), radius: 1, x: 1, y: 1)
                    }
                    
                    Text("ホップ: \(beer.hops)")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                        .shadow(color: .black.opacity(0.8), radius: 1, x: 1, y: 1)
                    
                    // レーティング表示（存在する場合のみ）
                    if let rating = beer.rating, rating > 0 {
                        HStack(spacing: 4) {
                            Text(NSLocalizedString("rating", comment: "") + ":")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.9))
                                .shadow(color: .black.opacity(0.8), radius: 1, x: 1, y: 1)
                            
                            ForEach(1...5, id: \.self) { star in
                                Image(systemName: rating >= Double(star) ? "star.fill" : 
                                      rating >= Double(star) - 0.5 ? "star.leadinghalf.filled" : "star")
                                    .foregroundColor(.yellow)
                                    .font(.caption)
                                    .shadow(color: .black.opacity(0.8), radius: 1, x: 1, y: 1)
                            }
                            
                            Text(String(format: "%.1f", rating))
                                .font(.caption)
                                .foregroundColor(.yellow)
                                .fontWeight(.medium)
                                .shadow(color: .black.opacity(0.8), radius: 1, x: 1, y: 1)
                        }
                    }
                }
                
                Spacer()
                
                // MARK: - 下部情報（日時とリンク）
                HStack {
                    Text("記録日時: \(beer.timestamp.formatted())")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                        .shadow(color: .black.opacity(0.8), radius: 1, x: 1, y: 1)
                    
                    Spacer()
                    
                    // 公式サイトリンク
                    if let websiteUrlString = beer.websiteUrl, 
                       !websiteUrlString.isEmpty,
                       let _ = URL(string: websiteUrlString) {
                        Button {
                            if let websiteUrlString = beer.websiteUrl,
                               let url = URL(string: websiteUrlString),
                               canOpenURL(url) {
                                showingSafari = true
                            } else {
                                showingWebsiteError = true
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "link.circle.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(.white)
                                Text("リンク")
                                    .font(.caption2)
                                    .foregroundColor(.white)
                                    .fontWeight(.medium)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.black.opacity(0.3))
                                    .stroke(Color.white.opacity(0.5), lineWidth: 0.5)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    // 飲んだビールの場合はビール絵文字を表示
                    if beer.hasDrunk {
                        Text("🍺")
                            .font(.system(size: 20))
                            .shadow(color: .black.opacity(0.8), radius: 1, x: 1, y: 1)
                    }
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
        }
        .frame(height: 140)
        .background(Color.clear)
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
            .tint(.red)
        }
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .sheet(isPresented: $showingSafari) {
            if let websiteUrlString = beer.websiteUrl,
               let url = URL(string: websiteUrlString) {
                SafariView(url: url, showingError: $showingWebsiteError)
                    .ignoresSafeArea()
            }
        }
        .alert("公式サイトを開けません", isPresented: $showingWebsiteError) {
            Button("OK") {
                // アラートを閉じるだけ
            }
        } message: {
            Text("申し訳ございませんが、この公式サイトのリンクを開くことができませんでした。")
        }
    }
    
    // MARK: - Helper function to check if URL can be opened
    private func canOpenURL(_ url: URL) -> Bool {
        // Check if URL scheme is supported (http, https)
        guard let scheme = url.scheme?.lowercased() else { return false }
        return scheme == "http" || scheme == "https"
    }
}

// MARK: - SafariView（アプリ内ブラウザ）
struct SafariView: UIViewControllerRepresentable {
    let url: URL
    @Binding var showingError: Bool
    
    init(url: URL, showingError: Binding<Bool> = .constant(false)) {
        self.url = url
        self._showingError = showingError
    }
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        let safariViewController = SFSafariViewController(url: url)
        safariViewController.delegate = context.coordinator
        return safariViewController
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
        // 更新処理は不要
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, SFSafariViewControllerDelegate {
        let parent: SafariView
        
        init(_ parent: SafariView) {
            self.parent = parent
        }
        
        func safariViewController(_ controller: SFSafariViewController, didCompleteInitialLoad didLoadSuccessfully: Bool) {
            if !didLoadSuccessfully {
                DispatchQueue.main.async {
                    controller.dismiss(animated: true) {
                        self.parent.showingError = true
                    }
                }
            }
        }
    }
}

// MARK: - Custom Button Style for Delete Action
struct RoundedDeleteButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.red)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}
