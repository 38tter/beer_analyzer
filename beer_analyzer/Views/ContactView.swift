//
//  ContactView.swift
//  beer_analyzer
//
//  Created by Claude Code on 2025/06/11.
//

import SwiftUI
import SafariServices

struct ContactView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showingGoogleForm = false
    @State private var showingEmailAlert = false
    
    // Google フォームのURL - Beer Analyzer お問い合わせフォーム
    // このURLは実際のGoogleフォームを作成後に置き換える必要があります
    private let googleFormURL = "https://forms.gle/beer-analyzer-contact-form"
    private let emailAddress = "odradek38@gmail.com"
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // ヘッダー
                    VStack(spacing: 16) {
                        Image(systemName: "envelope.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        Text("お問い合わせ")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("ご質問、ご要望、バグ報告など\nお気軽にお問い合わせください")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    
                    // お問い合わせ方法
                    VStack(spacing: 16) {
                        // Google フォーム
                        ContactMethodCard(
                            icon: "doc.fill",
                            title: "お問い合わせフォーム",
                            description: "Google フォームから簡単にお問い合わせいただけます（推奨）",
                            buttonText: "フォームを開く",
                            buttonColor: .blue
                        ) {
                            showingGoogleForm = true
                        }
                        
                        // メール
                        ContactMethodCard(
                            icon: "envelope.fill",
                            title: "メールでお問い合わせ",
                            description: "メールアプリから直接お問い合わせいただけます",
                            buttonText: "メールを送信",
                            buttonColor: .green
                        ) {
                            openMailApp()
                        }
                    }
                    
                    // お問い合わせ内容の例
                    VStack(alignment: .leading, spacing: 12) {
                        Text("お問い合わせ内容の例")
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            ContactExampleRow(icon: "🐛", text: "バグ報告・不具合について")
                            ContactExampleRow(icon: "💡", text: "新機能のご要望・改善提案")
                            ContactExampleRow(icon: "❓", text: "アプリの使い方に関する質問")
                            ContactExampleRow(icon: "⭐", text: "アプリへのご感想・レビュー")
                            ContactExampleRow(icon: "🤝", text: "その他のお問い合わせ")
                        }
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.thinMaterial)
                    )
                    
                    // 注意事項
                    VStack(alignment: .leading, spacing: 8) {
                        Text("注意事項")
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("• お返事には数日お時間をいただく場合があります")
                            Text("• 技術的な問題については詳細な情報をお教えください")
                            Text("• お問い合わせ内容は今後の開発の参考にさせていただきます")
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.orange.opacity(0.1))
                            .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                    )
                    
                    Spacer(minLength: 20)
                }
                .padding(.horizontal, 20)
            }
            .navigationTitle("お問い合わせ")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .sheet(isPresented: $showingGoogleForm) {
            if let url = URL(string: googleFormURL) {
                SafariView(url: url)
                    .ignoresSafeArea()
            }
        }
        .alert("メールアプリを開けませんでした", isPresented: $showingEmailAlert) {
            Button("OK") {}
        } message: {
            Text("メールアプリが利用できません。以下のアドレスに直接メールをお送りください：\n\(emailAddress)")
        }
    }
    
    private func openMailApp() {
        let subject = "Beer Analyzer お問い合わせ"
        let body = """
        
        
        ━━━━━━━━━━━━━━━━━━━━━━
        アプリ情報
        ━━━━━━━━━━━━━━━━━━━━━━
        アプリ名: Beer Analyzer
        バージョン: \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0")
        ビルド番号: \(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1")
        端末: \(UIDevice.current.model)
        iOS: \(UIDevice.current.systemVersion)
        """
        
        let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let encodedBody = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        if let url = URL(string: "mailto:\(emailAddress)?subject=\(encodedSubject)&body=\(encodedBody)") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            } else {
                showingEmailAlert = true
            }
        } else {
            showingEmailAlert = true
        }
    }
}

struct ContactMethodCard: View {
    let icon: String
    let title: String
    let description: String
    let buttonText: String
    let buttonColor: Color
    let action: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(buttonColor)
                    .frame(width: 28, height: 28)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
            }
            
            Button {
                action()
            } label: {
                Text(buttonText)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(buttonColor)
                    .cornerRadius(12)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.regularMaterial)
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
    }
}

struct ContactExampleRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 8) {
            Text(icon)
                .font(.body)
            
            Text(text)
                .font(.body)
                .foregroundColor(.primary)
            
            Spacer()
        }
    }
}

// SafariView for Google Form
struct SafariView: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
        // No update needed
    }
}

#Preview {
    ContactView()
}