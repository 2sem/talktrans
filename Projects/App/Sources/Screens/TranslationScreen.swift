//
//  TranslationScreen.swift
//  talktrans
//
//  Created by 영준 이 on 11/9/25.
//  Copyright © 2025 leesam. All rights reserved.
//

import SwiftUI
import Translation

struct TranslationScreen: View {
	@StateObject private var viewModel: TranslationViewModel
	@StateObject private var speechViewModel = SpeechRecognitionViewModel()
	@State private var showSpeechRecognition = false
	@FocusState private var isInputFocused: Bool
	
	init() {
		// TranslationSession will be created dynamically in TranslationViewModel
		// when translate button is pressed
		_viewModel = StateObject(wrappedValue: TranslationViewModel())
	}
	
	var body: some View {
		ZStack {
			// Gradient Background
			LinearGradient(
				colors: [
					.appBackgroundGradientStart,
					.appBackgroundGradientMid,
					.appBackgroundGradientEnd
				],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
			)
			.ignoresSafeArea()

			if viewModel.isFullScreen {
				// Full Screen Mode - Only show translated output
				VStack(spacing: 0) {
					TranslationOutputView(
						text: viewModel.translatedText,
						locale: viewModel.translatedLocale,
						availableLocales: viewModel.supportedTargetLocales,
						placeholder: "Translated message will appear here".localized(),
						onLocaleChange: { locale in
							viewModel.updateTranslatedLocale(locale)
						},
						isFullScreen: viewModel.isFullScreen,
						onToggleFullScreen: {
							viewModel.toggleFullScreen()
						},
						deviceOrientation: viewModel.deviceOrientation
					)
					.padding(16)
					
					BannerAdSwiftUIView()
						.frame(height: 50)
                }.transition(.scale)
			} else {
				// Normal Mode - Show all UI elements
				VStack(spacing: 20) {
					// Translated Output Section
					if !showSpeechRecognition && !isInputFocused {
						TranslationOutputView(
							text: viewModel.translatedText,
							locale: viewModel.translatedLocale,
							availableLocales: viewModel.supportedTargetLocales,
							placeholder: "Translated message will appear here".localized(),
							onLocaleChange: { locale in
								viewModel.updateTranslatedLocale(locale)
							},
							isFullScreen: viewModel.isFullScreen,
						onToggleFullScreen: {
							viewModel.toggleFullScreen()
						},
							deviceOrientation: viewModel.deviceOrientation
						)
						.padding(.horizontal, 16)
						.padding(.top, 20)
					}

					// Advertisement Banner Placeholder
					BannerAdSwiftUIView()
						.frame(height: 50)
	//                    .cornerRadius(8)

					// Native Input Section
					TranslationInputView(
						text: $viewModel.nativeText,
						isFocused: $isInputFocused,
						locale: viewModel.nativeLocale,
						availableLocales: TranslationLocale.allCases,
						placeholder: "".appendingFormat("Please input your message to be translated as %@".localized(), viewModel.translatedLocale.displayName.localized()),
						onLocaleChange: { locale in
							viewModel.updateNativeLocale(locale)
						},
						onSwap: {
							viewModel.swapLanguages()
						},
						maxLength: 100
					)
					.padding(.horizontal, 16)

					// Action Buttons
					HStack(spacing: 12) {
						// Translate Button
						Button(action: {
							isInputFocused = false
							viewModel.translate()
						}) {
							HStack {
								if viewModel.isTranslating {
									ProgressView()
										.progressViewStyle(CircularProgressViewStyle(tint: .white))
										.scaleEffect(0.8)
								} else {
									Text("Translate")
										.font(.system(size: 17, weight: .semibold))
								}
							}
							.frame(maxWidth: .infinity)
							.frame(height: 50)
							.background(
								LinearGradient(
									colors: [
										.appAccentGradientStart,
										.appAccentGradientEnd
									],
									startPoint: .leading,
									endPoint: .trailing
								)
							)
							.foregroundColor(.white)
							.cornerRadius(12)
						}
						.disabled(!viewModel.canTranslate)

						// Speech Recognition Button
						Button(action: {
							showSpeechRecognition = true
						}) {
							// Record Icon
							Image(systemName: "mic")
								.font(.system(size: 14, weight: .medium))
								.frame(maxWidth: .infinity)
								.frame(height: 50)
								.background(Color.appSecondaryButton)
								.foregroundColor(.appTextPrimary)
								.cornerRadius(12)
						}
						.buttonStyle(.plain)
					}
					.padding(.horizontal, 16)
					.padding(.bottom, 20)

					Spacer(minLength: 0)
                
					// Error Message
					if let errorMessage = viewModel.errorMessage {
						Text(errorMessage)
							.font(.system(size: 14))
							.foregroundColor(.red)
							.padding(.horizontal, 16)
					}
				}
				.onTapGesture {
					isInputFocused = false
				}
                .transition(.scale)
			}
		}
        .animation(.easeInOut, value: viewModel.isFullScreen)
		.translationTask(viewModel.translationConfiguration) { session in
			// This closure receives the TranslationSession
			// Pass the session to viewModel
			Task { @MainActor in
				viewModel.setTranslationSession(session)
			}
		}
		.sheet(isPresented: $showSpeechRecognition) {
			SpeechRecognitionScreen(
				viewModel: speechViewModel,
				text: $viewModel.nativeText,
				locale: viewModel.nativeLocale.locale,
				processTitle: "Translate",
				onProcess: {
					viewModel.translate()
				}
			)
		}
	}
}

#Preview {
	TranslationScreen()
}

