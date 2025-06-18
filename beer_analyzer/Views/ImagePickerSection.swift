
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
    @Binding var analysisResult: BeerAnalysisResult?
    @Binding var pairingSuggestion: String?
    @Binding var showingImagePicker: Bool
    
    @State private var selectedImageForPreview: UIImage? // プレビュー用画像
    
    var onImageSelected: () -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(NSLocalizedString("upload_or_take_photo", comment: ""))
                .font(.headline)

            // iOS 16+ の PhotosPicker
            PhotosPicker(selection: $selectedImage, matching: .images) {
                Label(NSLocalizedString("select_photo", comment: ""), systemImage: "photo")
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
                self.showingImagePicker = true
                self.selectedImageForPreview = nil
                self.analysisResult = nil
                self.pairingSuggestion = nil
                self.errorMessage = nil
            } label: {
                Label(NSLocalizedString("take_photo", comment: ""), systemImage: "camera")
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
