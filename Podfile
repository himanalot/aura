platform :ios, '15.0'
project 'aura.xcodeproj'

target 'aura' do
  use_frameworks!

  # Firebase dependencies
  pod 'Firebase'
  pod 'FirebaseCore'
  pod 'FirebaseAuth'
  pod 'FirebaseFirestore'
  pod 'FirebaseStorage'
  pod 'FirebaseFirestoreSwift'
  pod 'Firebase/Core'
  
  # UI & Charts
  pod 'DGCharts'  # Updated from Charts to DGCharts
  pod 'SkeletonView'
  pod 'Kingfisher'
  
  # Networking & Data
  pod 'Alamofire'
  pod 'SwiftyJSON'

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
      
      # Add build settings to fix sandbox permissions and Swift initialization issues
      target.build_configurations.each do |config|
        config.build_settings['ENABLE_BITCODE'] = 'NO'
        config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
        
        # Add sandbox permissions
        config.build_settings['CODE_SIGNING_ALLOWED'] = 'YES'
        config.build_settings['CODE_SIGNING_REQUIRED'] = 'NO'
        config.build_settings['EXPANDED_CODE_SIGN_IDENTITY'] = ''
        config.build_settings['CODE_SIGNING_IDENTITY'] = ''
        
        # Swift compiler flags to handle initialization
        config.build_settings['OTHER_SWIFT_FLAGS'] = '$(inherited) -suppress-warnings'
        config.build_settings['SWIFT_ENFORCE_EXCLUSIVE_ACCESS'] = 'off'
        
        # Enable modules
        config.build_settings['CLANG_ENABLE_MODULES'] = 'YES'
        config.build_settings['SWIFT_OPTIMIZATION_LEVEL'] = '-Onone'
        
        # Swift version
        config.build_settings['SWIFT_VERSION'] = '5.0'
      end
    end
  end
end