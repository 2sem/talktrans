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
	@FocusState private var isInputFocused: Bool
	
	var body: some View {
		ZStack {
            // Set Background White
            Color.white
                .ignoresSafeArea()
			// Gradient Background
			LinearGradient(
				colors: [Color.purple.opacity(0.5), Color.pink.opacity(0.5)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
			)
			.ignoresSafeArea()
			
            VStack(spacing: 20) {
                // Translated Output Section
                TranslationOutputView(
                    text: viewModel.translatedText,
                    locale: viewModel.translatedLocale,
                    availableLocales: viewModel.supportedTargetLocales,
                    placeholder: "Translated message will appear here".localized(),
                    onLocaleChange: { locale in
                        viewModel.updateTranslatedLocale(locale)
                    }
                )
                .padding(.horizontal, 16)
                .padding(.top, 20)
                
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
                    }) {
                        // Record Icon
                        Image(systemName: "mic")
                            .font(.system(size: 14, weight: .medium))
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.white)
                            .foregroundColor(.primary)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                        
//                        Text("Speech Recognition")
//                            .font(.system(size: 17, weight: .semibold))
//                            .frame(maxWidth: .infinity)
//                            .frame(height: 50)
//                            .background(Color.white)
//                            .foregroundColor(.primary)
//                            .cornerRadius(12)
//                            .overlay(
//                                RoundedRectangle(cornerRadius: 12)
//                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
//                            )
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
            }
			.contentShape(Rectangle())
			.onTapGesture {
				isInputFocused = false
			}
		}
		.sheet(isPresented: $showSpeechRecognition) {
			SpeechRecognitionScreen(
				viewModel: speechViewModel,
				text: $viewModel.nativeText,
				locale: viewModel.nativeLocale.locale,
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

