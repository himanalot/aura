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
    @State private var showResults = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 300)
                        .cornerRadius(10)
                        .overlay(
                            Group {
                                if isAnalyzing {
                                    VStack {
                                        ProgressView()
                                        Text(viewModel.analysisProgress)
                                            .padding(.top, 8)
                                    }
                                    .padding()
                                    .background(Color(.systemBackground).opacity(0.8))
                                    .cornerRadius(10)
                                }
                            }
                        )
                } else {
                    UploadPlaceholderView()
                }
                
                HStack(spacing: 20) {
                    Button(action: { showCamera = true }) {
                        Label("Take Photo", systemImage: "camera")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .disabled(isAnalyzing)
                    
                    Button(action: { showImagePicker = true }) {
                        Label("Upload Photo", systemImage: "photo")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .disabled(isAnalyzing)
                }
                
                if showResults, let analysis = viewModel.hairAnalysis {
                    HairAnalysisResultView(analysis: analysis)
                        .transition(.opacity)
                        .animation(.easeIn, value: showResults)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Hair Analysis")
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $selectedImage, sourceType: .photoLibrary)
            }
            .sheet(isPresented: $showCamera) {
                ImagePicker(image: $selectedImage, sourceType: .camera)
            }
            .onChange(of: selectedImage) { newImage in
                guard let image = newImage, !isAnalyzing else { return }
                isAnalyzing = true
                showResults = false
                
                Task {
                    do {
                        try await viewModel.analyzeHair(image: image)
                        await MainActor.run {
                            isAnalyzing = false
                            showResults = true
                        }
                    } catch {
                        await MainActor.run {
                            showError = true
                            isAnalyzing = false
                        }
                    }
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.error?.localizedDescription ?? "An error occurred while analyzing the image.")
            }
        }
    }
}

struct UploadPlaceholderView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "camera.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(.gray)
            
            Text("Take or upload a photo\nto analyze your hair health")
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
        }
        .frame(height: 300)
        .frame(maxWidth: .infinity)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
} 