
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
        HStack(alignment: .top, spacing: 10) {
            // MARK: - 画像とリンクのセクション
            VStack(spacing: 8) {
                // ビール画像
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
                        .background(Color.gray.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                
                // 公式サイトリンク（画像の下）
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
                                .font(.system(size: 14))
                                .foregroundColor(.blue)
                            Text("リンク")
                                .font(.caption2)
                                .foregroundColor(.blue)
                                .fontWeight(.medium)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.blue.opacity(0.1))
                                .stroke(Color.blue.opacity(0.3), lineWidth: 0.5)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .frame(width: 80) // 固定幅でレイアウトを安定させる
            
            // MARK: - ビール情報
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
                
                // レーティング表示（存在する場合のみ）
                if let rating = beer.rating, rating > 0 {
                    HStack(spacing: 4) {
                        Text(NSLocalizedString("rating", comment: "") + ":")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        ForEach(1...5, id: \.self) { star in
                            Image(systemName: rating >= Double(star) ? "star.fill" : 
                                  rating >= Double(star) - 0.5 ? "star.leadinghalf.filled" : "star")
                                .foregroundColor(.orange)
                                .font(.caption)
                        }
                        
                        Text(String(format: "%.1f", rating))
                            .font(.caption)
                            .foregroundColor(.orange)
                            .fontWeight(.medium)
                    }
                }
                
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
