//
//  CustomAlertView.swift
//  beer_analyzer
//
//  Created by 宮田聖也 on 2025/06/09.
//

import SwiftUI

struct CustomAlertView: View {
    let title: String
    let message: String
    var confirmAction: () -> Void

    var body: some View {
        ZStack {
            // 背景のオーバーレイ
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    // 背景タップで閉じないようにすることも可能
                    // confirmAction()
                }

            // アラートボックス
            VStack(spacing: 20) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.black)
                    .padding(.top, 10)

                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 15)

                Divider()

                Button("OK") {
                    confirmAction()
                }
                .font(.body)
                .fontWeight(.bold)
                .foregroundColor(.blue)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            }
            .frame(width: 280)
            .padding(.bottom, 5) // ボタンとの間隔を調整
            .background(Color.white)
            .cornerRadius(15)
            .shadow(radius: 10)
        }
    }
}
