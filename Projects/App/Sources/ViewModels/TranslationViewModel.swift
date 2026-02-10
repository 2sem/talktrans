//
//  TranslationViewModel.swift
//  talktrans
//
//  Created by 영준 이 on 11/9/25.
//  Copyright © 2025 leesam. All rights reserved.
//

import Foundation
import SwiftUI
import Speech
import AVFoundation
import Translation
import Combine

@MainActor
class TranslationViewModel: ObservableObject {
	@Published var nativeText: String = ""
	@Published var translatedText: String = ""
	@Published var nativeLocale: TranslationLocale = .english {
        didSet {
            LSDefaults.translationSourceLocale = nativeLocale.rawValue
        }
    }
	@Published var translatedLocale: TranslationLocale = .korean {
        didSet {
            LSDefaults.translationTargetLocale = translatedLocale.rawValue
        }
    }
	@Published var isTranslating: Bool = false
	@Published var isRecognizing: Bool = false
	@Published var errorMessage: String?
	@Published var translationConfiguration: TranslationSession.Configuration?
	@Published var isFullScreen: Bool = false
	@Published var deviceOrientation: UIDeviceOrientation = .portrait

	private let translationManager = TranslationManager.shared
	private let maxTextLength = 100
	private var translationSession: TranslationSession?
	private var orientationObserver: AnyCancellable?
	private var manualFullScreenToggle: Bool = false
	
	var canTranslate: Bool {
		!nativeText.isEmpty && !isTranslating
	}
	
	var supportedTargetLocales: [TranslationLocale] {
		let sourceLocale = nativeLocale.locale
		return translationManager.supportedTargetLangs(source: sourceLocale)
	}
	
	init() {
		// Initialize with saved locale or current locale
        if let savedSource = LSDefaults.translationSourceLocale,
           let locale = TranslationLocale(rawValue: savedSource) {
            nativeLocale = locale
        } else if let currentLocale = TranslationLocale.from(locale: Locale.current) {
			nativeLocale = currentLocale
		}

        // Initialize with saved target locale or default
        if let savedTarget = LSDefaults.translationTargetLocale,
           let locale = TranslationLocale(rawValue: savedTarget) {
            translatedLocale = locale
        } else {
            // Set default translated locale (Korean if native is not Korean, otherwise English)
            if nativeLocale != .korean {
                translatedLocale = .korean
            } else {
                translatedLocale = .english
            }
        }

		// Setup orientation observer
		setupOrientationObserver()
	}

	deinit {
		orientationObserver?.cancel()
	}

	// MARK: - Orientation Handling

	private func setupOrientationObserver() {
		// Enable orientation notifications
		UIDevice.current.beginGeneratingDeviceOrientationNotifications()

		// Observe orientation changes
		orientationObserver = NotificationCenter.default
			.publisher(for: UIDevice.orientationDidChangeNotification)
			.sink { [weak self] _ in
				guard let self = self else { return }
				Task { @MainActor in
					self.handleOrientationChange()
				}
			}

		// Set initial orientation
		deviceOrientation = UIDevice.current.orientation
		handleOrientationChange()
	}

	private func handleOrientationChange() {
		let newOrientation = UIDevice.current.orientation

		// Only handle valid orientations
		guard newOrientation.isValidInterfaceOrientation else { return }

		deviceOrientation = newOrientation

		// Auto-toggle full screen only if user hasn't manually toggled
		guard !manualFullScreenToggle else { return }

		// Switch to full screen in landscape, normal mode in portrait
		let shouldBeFullScreen = newOrientation.isLandscape

		if shouldBeFullScreen != isFullScreen {
			withAnimation(.easeInOut(duration: 0.3)) {
				isFullScreen = shouldBeFullScreen
			}
		}
	}
	
	func translate() {
		guard !nativeText.isEmpty else { return }
		guard !isTranslating else { return }
		
		let sourceLocale = nativeLocale.locale
		let targetLocale = translatedLocale.locale
		
		guard translationManager.canSupportTranslate(source: sourceLocale, target: targetLocale) else {
			errorMessage = "Translation from \(nativeLocale.displayName) to \(translatedLocale.displayName) is not supported"
			return
		}
		
		isTranslating = true
		errorMessage = nil
		
		// Recreate TranslationSession configuration when translate button is pressed
		// This will trigger translationTask modifier in the View, which will call setTranslationSession
		createTranslationConfiguration(source: sourceLocale, target: targetLocale)
		
		// Call TranslationManager.translate if session is already available
		if let session = translationSession {
			Task {
				do {
					let translated = try await translationManager.translate(text: nativeText, session: session)
					await MainActor.run {
						self.translatedText = translated
						self.isTranslating = false
					}
				} catch {
					await MainActor.run {
						self.errorMessage = error.localizedDescription
						self.isTranslating = false
					}
				}
			}
		}
	}
	
	func setTranslationSession(_ session: TranslationSession) {
		translationSession = session
		
		// Perform translation when session is set using TranslationManager
		guard !nativeText.isEmpty else { return }
		guard isTranslating else { return } // Only translate if translate() was called
		
		Task {
			do {
				let translated = try await translationManager.translate(text: nativeText, session: session)
				await MainActor.run {
					self.translatedText = translated
					self.isTranslating = false
				}
			} catch {
				await MainActor.run {
					self.errorMessage = error.localizedDescription
					self.isTranslating = false
				}
			}
		}
	}
	
	
	func swapLanguages() {
		let tempLocale = nativeLocale
		let tempText = nativeText
		
		nativeLocale = translatedLocale
		nativeText = translatedText
		
		translatedLocale = tempLocale
		translatedText = tempText
	}
	
	func updateNativeLocale(_ locale: TranslationLocale) {
		nativeLocale = locale
		
		// Auto-fix translated locale if not supported
		if !translationManager.canSupportTranslate(source: locale.locale, target: translatedLocale.locale) {
			if let firstSupported = supportedTargetLocales.first {
				translatedLocale = firstSupported
			}
		}
	}
	
	func updateTranslatedLocale(_ locale: TranslationLocale) {
		translatedLocale = locale
	}

	func toggleFullScreen() {
		// Mark that user has manually toggled full screen
		manualFullScreenToggle = true

		withAnimation(.easeInOut(duration: 0.3)) {
			isFullScreen.toggle()
		}
	}

	func resetManualFullScreenToggle() {
		manualFullScreenToggle = false
		// Re-apply orientation-based full screen state
		handleOrientationChange()
	}

	func validateText(_ text: String) -> Bool {
		return text.count <= maxTextLength
	}
	
	private func createTranslationConfiguration(source: Locale, target: Locale) {
		// Create TranslationSession.Configuration for use with translationTask
		var configuration = TranslationSession.Configuration()
		configuration.source = source.language
		configuration.target = target.language

		translationConfiguration = configuration
	}
}

// MARK: - UIDeviceOrientation Extension

extension UIDeviceOrientation {
	var isValidInterfaceOrientation: Bool {
		switch self {
		case .portrait, .portraitUpsideDown, .landscapeLeft, .landscapeRight:
			return true
		default:
			return false
		}
	}
}

