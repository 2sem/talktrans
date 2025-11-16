# Talktrans Project Overview

## Purpose
Talktrans (Talk-Translator) is an iOS application built with SwiftUI. The app appears to be a translation/communication app that integrates with KakaoTalk and includes features like speech recognition, contact access, and advertising (Google AdMob).

## Tech Stack
- **Language**: Swift 5.0
- **UI Framework**: SwiftUI
- **Project Management**: Tuist 4.104.5
- **Tool Management**: mise (for managing Tuist version)
- **Testing Framework**: Swift Testing
- **Platform**: iOS 18.0+
- **Deployment Targets**: iPhone and iPad

## Project Structure
The project uses a modular workspace structure managed by Tuist:

- **Workspace**: `sendadv` (defined in Workspace.swift)
- **Projects**:
  - `App`: Main application target
  - `ThirdParty`: Static framework containing third-party dependencies
  - `DynamicThirdParty`: Dynamic framework containing Firebase and SDWebImage

## Key Dependencies
- **Kakao SDK**: For KakaoTalk integration
- **Firebase**: Analytics, Crashlytics, Messaging, RemoteConfig
- **GADManager**: Google AdMob manager
- **SDWebImage**: Image loading
- **MBProgressHUD**: Progress indicators
- **LSExtensions**: Utility extensions
- **Material**: UI components

## Bundle Information
- Bundle ID: `com.credif.talktrans`
- Display Name: "Talk-Translator"
- App Store ID: 1186147362
- Development Team: M29A6H95KD

## Features
- Speech recognition
- Contact access
- KakaoTalk integration
- Google AdMob advertising
- Firebase analytics and crash reporting