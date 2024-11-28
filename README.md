## Setup

1. Clone the repository
2. Install CocoaPods dependencies:
   ```bash
   pod install
   ```
3. Copy the template files and add your API keys:
   ```bash
   cp aura/Config/Info.template.plist aura/Info.plist
   ```
4. Add your GitHub token to Info.plist:
   - GITHUB_API_TOKEN: Get from [GitHub Settings](https://github.com/settings/tokens)
   
5. Add your Firebase configuration:
   - Download GoogleService-Info.plist from Firebase Console
   - Add it to the project root directory

6. Open aura.xcworkspace in Xcode 

## Configuration

To set up the API key:

1. Copy `Config.template.xcconfig` to `Config.xcconfig`
2. Replace `your-api-key-here` with your actual OpenAI API key
3. Never commit `Config.xcconfig` to version control