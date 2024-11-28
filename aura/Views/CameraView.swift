import SwiftUI
import AVFoundation

struct CameraView: View {
    @Binding var image: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    // Camera state
    @StateObject private var camera = CameraModel()
    
    var body: some View {
        ZStack {
            // Camera preview
            CameraPreviewView(session: camera.session)
                .ignoresSafeArea()
            
            // Camera controls
            VStack {
                Spacer()
                
                HStack(spacing: 60) {
                    // Cancel button
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.title)
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                    }
                    
                    // Capture button
                    Button(action: { camera.capturePhoto() }) {
                        ZStack {
                            Circle()
                                .fill(.white)
                                .frame(width: 70, height: 70)
                            Circle()
                                .stroke(.white, lineWidth: 2)
                                .frame(width: 80, height: 80)
                        }
                    }
                    
                    // Flip camera button
                    Button(action: { camera.flipCamera() }) {
                        Image(systemName: "camera.rotate")
                            .font(.title)
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                    }
                }
                .padding(.bottom, 30)
            }
        }
        .onAppear {
            camera.checkPermissions()
        }
        .onChange(of: camera.photo) { newPhoto in
            if let photo = newPhoto {
                image = photo
                dismiss()
            }
        }
    }
}

// Camera model to handle AVFoundation logic
class CameraModel: NSObject, ObservableObject {
    @Published var photo: UIImage?
    @Published var isFlashOn = false
    @Published var error: String?
    
    let session = AVCaptureSession()
    private var device: AVCaptureDevice?
    private var output = AVCapturePhotoOutput()
    
    override init() {
        super.init()
        setupCamera()
    }
    
    func setupCamera() {
        checkPermissions()
        
        // Start with front camera configuration
        let discoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera],
            mediaType: .video,
            position: .front
        )
        
        guard let device = discoverySession.devices.first(where: { $0.position == .front }) else {
            DispatchQueue.main.async {
                self.error = "Front camera not available"
            }
            return
        }
        
        self.device = device
        
        session.beginConfiguration()
        do {
            // Remove any existing inputs
            session.inputs.forEach { session.removeInput($0) }
            
            let input = try AVCaptureDeviceInput(device: device)
            if session.canAddInput(input) {
                session.addInput(input)
            }
            
            if session.canAddOutput(output) {
                session.addOutput(output)
            }
            
            session.sessionPreset = .photo
            session.commitConfiguration()
            
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.session.startRunning()
            }
        } catch {
            DispatchQueue.main.async {
                self.error = "Error setting up camera: \(error.localizedDescription)"
            }
        }
    }
    
    func checkPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized:
                return
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                    if granted {
                        DispatchQueue.main.async {
                            self?.setupCamera()
                        }
                    }
                }
            default:
                return
        }
    }
    
    func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        output.capturePhoto(with: settings, delegate: self)
    }
    
    func flipCamera() {
        // Implementation for flipping camera
    }
}

extension CameraModel: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation(),
           let image = UIImage(data: imageData) {
            DispatchQueue.main.async {
                self.photo = image
            }
        }
    }
}

// Preview view using UIViewRepresentable
struct CameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: CGRect.zero)
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        if let layer = uiView.layer.sublayers?.first as? AVCaptureVideoPreviewLayer {
            layer.frame = uiView.bounds
        }
    }
} 