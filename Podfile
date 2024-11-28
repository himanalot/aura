platform :ios, '15.0'
project 'aura.xcodeproj'

target 'aura' do
  use_frameworks!

  # Firebase dependencies
  pod 'Firebase/Core'
  pod 'Firebase/Analytics'
  pod 'FirebaseAuth'
  pod 'FirebaseStorage'
  pod 'FirebaseFirestore'
  pod 'FirebaseFirestoreSwift'
  
  # Image Processing & ML
  pod 'GoogleMLKit/ImageLabeling'
  pod 'GoogleMLKit/FaceDetection'
  
  # UI & Image Handling
  pod 'Kingfisher'
  pod 'DGCharts'
  pod 'SkeletonView'
  
  # Networking & Data
  pod 'Alamofire'
  pod 'SwiftyJSON'
  pod 'OpenAIKit'  # Add this line


  post_install do |installer|
    installer.pods_project.targets.each do |target|
      # Apply specific settings for the BoringSSL-GRPC target
      if target.name == 'BoringSSL-GRPC'
        target.source_build_phase.files.each do |file|
          if file.settings && file.settings['COMPILER_FLAGS']
            flags = file.settings['COMPILER_FLAGS'].split
            flags.reject! { |flag| flag == '-GCC_WARN_INHIBIT_ALL_WARNINGS' }
            file.settings['COMPILER_FLAGS'] = flags.join(' ')
          end
        end
      end
      
      target.build_configurations.each do |config|
        config.build_settings['ENABLE_BITCODE'] = 'NO'
        config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
        config.build_settings['CODE_SIGNING_ALLOWED'] = 'YES'
      end
    end
  end
end