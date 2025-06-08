import SwiftUI
import AVFoundation

struct AVFoundationCameraView: UIViewControllerRepresentable {
    @Binding var capturedImage: UIImage?
    @Environment(\.dismiss) var dismiss // For dismissing the view

    // MARK: - UIViewControllerRepresentable Methods

    func makeUIViewController(context: Context) -> CameraViewController {
        let viewController = CameraViewController()
        viewController.coordinator = context.coordinator // Pass coordinator to the VC
        return viewController
    }

    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {
        // This method would be used if we need to update the view controller
        // based on changes in SwiftUI state. For now, it's empty.
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    // MARK: - Coordinator

    class Coordinator: NSObject, AVCapturePhotoCaptureDelegate {
        var parent: AVFoundationCameraView

        init(_ parent: AVFoundationCameraView) {
            self.parent = parent
        }

        func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
            defer {
                // Ensure dismiss is called whether success or failure, unless an early exit for critical error already happened.
                // However, current logic calls dismiss only on success. Let's adjust to call it always.
                // For a more nuanced approach, we might have different dismiss behaviors based on error type.
                parent.dismiss()
            }

            if let error = error {
                print("Error capturing photo: \(error.localizedDescription)")
                parent.capturedImage = nil // Explicitly set to nil on error
                // TODO: Propagate a specific error message to the user if the view had an error message binding.
                return // Dismiss will be handled by defer
            }

            guard let imageData = photo.fileDataRepresentation() else {
                print("Could not get image data from AVCapturePhoto.")
                parent.capturedImage = nil // Explicitly set to nil on data error
                // TODO: Propagate error
                return // Dismiss will be handled by defer
            }

            if let uiImage = UIImage(data: imageData) {
                print("Captured image orientation (rawValue): \(uiImage.imageOrientation.rawValue)")
                // Update the binding in the parent SwiftUI view
                parent.capturedImage = uiImage
                // Dismiss is handled by defer
            } else {
                print("Could not convert image data to UIImage.")
                parent.capturedImage = nil // Explicitly set to nil on conversion error
                // TODO: Propagate error
                // Dismiss is handled by defer
            }
        }
    }
}

// MARK: - Custom UIViewController for Camera
class CameraViewController: UIViewController {
    var captureSession: AVCaptureSession!
    var photoOutput: AVCapturePhotoOutput!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var captureButton: UIButton!
    weak var coordinator: AVFoundationCameraView.Coordinator?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        checkCameraPermissionsAndSetup() // Check permissions before setup
        setupCaptureButton()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let previewLayer = previewLayer {
            previewLayer.frame = view.bounds
        }
        if let button = captureButton {
            // Position the button at the bottom center
            button.frame = CGRect(x: view.bounds.midX - 50, y: view.bounds.maxY - 100, width: 100, height: 50)
        }
    }

    func checkCameraPermissionsAndSetup() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            // Permission already granted
            setupCaptureSession()
            startSessionIfNeeded()
        case .notDetermined:
            // Request permission
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    if granted {
                        self?.setupCaptureSession()
                        self?.startSessionIfNeeded()
                    } else {
                        print("Camera permission denied by user.")
                        // TODO: Inform user (e.g., show an alert, guide to settings)
                        // For now, we might just leave the view black or show a message.
                    }
                }
            }
        case .denied, .restricted:
            // Permission denied or restricted
            print("Camera permission is denied or restricted.")
            // TODO: Inform user (e.g., show an alert, guide to settings)
            // For now, the view will remain black as session won't be started.
        @unknown default:
            print("Unknown camera authorization status.")
            // TODO: Handle appropriately
        }
    }

    func startSessionIfNeeded() {
        // Start the session only if it's configured and not already running
        if let session = captureSession, !session.isRunning, session.inputs.isEmpty == false, session.outputs.isEmpty == false {
            DispatchQueue.global(qos: .userInitiated).async {
                session.startRunning()
            }
        } else if captureSession == nil {
             // This case implies setupCaptureSession was not called or failed.
             // It might be due to permissions not being granted.
            print("Capture session not available or not configured to start.")
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Session starting is now handled by checkCameraPermissionsAndSetup or after permission grant
        // However, if the view was previously stopped (e.g. backgrounded) and permissions are still good, restart.
        if AVCaptureDevice.authorizationStatus(for: .video) == .authorized {
            startSessionIfNeeded()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Stop the session when the view disappears
        if let session = captureSession, session.isRunning {
            DispatchQueue.global(qos: .userInitiated).async {
                session.stopRunning()
            }
        }
    }

    func setupCaptureSession() {
        captureSession = AVCaptureSession()
        captureSession.beginConfiguration()

        // 1. Video Input
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice),
              captureSession.canAddInput(videoDeviceInput) else {
            print("Failed to get video device input")
            captureSession.commitConfiguration()
            // TODO: Handle error (e.g., show an alert to the user via coordinator)
            return
        }
        captureSession.addInput(videoDeviceInput)

        // 2. Photo Output
        photoOutput = AVCapturePhotoOutput()
        guard captureSession.canAddOutput(photoOutput) else {
            print("Failed to add photo output")
            captureSession.commitConfiguration()
            // TODO: Handle error
            return
        }
        captureSession.addOutput(photoOutput)
        captureSession.sessionPreset = .photo // Set preset for high quality photos

        captureSession.commitConfiguration()

        // 3. Preview Layer
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds // Set initial frame, will be updated in viewDidLayoutSubviews
        view.layer.addSublayer(previewLayer)

        // Start session (moved to startSessionIfNeeded for better lifecycle management)
    }

    func setupCaptureButton() {
        captureButton = UIButton(type: .system)
        captureButton.setTitle("Capture", for: .normal)
        captureButton.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        captureButton.setTitleColor(.black, for: .normal)
        captureButton.layer.cornerRadius = 25 // Make it roundish
        captureButton.addTarget(self, action: #selector(captureButtonTapped), for: .touchUpInside)
        view.addSubview(captureButton)
        // Frame will be set in viewDidLayoutSubviews
    }

    @objc func captureButtonTapped() {
        takePhoto()
    }

    func takePhoto() {
        guard let photoOutput = self.photoOutput, captureSession.isRunning else {
            print("Photo output not available or session not running.")
            return
        }
        let photoSettings = AVCapturePhotoSettings()
        // Configure settings if needed (e.g., flashMode, highResolutionPhotoEnabled)
        if photoOutput.availablePhotoCodecTypes.contains(.hevc) {
            photoSettings.photoQualityPrioritization = .quality
        }
        photoOutput.capturePhoto(with: photoSettings, delegate: coordinator!) // Delegate to coordinator
    }
}


// MARK: - Preview (Optional)
#if DEBUG
struct AVFoundationCameraView_Previews: PreviewProvider {
    static var previews: some View {
        AVFoundationCameraView(capturedImage: .constant(nil))
            .edgesIgnoringSafeArea(.all)
    }
}
#endif
