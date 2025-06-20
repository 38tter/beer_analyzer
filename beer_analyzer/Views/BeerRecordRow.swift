
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
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: 0) {
            // MARK: - 上半分：画像
            ZStack {
                if let imageUrlString = beer.imageUrl, let imageUrl = URL(string: imageUrlString) {
                    KFImage(imageUrl)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    Image(systemName: "photo.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .foregroundColor(.gray)
                        .background(Color.gray.opacity(0.1))
                }
                
                // 飲んだビールの場合は背景にビール絵文字を表示
                if beer.hasDrunk {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Text("🍺")
                                .font(.system(size: 30))
                                .opacity(0.3)
                                .padding(.trailing, 8)
                                .padding(.bottom, 8)
                        }
                    }
                }
                
            }
            .frame(height: 140)
            .clipped()
            
            // MARK: - 下半分：情報
            VStack(alignment: .leading, spacing: 6) {
                // タイトル
                Text(beer.beerName)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(colorScheme == .dark ? .white : .indigo)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                // レーティング（星マーク付き）
                if let rating = beer.rating, rating > 0 {
                    HStack(spacing: 2) {
                        ForEach(1...5, id: \.self) { star in
                            Image(systemName: rating >= Double(star) ? "star.fill" : 
                                  rating >= Double(star) - 0.5 ? "star.leadinghalf.filled" : "star")
                                .foregroundColor(.orange)
                                .font(.caption2)
                        }
                        
                        Text(String(format: "%.1f", rating))
                            .font(.caption)
                            .foregroundColor(colorScheme == .dark ? .yellow : .orange)
                            .fontWeight(.medium)
                    }
                }
                
                // 製造者
                HStack(spacing: 4) {
                    Text("🏭")
                        .font(.caption)
                    Text(beer.manufacturer)
                        .font(.caption)
                        .foregroundColor(colorScheme == .dark ? .white.opacity(0.8) : .secondary)
                        .lineLimit(1)
                }
                
                // アルコール度数
                HStack(spacing: 4) {
                    Text("🍺")
                        .font(.caption)
                    Text(beer.abv + "%")
                        .font(.caption)
                        .foregroundColor(colorScheme == .dark ? .white.opacity(0.8) : .secondary)
                        .lineLimit(1)
                }
                
                // 公式サイトリンク（絵文字付き）
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
                            Text("🔗")
                                .font(.caption)
                            Text("リンク")
                                .font(.caption)
                                .foregroundColor(colorScheme == .dark ? .cyan : .blue)
                                .fontWeight(.medium)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 8)
            .padding(.vertical, 10)
            .frame(height: 120)
        }
        .frame(maxWidth: .infinity)
        .aspectRatio(1.0, contentMode: .fit)
        .background(colorScheme == .dark ? Color(.systemGray6) : Color.white)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .contextMenu {
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
