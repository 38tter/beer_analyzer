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
    @State private var selectedImage: PhotosPickerItem?
    @State private var uiImage: UIImage?
    @State private var analysisResult: BeerAnalysisResult?
    @State private var pairingSuggestion: String?
    @State private var errorMessage: String?
    @State private var isLoadingAnalysis = false
    @State private var isLoadingPairing = false
    @State private var recordedBeers: [BeerRecord] = []
    @State private var userId: String?
    @State private var showingImagePicker = false
    @State private var showingTermsOfUse = false // New state variable
    
    // 選択されたソースタイプ（カメラまたはフォトライブラリ）
    @State private var sourceType: UIImagePickerController.SourceType = .camera
    
    @State private var showingNoBeerAlert: Bool = false
    
    @StateObject private var geminiService = GeminiAPIService()
    @EnvironmentObject var firestoreService: FirestoreService

    var body: some View {
        TabView {
            NavigationView {
                ScrollView {
                    VStack(spacing: 20) {
                        // MARK: - Title Logo
                        Image("AppTitleLogo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 320, height: 180)
                            .padding(.bottom, 10)
                        
                        Text("ユーザーID: \(userId ?? "認証中...")")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        // MARK: - Image Selection
                        ImagePickerSection(
                            selectedImage: $selectedImage,
                            uiImage: $uiImage,
                            errorMessage: $errorMessage,
                            analysisResult: $analysisResult,
                            pairingSuggestion: $pairingSuggestion,
                            showingImagePicker: $showingImagePicker
                        ) {
                            resetAnalysisResults()
                        }
                        
                        // MARK: - Image Preview
                        if let uiImage = uiImage {
                            ImagePreviewSection(image: uiImage)
                        }
                        
                        // MARK: - Analysis Button
                        AnalysisButton(
                            isLoading: isLoadingAnalysis,
                            isEnabled: uiImage != nil && !isLoadingAnalysis
                        ) {
                            analyzeBeer()
                        }
                        
                        // MARK: - Error Message
                        if let errorMessage = errorMessage {
                            ErrorMessageView(message: errorMessage)
                        }
                        
                        // MARK: - Analysis Result
                        if let analysisResult = analysisResult {
                            AnalysisResultView(
                                analysisResult: analysisResult,
                                isLoadingPairing: isLoadingPairing
                            ) {
                                generatePairingSuggestion()
                            }
                        }
                        
                        // MARK: - Pairing Suggestion
                        if let pairingSuggestion = pairingSuggestion {
                            PairingSuggestionView(pairingSuggestion: pairingSuggestion)
                        }
                    }
                    .padding()
                    // MARK: - CameraPicker のシート表示
                    .sheet(isPresented: $showingImagePicker) {
                        CameraPicker(
                            selectedImage: $uiImage
                        )
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
                
                .alert("ビールの解析に失敗しました", isPresented: $showingNoBeerAlert) {
                    // アクションボタンを定義 (ここではOKボタンのみ)
                    Button("OK") {
                        // OKが押されたときの処理
                        // 何もしなければアラートが閉じるだけ
                    }
                } message: {
                    // アラートのメッセージ
                    Text("ビールが検出されない、もしくはビールの解析に失敗しました")
                }
            }
            .tabItem {
                Label("追加", systemImage: "magnifyingglass")
            }
            
            // MARK: - 2 つ目のタブ
            // MARK: - Recorded Beers List
            BeerRecordsList { idToDelete in
                Task {
                    await deleteBeerRecord(idToDelete: idToDelete)
                }
            }
            .tabItem {
                Label("記録", systemImage: "list.bullet")
            }

            // New "About" Tab
            TermsOfUseView(onAccept: {}, isPresentedForAcceptance: false) // onAccept can be empty as button is hidden
                .tabItem {
                    Label("About", systemImage: "info.circle")
                }
        }
        .onAppear { // This onAppear might be on TabView or a sub-view, adjust as needed
            authenticateAnonymously()
            observeRecordedBeers()

            // New logic for Terms of Use
            if !UserDefaultsService.hasAcceptedTerms() {
                // DispatchQueue.main.async might be needed if onAppear is called
                // during a view update cycle that prevents immediate state change.
                // For simplicity, try without first.
                self.showingTermsOfUse = true
            }
        }
        .sheet(isPresented: $showingTermsOfUse) {
            TermsOfUseView(
                onAccept: {
                    UserDefaultsService.setTermsAccepted(true)
                    self.showingTermsOfUse = false
                },
                isPresentedForAcceptance: true // Ensure this is true
            )
            .interactiveDismissDisabled() // Prevent dismissing by swipe
        }
    }

    // MARK: - Helper Methods
    private func resetAnalysisResults() {
        analysisResult = nil
        pairingSuggestion = nil
        errorMessage = nil
    }

    private func deleteBeerRecord(idToDelete: String) async {
        guard let currentUserId = userId else {
            errorMessage = "ユーザーが認証されていないため、ビールを削除できません。"
            return
        }

        do {
            try await firestoreService.deleteBeer(id: idToDelete, userId: currentUserId)
            print("Successfully deleted beer record with ID: \(idToDelete)")
        } catch {
            errorMessage = "ビールの削除に失敗しました: \(error.localizedDescription)"
            print("Error deleting beer record: \(error.localizedDescription)")
        }
    }

    private func analyzeBeer() {
        guard let uiImage = uiImage else {
            errorMessage = "解析する画像がありません。"
            return
        }
        guard let currentUserId = userId else {
            errorMessage = "ユーザーが認証されていません。しばらくお待ちください。"
            return
        }

        isLoadingAnalysis = true
        errorMessage = nil
        analysisResult = nil
        pairingSuggestion = nil
        showingNoBeerAlert = false

        Task {
            do {
                let tempBeerId = UUID().uuidString
                let uploadedImageUrl = try await firestoreService.uploadImage(
                    image: uiImage,
                    userId: currentUserId,
                    beerId: tempBeerId
                )
                print("Image uploaded. URL: \(uploadedImageUrl)")

                if let base64String = uiImage.toBase64() {
                    let result = try await geminiService.analyzeBeer(
                        imageData: base64String,
                        imageType: uiImage.toMimeType()
                    )
                    
                    if result.isNotBeer {
                        showingNoBeerAlert = true
                    } else {
                        DispatchQueue.main.async {
                            self.analysisResult = result
                            Task {
                                await firestoreService.saveBeerRecord(result, imageUrl: uploadedImageUrl)
                            }
                        }
                    }
                } else {
                    throw BeerError.imageConversionFailed
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "ビールの解析に失敗しました: \(error.localizedDescription)"
                }
                showingNoBeerAlert = true
            }
            DispatchQueue.main.async {
                self.isLoadingAnalysis = false
            }
        }
    }

    private func generatePairingSuggestion() {
        guard let analysisResult = analysisResult else {
            errorMessage = "まずビールを解析してください。"
            return
        }

        isLoadingPairing = true
        errorMessage = nil

        Task {
            do {
                let suggestion = try await geminiService.generatePairingSuggestion(for: analysisResult)
                DispatchQueue.main.async {
                    self.pairingSuggestion = suggestion
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "ペアリングの提案に失敗しました: \(error.localizedDescription)"
                }
            }
            DispatchQueue.main.async {
                self.isLoadingPairing = false
            }
        }
    }

    private func authenticateAnonymously() {
        if let currentFirebaseUserId = AuthService.shared.getCurrentUserId() {
            self.userId = currentFirebaseUserId
            print("Already signed in anonymously with UID: \(currentFirebaseUserId)")
            return
        }
        
        AuthService.shared.signInAnonymously { result in
            switch result {
            case .success(let uid):
                self.userId = uid
            case .failure(let error):
                self.errorMessage = "認証エラー: \(error.localizedDescription)"
            }
        }
    }

    private func observeRecordedBeers() {
        firestoreService.observeBeers { result in
            switch result {
            case .success(let beers):
                self.recordedBeers = beers
            case .failure(let error):
                self.errorMessage = "記録されたビールの読み込みエラー: \(error.localizedDescription)"
            }
        }
    }
}

// MARK: - Supporting Views
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

#Preview {
    ContentView()
}
