import SwiftUI
import PhotosUI
import MLKit

struct HairAnalysisView: View {
    @StateObject private var viewModel = HairAnalysisViewModel()
    @State private var showImagePicker = false
    @State private var showCamera = false
    @State private var selectedImage: UIImage?
    @State private var showError = false
    @State private var isAnalyzing = false
    @State private var navigationPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                AuraTheme.backgroundGradient
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity)
                            .frame(height: UIScreen.main.bounds.height * 0.4)
                            .clipShape(RoundedRectangle(cornerRadius: 24))
                            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                            .padding(.horizontal)
                            .overlay(
                                Group {
                                    if isAnalyzing {
                                        AnalyzingOverlayView(progress: viewModel.analysisProgress)
                                    }
                                }
                            )
                        
                        Button(action: analyzeImage) {
                            HStack {
                                Image(systemName: "wand.and.stars")
                                Text("Analyze Hair")
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(AuraTheme.gradient)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: AuraTheme.primaryBlue.opacity(0.3), radius: 10, x: 0, y: 5)
                        }
                        .padding(.horizontal)
                        .disabled(isAnalyzing)
                    } else {
                        UploadPlaceholderView()
                            .padding(.horizontal)
                    }
                    
                    VStack(spacing: 16) {
                        HStack(spacing: 20) {
                            ActionButton(
                                title: "Take Photo",
                                icon: "camera.fill",
                                action: { showCamera = true }
                            )
                            
                            ActionButton(
                                title: "Upload Photo",
                                icon: "photo.fill",
                                action: { showImagePicker = true }
                            )
                        }
                        .disabled(isAnalyzing)
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical, 24)
            }
            .navigationDestination(for: HairAnalysis.self) { analysis in
                AnalysisResultScreen(analysis: analysis) {
                    // Reset and go back to analysis screen
                    selectedImage = nil
                    navigationPath.removeLast()
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    AuraLogo(size: 32)
                }
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $selectedImage, sourceType: .photoLibrary)
            }
            .sheet(isPresented: $showCamera) {
                ImagePicker(image: $selectedImage, sourceType: .camera)
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.error?.localizedDescription ?? "An error occurred while analyzing the image.")
            }
        }
    }
    
    private func analyzeImage() {
        guard let image = selectedImage, !isAnalyzing else { return }
        isAnalyzing = true
        
        Task {
            do {
                try await viewModel.analyzeHair(image: image)
                await MainActor.run {
                    isAnalyzing = false
                    if let analysis = viewModel.hairAnalysis {
                        navigationPath.append(analysis)
                    }
                }
            } catch {
                await MainActor.run {
                    showError = true
                    isAnalyzing = false
                }
            }
        }
    }
}


struct ActionButton: View {
    let title: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                Text(title)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
    }
}

struct AnalyzingOverlayView: View {
    let progress: String
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.black.opacity(0.7))
            VStack(spacing: 16) {
                ProgressView()
                    .scaleEffect(1.2)
                    .tint(.white)
                Text(progress)
                    .font(.headline)
                    .foregroundColor(.white)
            }
            .padding(24)
        }
    }
} 
