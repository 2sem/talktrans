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

@MainActor
class TranslationViewModel: ObservableObject {
	@Published var nativeText: String = ""
	@Published var translatedText: String = ""
	@Published var nativeLocale: TranslationLocale = .english
	@Published var translatedLocale: TranslationLocale = .korean
	@Published var isTranslating: Bool = false
	@Published var isRecognizing: Bool = false
	@Published var errorMessage: String?
	
	private let translationManager = TranslationManager.shared
	private let maxTextLength = 100
	
	var canTranslate: Bool {
		!nativeText.isEmpty && !isTranslating
	}
	
	var supportedTargetLocales: [TranslationLocale] {
		let sourceLocale = nativeLocale.locale
		return translationManager.supportedTargetLangs(source: sourceLocale)
	}
	
	init() {
		// Initialize with current locale
		if let currentLocale = TranslationLocale.from(locale: Locale.current) {
			nativeLocale = currentLocale
		}
		
		// Set default translated locale (Korean if native is not Korean, otherwise English)
		if nativeLocale != .korean {
			translatedLocale = .korean
		} else {
			translatedLocale = .english
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
		
		translationManager.requestTranslate(
			text: nativeText,
			from: sourceLocale,
			to: targetLocale
		) { [weak self] result in
			Task { @MainActor in
				self?.isTranslating = false
				switch result {
				case .success(let translated):
					self?.translatedText = translated
				case .failure(let error):
					self?.errorMessage = error.localizedDescription
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
	
	func validateText(_ text: String) -> Bool {
		return text.count <= maxTextLength
	}
}

