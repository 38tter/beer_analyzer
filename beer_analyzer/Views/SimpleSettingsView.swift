//
//  SimpleSettingsView.swift
//  beer_analyzer
//
//  Created by Claude Code on 2025/06/11.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
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
                        
                        Text(NSLocalizedString("app_name", comment: ""))
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(NSLocalizedString("app_version", comment: ""))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
                
                // Settings Options
                Section(NSLocalizedString("settings", comment: "")) {
                    Button {
                        showingTerms = true
                    } label: {
                        HStack {
                            Image(systemName: "doc.text.fill")
                                .foregroundColor(.blue)
                            Text(NSLocalizedString("terms_of_use", comment: ""))
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
                            Text(NSLocalizedString("privacy_policy", comment: ""))
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
                            Text(NSLocalizedString("version_history", comment: ""))
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
                            Text(NSLocalizedString("contact_us", comment: ""))
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    }
                }
                
                // Developer Info
                Section(NSLocalizedString("developer_info", comment: "")) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(NSLocalizedString("developed_by", comment: ""))
                            .font(.subheadline)
                        Text("odradek38@gmail.com")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle(NSLocalizedString("settings", comment: ""))
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
                        Text(NSLocalizedString("version_history_title", comment: ""))
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(NSLocalizedString("version_history_subtitle", comment: ""))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text(NSLocalizedString("version_date", comment: ""))
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text(NSLocalizedString("feature_beer_analysis", comment: ""))
                            Text(NSLocalizedString("feature_beer_management", comment: ""))
                            Text(NSLocalizedString("feature_infinite_scroll", comment: ""))
                            Text(NSLocalizedString("feature_sort", comment: ""))
                            Text(NSLocalizedString("feature_drink_status", comment: ""))
                            Text(NSLocalizedString("feature_website_links", comment: ""))
                            Text(NSLocalizedString("feature_loading_animation", comment: ""))
                            Text(NSLocalizedString("feature_terms", comment: ""))
                            Text(NSLocalizedString("feature_settings", comment: ""))
                        }
                        .font(.body)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                .padding()
            }
            .navigationTitle(NSLocalizedString("version_history", comment: ""))
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
                    
                    Text(NSLocalizedString("contact_title", comment: ""))
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(NSLocalizedString("contact_description", comment: ""))
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
                            Text(NSLocalizedString("send_email", comment: ""))
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
                        Text(NSLocalizedString("email_address_label", comment: ""))
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
            .navigationTitle(NSLocalizedString("contact_us", comment: ""))
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
        .alert(NSLocalizedString("email_app_error_title", comment: ""), isPresented: $showingEmailAlert) {
            Button(NSLocalizedString("ok", comment: "")) {}
        } message: {
            Text(String(format: NSLocalizedString("email_app_error_message", comment: ""), emailAddress))
        }
    }
    
    private func openMailApp() {
        let subject = NSLocalizedString("email_subject", comment: "")
        let body = String(format: NSLocalizedString("email_body_app_info", comment: ""), UIDevice.current.model, UIDevice.current.systemVersion)
        
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
                        Text(NSLocalizedString("privacy_policy_title", comment: ""))
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(NSLocalizedString("privacy_policy_subtitle", comment: ""))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        privacySection(
                            title: NSLocalizedString("privacy_section_1_title", comment: ""),
                            content: NSLocalizedString("privacy_section_1_content", comment: "")
                        )
                        
                        privacySection(
                            title: NSLocalizedString("privacy_section_2_title", comment: ""),
                            content: NSLocalizedString("privacy_section_2_content", comment: "")
                        )
                        
                        privacySection(
                            title: NSLocalizedString("privacy_section_3_title", comment: ""),
                            content: NSLocalizedString("privacy_section_3_content", comment: "")
                        )
                        
                        privacySection(
                            title: NSLocalizedString("privacy_section_4_title", comment: ""),
                            content: NSLocalizedString("privacy_section_4_content", comment: "")
                        )
                        
                        privacySection(
                            title: NSLocalizedString("privacy_section_5_title", comment: ""),
                            content: NSLocalizedString("privacy_section_5_content", comment: "")
                        )
                        
                        Text(NSLocalizedString("last_updated", comment: ""))
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top, 20)
                    }
                }
                .padding()
            }
            .navigationTitle(NSLocalizedString("privacy_policy", comment: ""))
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
}