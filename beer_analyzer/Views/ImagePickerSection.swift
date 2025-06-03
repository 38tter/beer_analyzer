
//
//  ImagePickerSection.swift
//  beer_analyzer
//

import SwiftUI
import PhotosUI

struct ImagePickerSection: View {
    @Binding var selectedImage: PhotosPickerItem?
    @Binding var uiImage: UIImage?
    @Binding var errorMessage: String?
    
    var onImageSelected: () -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("ビールの写真をアップロードまたは撮影")
                .font(.headline)

            // iOS 16+ の PhotosPicker
            PhotosPicker(selection: $selectedImage, matching: .images) {
                Label("写真を選択", systemImage: "photo")
                    .font(.title3)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(15)
            }
            .onChange(of: selectedImage) { newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                        if let image = UIImage(data: data) {
                            uiImage = image
                            onImageSelected()
                        }
                    }
                }
            }

            // カメラからの撮影
            Button {
                errorMessage = "カメラ機能は現在デモ版では未実装です。写真を選択してください。"
            } label: {
                Label("カメラで撮影", systemImage: "camera")
                    .font(.title3)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(15)
            }
        }
        .padding()
        .background(Color.white.opacity(0.8))
        .cornerRadius(20)
        .shadow(radius: 5)
    }
}
