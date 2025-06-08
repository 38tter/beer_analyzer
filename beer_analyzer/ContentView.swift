//
//  ContentView.swift
//  beer_analyzer
//
//  Created by 宮田聖也 on 2025/06/02.
//

import SwiftUI
import PhotosUI
import FirebaseRemoteConfig
import Kingfisher

struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // MARK: - Title Logo
                    Image("AppTitleLogo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 320, height: 180)
                        .padding(.bottom, 10)

                    Text("ユーザーID: \(viewModel.userId ?? "認証中...")")
                        .font(.caption)
                        .foregroundColor(.gray)

                    // MARK: - Image Selection
                    ImagePickerSection(
                        selectedImage: $viewModel.selectedImage, // Bind to ViewModel's property
                        uiImage: $viewModel.uiImage, // Bind to ViewModel's property
                        errorMessage: $viewModel.errorMessage, // Bind to ViewModel's property
                        analysisResult: $viewModel.analysisResult, // Bind to ViewModel's property
                        pairingSuggestion: $viewModel.pairingSuggestion, // Bind to ViewModel's property
                        showingImagePicker: $viewModel.showingImagePicker // Bind to ViewModel's property
                    ) {
                        viewModel.resetAnalysisResults() // Call ViewModel's method
                    }

                    // MARK: - Image Preview
                    if let uiImage = viewModel.uiImage {
                        ImagePreviewSection(image: uiImage)
                    }

                    // MARK: - Analysis Button
                    AnalysisButton(
                        isLoading: viewModel.isLoadingAnalysis, // Use ViewModel's property
                        isEnabled: viewModel.uiImage != nil && !viewModel.isLoadingAnalysis // Use ViewModel's property
                    ) {
                        viewModel.analyzeBeer() // Call ViewModel's method
                    }

                    // MARK: - Error Message
                    if let errorMessage = viewModel.errorMessage {
                        ErrorMessageView(message: errorMessage)
                    }

                    // MARK: - Analysis Result
                    if let analysisResult = viewModel.analysisResult {
                        AnalysisResultView(
                            analysisResult: analysisResult,
                            isLoadingPairing: viewModel.isLoadingPairing // Use ViewModel's property
                        ) {
                            viewModel.generatePairingSuggestion() // Call ViewModel's method
                        }
                    }

                    // MARK: - Pairing Suggestion
                    if let pairingSuggestion = viewModel.pairingSuggestion {
                        PairingSuggestionView(pairingSuggestion: pairingSuggestion)
                    }

                    // MARK: - Recorded Beers List
                    BeerRecordsList(recordedBeers: viewModel.recordedBeers) { idToDelete in // Use ViewModel's property
                        Task {
                            await viewModel.deleteBeerRecord(idToDelete: idToDelete) // Call ViewModel's method
                        }
                    }
                }
                .padding()
                // .onAppear block is removed as this logic is now in ContentViewModel's init
                // MARK: - AVFoundationCameraView Sheet (replaces CameraPicker)
                .sheet(isPresented: $viewModel.showingImagePicker) { // Bind to ViewModel's property
                    AVFoundationCameraView(capturedImage: $viewModel.uiImage) // Use the new AVFoundation based camera
                        .edgesIgnoringSafeArea(.all) // Recommended for full-screen camera views
                }
            }
            .navigationBarHidden(true)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.indigo.opacity(0.2)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
        }
    }
}

// MARK: - Supporting Views
// No changes needed for Supporting Views like ImagePreviewSection, AnalysisButton, ErrorMessageView
// as they were already taking data as parameters.
// We might need to adjust ImagePickerSection and CameraPicker if they were directly using @State from ContentView
// that are now in the ViewModel. The bindings $viewModel.propertyName should handle most cases.
// BeerRecordsList, AnalysisResultView, PairingSuggestionView are fine as they receive data.
struct ImagePreviewSection: View {
    let image: UIImage

    var body: some View {
        VStack {
            Text("プレビュー")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.bottom, 5)
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxHeight: 300)
                .cornerRadius(10)
                .shadow(radius: 3)
        }
        .padding()
        .background(Color.white.opacity(0.8))
        .cornerRadius(20)
        .shadow(radius: 5)
    }
}

struct AnalysisButton: View {
    let isLoading: Bool
    let isEnabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.2)
                }
                Text(isLoading ? "解析中..." : "ビールを解析")
                    .font(.title3)
                    .fontWeight(.semibold)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(isEnabled ? Color.indigo : Color.gray)
            .foregroundColor(.white)
            .cornerRadius(15)
        }
        .disabled(!isEnabled)
        .padding(.horizontal)
    }
}

struct ErrorMessageView: View {
    let message: String

    var body: some View {
        Text(message)
            .foregroundColor(.red)
            .padding()
            .background(Color.red.opacity(0.1))
            .cornerRadius(10)
    }
}

// Assuming ImagePickerSection, CameraPicker, AnalysisResultView, PairingSuggestionView, BeerRecordsList
// are defined elsewhere or are simple enough not to require changes other than what's shown.
// For example, ImagePickerSection would change from:
// @Binding var selectedImage: PhotosPickerItem?
// to using viewModel passed in or via @EnvironmentObject
// However, the current diff passes bindings $viewModel.property, which is a common pattern.

#Preview {
    ContentView()
}
