//
//  SettingsView.swift
//  beer_analyzer
//
//  Created by Claude Code on 2025/06/11.
//

import SwiftUI
import SafariServices

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showingTerms = false
    @State private var showingVersionHistory = false
    @State private var showingContact = false
    
    // アプリバージョン情報
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
    
    private var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // アプリ情報セクション
                    VStack(spacing: 16) {
                        Image("AppTitleLogo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 200, height: 112)
                        
                        VStack(spacing: 8) {
                            Text("Beer Analyzer")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.blue, .indigo],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                            
                            Text("ビール解析アプリ")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Text("Version \(appVersion) (\(buildNumber))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.top, 20)
                    
                    // 設定メニュー
                    VStack(spacing: 0) {
                        SettingsMenuRow(
                            icon: "doc.text.fill",
                            title: "利用規約",
                            description: "アプリの利用規約を確認する"
                        ) {
                            showingTerms = true
                        }
                        
                        Divider()
                            .padding(.leading, 60)
                        
                        SettingsMenuRow(
                            icon: "clock.arrow.circlepath",
                            title: "バージョン更新履歴",
                            description: "アプリの更新内容を確認する"
                        ) {
                            showingVersionHistory = true
                        }
                        
                        Divider()
                            .padding(.leading, 60)
                        
                        SettingsMenuRow(
                            icon: "envelope.fill",
                            title: "お問い合わせ",
                            description: "開発者にお問い合わせする"
                        ) {
                            showingContact = true
                        }
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.regularMaterial)
                    )
                    
                    // 開発者情報
                    VStack(spacing: 12) {
                        Text("開発者情報")
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        VStack(spacing: 8) {
                            Text("Developed by 38tter")
                                .font(.subheadline)
                                .foregroundColor(.primary)
                            
                            Text("お問い合わせ: odradek38@gmail.com")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.thinMaterial)
                    )
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 20)
            }
            .navigationTitle("設定")
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
        .sheet(isPresented: $showingTerms) {
            TermsOfUseView(
                onAccept: {},
                isPresentedForAcceptance: false,
                showCloseButton: true
            )
        }
        .sheet(isPresented: $showingVersionHistory) {
            VersionHistoryView()
        }
        .sheet(isPresented: $showingContact) {
            ContactView()
        }
    }
}

struct SettingsMenuRow: View {
    let icon: String
    let title: String
    let description: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.blue)
                    .frame(width: 28, height: 28)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    SettingsView()
}