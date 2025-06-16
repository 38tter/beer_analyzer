//
//  SimpleSettingsView.swift
//  beer_analyzer
//
//  Created by Claude Code on 2025/06/11.
//

import SwiftUI
import Foundation

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var localizationService: LocalizationService
    @State private var showingTerms = false
    @State private var showingPrivacyPolicy = false
    @State private var showingVersionHistory = false
    @State private var showingContact = false
    
    var body: some View {
        NavigationView {
            List {
                // App Info Section
                Section {
                    VStack(spacing: 12) {
                        Image("AppTitleLogo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 200, height: 112)
                        
                        Text("Beer Analyzer")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Version 1.0.0")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
                
                // Language Selection
                Section(localizationService.language) {
                    HStack {
                        Image(systemName: "globe")
                            .foregroundColor(.blue)
                        Picker(localizationService.language, selection: Binding(
                            get: { localizationService.currentLanguage },
                            set: { newValue in localizationService.setLanguage(newValue) }
                        )) {
                            Text("日本語").tag(LocalizationService.AppLanguage.japanese)
                            Text("English").tag(LocalizationService.AppLanguage.english)
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                }
                
                // Settings Options
                Section(localizationService.settings) {
                    Button {
                        showingTerms = true
                    } label: {
                        HStack {
                            Image(systemName: "doc.text.fill")
                                .foregroundColor(.blue)
                            Text(localizationService.termsOfUse)
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    }
                    
                    Button {
                        showingPrivacyPolicy = true
                    } label: {
                        HStack {
                            Image(systemName: "hand.raised.fill")
                                .foregroundColor(.blue)
                            Text(localizationService.privacyPolicy)
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    }
                    
                    Button {
                        showingVersionHistory = true
                    } label: {
                        HStack {
                            Image(systemName: "clock.arrow.circlepath")
                                .foregroundColor(.blue)
                            Text("バージョン更新履歴")
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    }
                    
                    Button {
                        showingContact = true
                    } label: {
                        HStack {
                            Image(systemName: "envelope.fill")
                                .foregroundColor(.blue)
                            Text("お問い合わせ")
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    }
                }
                
                // Developer Info
                Section("開発者情報") {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Developed by 38tter")
                            .font(.subheadline)
                        Text("odradek38@gmail.com")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle(localizationService.settings)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .sheet(isPresented: $showingTerms) {
            TermsOfUseView(
                onAccept: {},
                isPresentedForAcceptance: false,
                showCloseButton: true
            )
        }
        .sheet(isPresented: $showingPrivacyPolicy) {
            PrivacyPolicyView()
        }
        .sheet(isPresented: $showingVersionHistory) {
            SimpleVersionHistoryView()
        }
        .sheet(isPresented: $showingContact) {
            SimpleContactView()
        }
    }
}

struct SimpleVersionHistoryView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(spacing: 16) {
                        Text("バージョン更新履歴")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Beer Analyzerの更新内容")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Version 1.0.0 - 2025年6月11日")
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("• ビール画像解析機能")
                            Text("• ビール情報の保存・管理")
                            Text("• 無限スクロール対応")
                            Text("• ソート機能")
                            Text("• 飲酒ステータス記録")
                            Text("• 公式サイトリンク表示")
                            Text("• アニメーション付きローディング")
                            Text("• 利用規約の実装")
                            Text("• 設定画面の追加")
                        }
                        .font(.body)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                .padding()
            }
            .navigationTitle("更新履歴")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
}

struct SimpleContactView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showingEmailAlert = false
    
    private let emailAddress = "odradek38@gmail.com"
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    Image(systemName: "envelope.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("お問い合わせ")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("ご質問、ご要望、バグ報告など\nお気軽にお問い合わせください")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 40)
                
                VStack(spacing: 16) {
                    Button {
                        openMailApp()
                    } label: {
                        HStack {
                            Image(systemName: "envelope.fill")
                                .font(.title2)
                            Text("メールを送信")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                    }
                    
                    VStack(spacing: 8) {
                        Text("メールアドレス")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(emailAddress)
                            .font(.body)
                            .foregroundColor(.primary)
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("お問い合わせ")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
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
        バージョン: 1.0.0
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

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(spacing: 16) {
                        Text("プライバシーポリシー")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Beer Analyzer プライバシーポリシー")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        privacySection(
                            title: "1. 収集する情報",
                            content: """
                            本アプリでは、以下の情報を収集する場合があります：
                            • ビール画像の解析データ
                            • アプリの使用状況（匿名）
                            • エラーログ（匿名）
                            """
                        )
                        
                        privacySection(
                            title: "2. 情報の利用目的",
                            content: """
                            収集した情報は以下の目的で利用します：
                            • ビール解析機能の提供・改善
                            • アプリの安定性向上
                            • ユーザーサポート
                            """
                        )
                        
                        privacySection(
                            title: "3. 情報の共有",
                            content: """
                            個人を特定できる情報を第三者と共有することはありません。
                            匿名化された統計データのみを品質向上の目的で利用する場合があります。
                            """
                        )
                        
                        privacySection(
                            title: "4. データの保存",
                            content: """
                            ビール記録データは安全に暗号化されてクラウドに保存されます。
                            お客様はいつでもデータの削除を要求できます。
                            """
                        )
                        
                        privacySection(
                            title: "5. お問い合わせ",
                            content: """
                            プライバシーに関するご質問は以下までお問い合わせください：
                            odradek38@gmail.com
                            """
                        )
                        
                        Text("最終更新日: 2025年6月11日")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top, 20)
                    }
                }
                .padding()
            }
            .navigationTitle("プライバシーポリシー")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
    
    private func privacySection(title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .fontWeight(.bold)
            
            Text(content)
                .font(.body)
                .foregroundColor(.primary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    SettingsView()
        .environmentObject(LocalizationService.shared)
}