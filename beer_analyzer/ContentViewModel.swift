import SwiftUI
import PhotosUI
import FirebaseRemoteConfig
import Kingfisher // Assuming Kingfisher might be used by BeerAnalysisResult or BeerRecord if they involve image URLs

class ContentViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var selectedImage: PhotosPickerItem? = nil
    @Published var uiImage: UIImage? = nil
    @Published var analysisResult: BeerAnalysisResult? = nil
    @Published var pairingSuggestion: String? = nil
    @Published var errorMessage: String? = nil
    @Published var isLoadingAnalysis: Bool = false
    @Published var isLoadingPairing: Bool = false
    @Published var recordedBeers: [BeerRecord] = []
    @Published var userId: String? = nil
    @Published var showingImagePicker: Bool = false
    // sourceType is no longer needed as PhotosPicker handles library
    // and AVFoundationCameraView handles direct camera access.

    // MARK: - Services
    let geminiService = GeminiAPIService()
    let firestoreService = FirestoreService()
    let authService = AuthService.shared

    // MARK: - Initialization
    init() {
        // Perform any specific setup here if needed in the future.
        // For now, default initializers for services are assumed.
        // If AuthService requires explicit setup not handled by .shared,
        // it would be done here.
        // Initial calls to authenticate and observe data
        authenticateAnonymously()
        observeRecordedBeers()
    }

    // MARK: - Public Methods

    func resetAnalysisResults() {
        analysisResult = nil
        pairingSuggestion = nil
        errorMessage = nil
    }

    func deleteBeerRecord(idToDelete: String) async {
        guard let currentUserId = userId else {
            errorMessage = "ユーザーが認証されていないため、ビールを削除できません。"
            return
        }

        do {
            // Assuming firestoreService.deleteBeer is an async func
            try await firestoreService.deleteBeer(id: idToDelete, userId: currentUserId)
            print("Successfully deleted beer record with ID: \(idToDelete)")
            // The observer for recordedBeers should automatically update the list
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "ビールの削除に失敗しました: \(error.localizedDescription)"
            }
            print("Error deleting beer record: \(error.localizedDescription)")
        }
    }

    func analyzeBeer() {
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

        Task {
            do {
                let tempBeerId = UUID().uuidString // Create a unique ID for the beer
                // Assuming firestoreService.uploadImage is an async func
                let uploadedImageUrl = try await firestoreService.uploadImage(
                    image: uiImage,
                    userId: currentUserId,
                    beerId: tempBeerId // Pass the beerId to associate the image with the beer
                )
                print("Image uploaded. URL: \(uploadedImageUrl)")

                if let base64String = uiImage.toBase64() { // Assuming UIImage.toBase64() exists
                    // Assuming geminiService.analyzeBeer is an async func
                    let result = try await geminiService.analyzeBeer(
                        imageData: base64String,
                        imageType: uiImage.toMimeType() // Assuming UIImage.toMimeType() exists
                    )
                    DispatchQueue.main.async {
                        self.analysisResult = result
                        // Save the full analysis result along with the image URL
                        // Assuming firestoreService.saveBeerRecord takes BeerAnalysisResult and URL
                        Task {
                             await self.firestoreService.saveBeerRecord(result, userId: currentUserId, imageUrl: uploadedImageUrl)
                        }
                    }
                } else {
                    throw BeerError.imageConversionFailed // Assuming BeerError enum exists
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "ビールの解析に失敗しました: \(error.localizedDescription)"
                }
            }
            DispatchQueue.main.async {
                self.isLoadingAnalysis = false
            }
        }
    }

    func generatePairingSuggestion() {
        guard let analysisResult = analysisResult else {
            errorMessage = "まずビールを解析してください。"
            return
        }

        isLoadingPairing = true
        errorMessage = nil

        Task {
            do {
                // Assuming geminiService.generatePairingSuggestion is an async func
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

    // MARK: - Private Helper Methods

    private func authenticateAnonymously() {
        authService.signInAnonymously { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let uid):
                    self?.userId = uid
                    // Once authenticated, fetch initial data like recorded beers
                    self?.observeRecordedBeers()
                case .failure(let error):
                    self?.errorMessage = "認証エラー: \(error.localizedDescription)"
                }
            }
        }
    }

    private func observeRecordedBeers() {
        guard let currentUserId = userId else {
            // Don't try to observe if userId is nil.
            // It will be called again by authenticateAnonymously upon successful login.
            return
        }
        // Assuming firestoreService.observeBeers takes userId and a completion handler
        firestoreService.observeBeers(userId: currentUserId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let beers):
                    self?.recordedBeers = beers
                case .failure(let error):
                    self?.errorMessage = "記録されたビールの読み込みエラー: \(error.localizedDescription)"
                }
            }
        }
    }
}

// Note: Actual definitions for BeerError, BeerAnalysisResult, BeerRecord,
// UIImage extensions (toBase64, toMimeType), GeminiAPIService, FirestoreService,
// and AuthService are expected to be in their respective project files.
// This file should only contain the ContentViewModel class.
// Ensure necessary import statements are present if these types are in different modules/files.
