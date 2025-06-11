//
//  TermsOfUseView.swift
//  beer_analyzer
//
//  Created by Claude Code on 2025/06/11.
//

import SwiftUI

struct TermsOfUseView: View {
    let onAccept: () -> Void
    let isPresentedForAcceptance: Bool
    let showCloseButton: Bool
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.presentationMode) private var presentationMode
    
    init(onAccept: @escaping () -> Void, isPresentedForAcceptance: Bool, showCloseButton: Bool = true) {
        self.onAccept = onAccept
        self.isPresentedForAcceptance = isPresentedForAcceptance
        self.showCloseButton = showCloseButton && !isPresentedForAcceptance
    }
    
    private let termsText = """
Beer Analyzer 利用規約

本利用規約（以下「本規約」といいます）は、38tter（以下「当社」といいます）が提供するモバイルアプリケーション「Beer Analyzer」（以下「本アプリ」といいます）の利用に関する条件を定めるものです。本アプリをご利用になる前に、本規約をよくお読みください。本アプリを利用することにより、お客様は本規約の全ての条件に同意したものとみなされます。

第1条（本規約への同意）
お客様は、本規約に同意した場合に限り、本アプリを利用することができます。

お客様が未成年である場合は、親権者その他の法定代理人の同意を得た上で本アプリを利用するものとします。

第2条（本アプリのサービス内容）
本アプリは、お客様が撮影・アップロードしたビールの画像から、銘柄、製造者、アルコール度数、ホップ等の情報をAIが解析・抽出し、記録・管理する機能を提供します。

本アプリは、記録されたビールの情報に基づき、AIがペアリング（料理やシーンなど）の提案を行う機能を提供します。

本アプリは、お客様が記録したビールの情報を保存し、閲覧できる機能を提供します。

第3条（生成AI機能の利用に関する注意）
本アプリは、最新の生成AI技術（Google Gemini等）を活用して画像解析および情報提案を行っています。

生成AIは、高度な技術を用いていますが、その性質上、生成される情報や提案には、誤り、不正確な内容、不適切な表現、または最新ではない情報が含まれる可能性があります。

お客様は、本アプリが提供する情報や提案をご自身の判断と責任において利用するものとし、その正確性、完全性、有用性について、当社はいかなる保証も行いません。

本アプリの利用により生じたいかなる損害についても、当社は一切の責任を負いません。

第4条（著作権および知的財産権）
本アプリに関する著作権、商標権、特許権その他一切の知的財産権は、当社または正当な権利者に帰属します。

お客様は、本アプリを通じて提供される情報やコンテンツを、私的利用の範囲を超えて利用（複製、改変、配布、公開など）することはできません。

お客様が本アプリにアップロードする画像に関する著作権は、お客様または正当な権利者に留保されますが、お客様は当社に対し、本アプリの運営、機能提供および改善のために、当該画像を無償で利用（複製、送信、加工、公開を含む）することを許諾するものとします。

第5条（禁止事項）
お客様は、本アプリの利用にあたり、以下の行為を行ってはなりません。

• 法令または本規約に違反する行為。
• 公序良俗に反する行為。
• 当社または第三者の権利（著作権、商標権、プライバシー権など）を侵害する行為。
• 他のお客様または第三者に不利益、損害、不快感を与える行為。
• 本アプリの運営を妨害する行為、または本アプリの信用を毀損する行為。
• コンピュータウイルス等の有害なプログラムを送信する行為。
• 本アプリを、解析や逆アセンブルするなどのリバースエンジニアリング行為。
• その他、当社が不適切と判断する行為。

第6条（免責事項）
当社は、本アプリの提供に関して、その完全性、正確性、信頼性、特定の目的への適合性、セキュリティなどについて、いかなる保証も行いません。

当社は、本アプリの利用によってお客様に生じた損害（直接的、間接的、偶発的、派生的損害を含むがこれに限られない）について、一切の責任を負いません。

当社は、本アプリの利用に関連して、お客様と第三者との間で生じた紛争について、一切の責任を負いません。

天災地変、システム障害、通信回線の障害その他当社の責に帰さない事由により本アプリの提供が中断または停止した場合でも、当社は責任を負いません。

第7条（本アプリの変更・停止・終了）
当社は、お客様に事前に通知することなく、本アプリのサービス内容を変更、追加、停止または終了することができるものとします。これによりお客様に生じたいかなる損害についても、当社は責任を負いません。

第8条（本規約の変更）
当社は、必要と判断した場合、お客様に事前に通知することなく本規約を変更できるものとします。変更後の規約は、本アプリ内に表示された時点から効力を生じるものとし、お客様は変更後の規約に従うものとします。

第9条（準拠法および管轄）
本規約の解釈にあたっては、日本法を準拠法とします。本規約に関する一切の紛争については、38tterの所在地を管轄する裁判所を第一審の専属的合意管轄裁判所とします。

制定日: 2025年6月11日
"""
    
    var body: some View {
        let contentView = VStack(spacing: 0) {
            // ヘッダー
            if isPresentedForAcceptance {
                VStack(spacing: 16) {
                    Text("利用規約への同意")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Beer Analyzerをご利用いただく前に、利用規約をお読みいただき、同意をお願いいたします。")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .background(Color(.systemGroupedBackground))
            }
            
            // 利用規約本文
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(termsText)
                        .font(.system(size: 14))
                        .lineSpacing(4)
                        .foregroundColor(.primary)
                }
                .padding()
            }
            .background(Color(.systemBackground))
            
            // 同意ボタン（初回表示時のみ）
            if isPresentedForAcceptance {
                VStack(spacing: 12) {
                    Button {
                        onAccept()
                    } label: {
                        Text("利用規約に同意してアプリを開始")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                    
                    Text("同意いただかない場合、アプリをご利用いただけません。")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .background(Color(.systemGroupedBackground))
            }
        }
        .navigationTitle(isPresentedForAcceptance ? "" : "利用規約")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if showCloseButton {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("閉じる") {
                        // Try both dismiss methods for compatibility
                        if #available(iOS 15.0, *) {
                            dismiss()
                        } else {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
            }
        }
        
        // Only wrap in NavigationView when presented for acceptance (standalone)
        if isPresentedForAcceptance {
            NavigationView {
                contentView
            }
        } else {
            contentView
        }
    }
}

#Preview {
    NavigationView {
        TermsOfUseView(onAccept: {}, isPresentedForAcceptance: false)
    }
}

#Preview("For Acceptance") {
    TermsOfUseView(onAccept: {}, isPresentedForAcceptance: true)
}

#Preview("In Tab") {
    TermsOfUseView(onAccept: {}, isPresentedForAcceptance: false, showCloseButton: false)
}