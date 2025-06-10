//
//  TermsOfUseView.swift
//  beer_analyzer
//
//  Created by Jules on 2023/10/27. // Placeholder for actual date
//

import SwiftUI

struct TermsOfUseView: View {
    // Action to perform when terms are accepted
    var onAccept: () -> Void
    var isPresentedForAcceptance: Bool // New property

    // Placeholder for actual Terms of Use text
    let termsText: String = """
    IMPORTANT: PLEASE READ THESE TERMS OF USE CAREFULLY.

    Last Updated: October 27, 2023 (Placeholder Date)

    1. Introduction
    Welcome to Beer Analyzer App! These Terms of Use ("Terms") govern your use of our mobile application ("App"). By downloading, accessing, or using our App, you agree to be bound by these Terms. If you do not agree to these Terms, do not use the App.

    2. License to Use the App
    We grant you a limited, non-exclusive, non-transferable, revocable license to use the App for your personal, non-commercial purposes, subject to these Terms.

    3. User Conduct
    You agree not to use the App for any unlawful purpose or in any way that could damage, disable, overburden, or impair the App. You agree not to attempt to gain unauthorized access to any part of the App.

    4. Intellectual Property
    All content, features, and functionality of the App, including but not limited to text, graphics, logos, and software, are the exclusive property of [Your Company Name] or its licensors and are protected by copyright and other intellectual property laws.

    5. Disclaimers
    THE APP IS PROVIDED "AS IS" AND "AS AVAILABLE" WITHOUT ANY WARRANTIES OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR NON-INFRINGEMENT. WE DO NOT WARRANT THAT THE APP WILL BE UNINTERRUPTED, ERROR-FREE, OR FREE OF VIRUSES OR OTHER HARMFUL COMPONENTS.

    6. Limitation of Liability
    TO THE FULLEST EXTENT PERMITTED BY APPLICABLE LAW, [YOUR COMPANY NAME] SHALL NOT BE LIABLE FOR ANY INDIRECT, INCIDENTAL, SPECIAL, CONSEQUENTIAL, OR PUNITIVE DAMAGES, OR ANY LOSS OF PROFITS OR REVENUES, WHETHER INCURRED DIRECTLY OR INDIRECTLY, OR ANY LOSS OF DATA, USE, GOODWILL, OR OTHER INTANGIBLE LOSSES, RESULTING FROM (A) YOUR ACCESS TO OR USE OF OR INABILITY TO ACCESS OR USE THE APP; (B) ANY CONDUCT OR CONTENT OF ANY THIRD PARTY ON THE APP; OR (C) UNAUTHORIZED ACCESS, USE, OR ALTERATION OF YOUR TRANSMISSIONS OR CONTENT.

    7. Changes to Terms
    We reserve the right to modify these Terms at any time. We will notify you of any changes by posting the new Terms within the App. Your continued use of the App after such changes constitutes your acceptance of the new Terms.

    8. Governing Law
    These Terms shall be governed and construed in accordance with the laws of [Your Jurisdiction], without regard to its conflict of law provisions.

    9. Contact Us
    If you have any questions about these Terms, please contact us at [Your Contact Email/Link].

    ---
    By clicking "Accept", you acknowledge that you have read, understood, and agree to be bound by these Terms of Use.
    """

    var body: some View {
        VStack {
            Text("Terms of Use")
                .font(.largeTitle)
                .padding(.top)

            ScrollView {
                Text(termsText)
                    .font(.body)
                    .padding()
            }

            if isPresentedForAcceptance { // Conditional button
                Button(action: onAccept) {
                    Text("Accept")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
            }
        }
    }
}

struct TermsOfUseView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            TermsOfUseView(onAccept: {
                print("Terms Accepted (Preview - for acceptance)")
            }, isPresentedForAcceptance: true)
            .previewDisplayName("For Acceptance")

            TermsOfUseView(onAccept: {}, isPresentedForAcceptance: false)
                .previewDisplayName("For Viewing")
        }
    }
}
