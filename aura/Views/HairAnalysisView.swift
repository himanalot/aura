import SwiftUI
import PhotosUI
import MLKit
import FirebaseAuth

struct HairAnalysisView: View {
    @StateObject private var viewModel = HairAnalysisViewModel()
    @State private var showImagePicker = false
    @State private var showCamera = false
    @State private var selectedImage: UIImage?
    @State private var showError = false
    @State private var isAnalyzing = false
    @State private var navigationPath = NavigationPath()
    @State private var showReferralView = false
    @State private var showReferralCodeEntry = false
    @State private var showReferralCodeShare = false
    @State private var referralStatus: UserReferralStatus?
    @State private var generatedReferralCode: ReferralCode?
    @State private var isGeneratingCode = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                LinearGradient(
                    colors: [
                        AuraTheme.primary.opacity(0.8),
                        AuraTheme.accent.opacity(0.6)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
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
                                HStack(spacing: 12) {
                                    Image(systemName: "wand.and.stars")
                                        .font(.system(size: 16, weight: .semibold))
                                    Text("Analyze Hair")
                                        .font(.system(size: 16, weight: .semibold))
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(.ultraThinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                )
                                .shadow(color: .black.opacity(0.1), radius: 6, y: 2)
                                .foregroundColor(.white)
                            }
                            .padding(.horizontal)
                            .disabled(isAnalyzing)
                            .pressEffect()
                        } else {
                            UploadPlaceholderView()
                                .padding(.horizontal, 24)
                                .background(.ultraThinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 24))
                                .shadow(color: .black.opacity(0.1), radius: 8, y: 2)
                                .padding(.horizontal)
                        }
                        
                        VStack(spacing: 20) {
                            HStack(spacing: 16) {
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
                            .padding(.horizontal)
                            
                            Button(action: { showReferralCodeEntry = true }) {
                                HStack(spacing: 12) {
                                    Image(systemName: "ticket.fill")
                                        .font(.system(size: 16, weight: .semibold))
                                    Text("Enter Referral Code")
                                        .font(.system(size: 16, weight: .semibold))
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(.ultraThinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                )
                                .shadow(color: Color.black.opacity(0.1), radius: 8, y: 4)
                                .foregroundColor(.white)
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical, 32)
                }
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
                Text(errorMessage ?? "An error occurred while analyzing the image.")
            }
        }
        .task {
            await loadUserReferralStatus()
        }
        .sheet(isPresented: $showReferralCodeShare) {
            if isGeneratingCode {
                ProgressView("Generating code...")
                    .padding()
            } else if let code = generatedReferralCode {
                ReferralShareView(referralCode: code) {
                    showReferralCodeShare = false
                    Task {
                        await loadUserReferralStatus()
                    }
                }
            } else {
                Text("Unable to generate referral code")
                    .padding()
            }
        }
        .sheet(isPresented: $showReferralCodeEntry) {
            ReferralView {
                Task {
                    await loadUserReferralStatus()
                }
            }
        }
    }
    
    private func loadUserReferralStatus() async {
        if let userId = Auth.auth().currentUser?.uid {
            do {
                referralStatus = try await FirebaseService.shared.getReferralStatus(userId: userId)
                
                // Check if user has no referral code
                if referralStatus?.referralCode == nil {
                    // Generate a new code if they don't have one
                    do {
                        generatedReferralCode = try await FirebaseService.shared.generateReferralCode(for: userId)
                        // Refresh status after generating new code
                        referralStatus = try await FirebaseService.shared.getReferralStatus(userId: userId)
                    } catch {
                        print("Error generating initial referral code: \(error)")
                    }
                } else if let code = referralStatus?.referralCode,
                          !code.isEmpty {  // Only try to load if code exists and isn't empty
                    do {
                        let existingCodes = try await FirebaseService.shared.getReferralCodes(code: code)
                        if let existingCode = existingCodes.first {
                            generatedReferralCode = existingCode
                        } else {
                            // Only create a new code document if none exists for this code
                            let newReferralCode = ReferralCode(
                                id: UUID().uuidString,
                                ownerId: userId,
                                code: code,
                                usedBy: [],
                                createdAt: Date()
                            )
                            try await FirebaseService.shared.saveReferralCode(newReferralCode)
                            generatedReferralCode = newReferralCode
                        }
                    } catch {
                        print("Error loading referral code: \(error)")
                    }
                }
            } catch {
                print("Error loading referral status: \(error)")
            }
        }
    }
    
    private func analyzeImage() {
        guard let image = selectedImage, !isAnalyzing else { return }
        
        Task {
            do {
                if let userId = Auth.auth().currentUser?.uid {
                    // Ensure user exists in Firebase
                    do {
                        try await FirebaseService.shared.ensureUserExists(
                            userId: userId,
                            email: Auth.auth().currentUser?.email ?? ""
                        )
                    } catch {
                        print("Error checking/creating user: \(error)")
                    }
                    
                    // Directly perform analysis without checking referral status
                    await performAnalysis(image: image)
                }
            } catch {
                await MainActor.run {
                    showError = true
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    private func performAnalysis(image: UIImage) async {
        isAnalyzing = true
        do {
            try await viewModel.analyzeHair(image: image)
            if let userId = Auth.auth().currentUser?.uid {
                // Set available analyses to 0 instead of decrementing
                try await FirebaseService.shared.setAvailableAnalyses(userId: userId, amount: 0)
                // Refresh the status after updating
                await loadUserReferralStatus()
            }
            await MainActor.run {
                isAnalyzing = false
                if let analysis = viewModel.hairAnalysis {
                    navigationPath.append(analysis)
                }
            }
        } catch {
            await MainActor.run {
                showError = true
                errorMessage = error.localizedDescription
                isAnalyzing = false
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
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.1), radius: 6, y: 2)
            .foregroundColor(.white)
            .pressEffect()
        }
    }
}

extension View {
    func pressEffect() -> some View {
        buttonStyle(PressEffectStyle())
    }
}

struct PressEffectStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .opacity(configuration.isPressed ? 0.8 : 1)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
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

