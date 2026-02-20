# iOS Build Environment Setup Guide

This document outlines the steps to configure a remote macOS machine to build the `mobile-poc` React Native application.

## 1. System Requirements
*   **OS:** macOS Sonoma or later (recommended).
*   **Xcode:** Xcode 15+ (Install via App Store).
*   **Command Line Tools:** Required for git and build tools.

## 2. Install Dependencies (Homebrew)
If Homebrew is not installed, install it first:
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Then, install the core dependencies:
```bash
brew update
brew install node
brew install watchman
brew install cocoapods
```

## 3. Configure Xcode Command Line Tools
Ensure the active developer directory is pointing to Xcode:
```bash
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
```
Verify it:
```bash
xcodebuild -version
# Should output: Xcode 15.x (or newer)
```

## 4. Project Setup
Transfer the `mobile-poc` folder to this machine (e.g., via `rsync` or `git clone`).

Navigate to the project directory:
```bash
cd mobile-poc
```

### Install JavaScript Dependencies
```bash
npm install
```

### Install iOS Native Dependencies (CocoaPods)
```bash
cd ios
pod install
cd ..
```

## 5. Signing & Certificates
**Important:** To build for a physical device or create a release build (`.ipa`), you must have valid Apple Developer certificates installed in the Keychain.

1.  Open `ios/mobilepoc.xcworkspace` in Xcode.
2.  Select the project root in the navigator.
3.  Go to **Signing & Capabilities**.
4.  Select your **Team**.
5.  Ensure a "Signing Certificate" is found.

## 6. Building the App

### Option A: Development Build (Simulator)
To run on the iOS Simulator:
```bash
npx expo run:ios
```
*This will automatically launch the simulator and install the app.*

### Option B: Archive for Release (IPA)
To build a production `.ipa` file:

```bash
# 1. Archive
xcodebuild -workspace ios/mobilepoc.xcworkspace 
  -scheme mobilepoc 
  -configuration Release 
  -archivePath ./build/mobilepoc.xcarchive 
  archive

# 2. Export IPA (Requires ExportOptions.plist)
xcodebuild -exportArchive 
  -archivePath ./build/mobilepoc.xcarchive 
  -exportPath ./build 
  -exportOptionsPlist ./ios/ExportOptions.plist
```
*(Note: You may need to generate an `ExportOptions.plist` file if one is not provided).*

## 7. Troubleshooting
*   **CocoaPods Errors:** Run `repo update` via `pod repo update`.
*   **Signing Errors:** Open Xcode GUI to fix automatic signing issues.
*   **Node Version:** Ensure you are using a compatible Node version (LTS recommended, v18+).
