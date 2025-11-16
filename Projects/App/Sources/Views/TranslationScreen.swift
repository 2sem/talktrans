//
//  TranslationScreen.swift
//  talktrans
//
//  Created by 영준 이 on 11/9/25.
//  Copyright © 2025 leesam. All rights reserved.
//

import SwiftUI

struct TranslationScreen: View {
	@StateObject private var viewModel = TranslationViewModel()
	@StateObject private var speechViewModel = SpeechRecognitionViewModel()
	@State private var showSpeechRecognition = false
	
	var body: some View {
		ZStack {
			// Gradient Background
			LinearGradient(
				colors: [Color.purple.opacity(0.3), Color.pink.opacity(0.2)],
				startPoint: .top,
				endPoint: .bottom
			)
			.ignoresSafeArea()
			
			ScrollView {
				VStack(spacing: 20) {
					// Translated Output Section
					TranslationOutputView(
						text: viewModel.translatedText,
						locale: viewModel.translatedLocale,
						availableLocales: viewModel.supportedTargetLocales,
						placeholder: "Translated message will appear here",
						onLocaleChange: { locale in
							viewModel.updateTranslatedLocale(locale)
						}
					)
					.padding(.horizontal, 16)
					.padding(.top, 20)
					
					// Native Input Section
					TranslationInputView(
						text: $viewModel.nativeText,
						locale: viewModel.nativeLocale,
						availableLocales: TranslationLocale.allCases,
						placeholder: "Please input your message to be translated as \(viewModel.translatedLocale.displayName)",
						onLocaleChange: { locale in
							viewModel.updateNativeLocale(locale)
						},
						maxLength: 100
					)
					.padding(.horizontal, 16)
					
					// Action Buttons
					HStack(spacing: 12) {
						// Translate Button
						Button(action: {
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
							.background(viewModel.canTranslate ? Color.purple : Color.gray)
							.foregroundColor(.white)
							.cornerRadius(12)
						}
						.disabled(!viewModel.canTranslate)
						
						// Speech Recognition Button
						Button(action: {
							showSpeechRecognition = true
							speechViewModel.startRecognition(locale: viewModel.nativeLocale.locale) { recognizedText in
								viewModel.nativeText = recognizedText
							}
						}) {
							Text("Speech Recognition")
								.font(.system(size: 17, weight: .semibold))
								.frame(maxWidth: .infinity)
								.frame(height: 50)
								.background(Color.white)
								.foregroundColor(.primary)
								.cornerRadius(12)
								.overlay(
									RoundedRectangle(cornerRadius: 12)
										.stroke(Color.gray.opacity(0.3), lineWidth: 1)
								)
						}
					}
					.padding(.horizontal, 16)
					
					// Error Message
					if let errorMessage = viewModel.errorMessage {
						Text(errorMessage)
							.font(.system(size: 14))
							.foregroundColor(.red)
							.padding(.horizontal, 16)
					}
					
					// Advertisement Banner Placeholder
					Rectangle()
						.fill(Color.white)
						.frame(height: 50)
						.cornerRadius(8)
						.overlay(
							Text("Advertisement")
								.font(.system(size: 14))
								.foregroundColor(.secondary)
						)
						.padding(.horizontal, 16)
						.padding(.bottom, 20)
				}
			}
		}
		.sheet(isPresented: $showSpeechRecognition) {
			SpeechRecognitionSheet(
				viewModel: speechViewModel,
				translationViewModel: viewModel,
				isPresented: $showSpeechRecognition
			)
		}
	}
}

struct SpeechRecognitionSheet: View {
	@ObservedObject var viewModel: SpeechRecognitionViewModel
	@ObservedObject var translationViewModel: TranslationViewModel
	@Binding var isPresented: Bool
	
	var body: some View {
		VStack(spacing: 20) {
			Text("Recognizing...")
				.font(.system(size: 20, weight: .semibold))
				.padding(.top, 20)
			
			Text("Please say sentence to be recognized")
				.font(.system(size: 16))
				.foregroundColor(.secondary)
			
			if viewModel.isRecognizing {
				ProgressView()
					.scaleEffect(1.5)
					.padding()
			}
			
			if !viewModel.recognizedText.isEmpty {
				Text(viewModel.recognizedText)
					.font(.system(size: 16))
					.padding()
					.frame(maxWidth: .infinity, alignment: .leading)
					.background(Color.gray.opacity(0.1))
					.cornerRadius(12)
					.padding(.horizontal, 20)
			}
			
			if let errorMessage = viewModel.errorMessage {
				Text(errorMessage)
					.font(.system(size: 14))
					.foregroundColor(.red)
					.padding(.horizontal, 20)
			}
			
			HStack(spacing: 12) {
				Button(action: {
					viewModel.stopRecognition()
					isPresented = false
				}) {
					Text("Done")
						.font(.system(size: 17, weight: .semibold))
						.frame(maxWidth: .infinity)
						.frame(height: 50)
						.background(Color.gray.opacity(0.2))
						.foregroundColor(.primary)
						.cornerRadius(12)
				}
				
				Button(action: {
					viewModel.stopRecognition()
					translationViewModel.translate()
					isPresented = false
				}) {
					Text("Translate")
						.font(.system(size: 17, weight: .semibold))
						.frame(maxWidth: .infinity)
						.frame(height: 50)
						.background(Color.purple)
						.foregroundColor(.white)
						.cornerRadius(12)
				}
			}
			.padding(.horizontal, 20)
			.padding(.bottom, 20)
			
			Spacer()
		}
		.onDisappear {
			viewModel.stopRecognition()
		}
	}
}

#Preview {
	TranslationScreen()
}

