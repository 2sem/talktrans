//
//  TranslationScreen.swift
//  talktrans
//
//  Created by 영준 이 on 11/9/25.
//  Copyright © 2025 leesam. All rights reserved.
//

import SwiftUI
import Translation
import SwiftData

struct TranslationScreen: View {
	@StateObject private var viewModel: TranslationViewModel
	@StateObject private var speechViewModel = SpeechRecognitionViewModel()
	@EnvironmentObject private var reviewManager: ReviewManager
	@EnvironmentObject private var adManager: SwiftUIAdManager
	@Environment(\.modelContext) private var modelContext
	@State private var showSpeechRecognition = false
	@State private var showHistory = false
	@State private var showAdFreeToast = false
	@State private var lastHandledTranslationID: UUID?
	@State private var isTableModePresented = false
	@State private var lastTableModeTranslationInput = ""
	@FocusState private var isInputFocused: Bool

	private let topContentPadding: CGFloat = 12

	init() {
		// TranslationSession will be created dynamically in TranslationViewModel
		// when translate button is pressed
		_viewModel = StateObject(wrappedValue: TranslationViewModel())
	}

	var body: some View {
		let sessionBindingRequestID = viewModel.sessionBindingRequestID

		ZStack {
			LinearGradient(
				colors: [
					.duoBackground,
					.duoBackground,
					.duoThemAccent.opacity(0.08),
					.duoYouAccent.opacity(0.06)
				],
				startPoint: .topLeading,
				endPoint: .bottomTrailing
			)
			.ignoresSafeArea()

			if isTableModePresented {
				DuoTableModeView(
					sourceText: viewModel.nativeText,
					translatedText: viewModel.translatedText,
					sourceLocale: viewModel.nativeLocale,
					targetLocale: viewModel.translatedLocale,
					onExit: {
						isTableModePresented = false
					},
					onSpeakToReply: {
						showSpeechRecognition = true
					},
					onSwap: {
						viewModel.swapLanguages()
					}
				)
				.transition(.scale)
			} else {
				// Normal Mode - Show all UI elements
				VStack(spacing: 8) {
					DuoHeaderView(
						onHistoryTapped: { showHistory = true }
					)
						.padding(.horizontal, 18)
						.padding(.top, topContentPadding)

					DuoModeSelectorView(
						isSpeechSelected: showSpeechRecognition,
						onTypeTapped: { showSpeechRecognition = false },
						onSpeakTapped: { showSpeechRecognition = true }
					)
						.padding(.horizontal, 16)

					// Translated Output Section
					if !isInputFocused {
						TranslationOutputView(
							text: viewModel.translatedText,
							locale: viewModel.translatedLocale,
							sourceLocale: viewModel.nativeLocale,
							availableLocales: viewModel.supportedTargetLocales,
							placeholder: "Translated message will appear here".localized(),
							onLocaleChange: { locale in
								viewModel.updateTranslatedLocale(locale)
							},
							onSwap: {
								viewModel.swapLanguages()
							},
							isFullScreen: false,
							onToggleFullScreen: { },
							deviceOrientation: viewModel.deviceOrientation
						)
						.frame(maxHeight: .infinity)
						.layoutPriority(1)
						.padding(.horizontal, 16)
					}

					if !SwiftUIAdManager.isDisabled, !adManager.isAdFree {
						GeometryReader { proxy in
							BannerAdSwiftUIView(adWidth: proxy.size.width)
								.frame(maxWidth: .infinity, minHeight: 50, maxHeight: 50)
						}
						.frame(height: 50)
						.padding(.horizontal, 16)
					}

					// Native Input Section
					TranslationInputView(
						text: $viewModel.nativeText,
						isFocused: $isInputFocused,
						locale: viewModel.nativeLocale,
						targetLocale: viewModel.translatedLocale,
						availableLocales: TranslationLocale.allCases,
						placeholder: "".appendingFormat("Please input your message to be translated as %@".localized(), viewModel.translatedLocale.displayName.localized()),
						onLocaleChange: { locale in
							viewModel.updateNativeLocale(locale)
						},
						onSwap: {
							viewModel.swapLanguages()
						},
						onHistoryTapped: {
							showHistory = true
						},
						maxLength: 500
					)
					.frame(maxHeight: .infinity)
					.layoutPriority(1)
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
							.frame(height: 52)
							.background(
								LinearGradient(
									colors: [
										.duoThemAccent,
										.duoThemAccentDeep
									],
									startPoint: .leading,
									endPoint: .trailing
								)
							)
							.foregroundStyle(.white)
							.clipShape(.rect(cornerRadius: 16, style: .continuous))
						}
						.disabled(!viewModel.canTranslate)

						Button(action: {
							isInputFocused = false
							lastTableModeTranslationInput = viewModel.nativeText.trimmingCharacters(in: .whitespacesAndNewlines)
							isTableModePresented = true
						}) {
							Image(systemName: "person.line.dotted.person.fill")
								.font(.system(size: 18, weight: .semibold))
								.frame(width: 52, height: 52)
								.background(Color.duoThemAccent.opacity(0.14))
								.foregroundStyle(Color.duoThemAccentDeep)
								.clipShape(.rect(cornerRadius: 16, style: .continuous))
								.overlay(
									RoundedRectangle(cornerRadius: 16, style: .continuous)
										.stroke(Color.duoThemAccent.opacity(0.24), lineWidth: 1)
								)
						}
						.buttonStyle(.plain)
						.accessibilityLabel("Table Mode")
					}
					.padding(.horizontal, 16)
					.padding(.bottom, 8)

					// Error Message (moved here, before Spacer)
					if let errorMessage = viewModel.errorMessage {
						Text(errorMessage)
							.font(.system(size: 14))
							.foregroundColor(.red)
							.padding(.horizontal, 16)
					}

				}
				.safeAreaPadding(.bottom, 12)
				.onTapGesture {
					isInputFocused = false
				}
				.transition(.scale)
			}
		}
		.statusBarHidden(isTableModePresented)
		.onChange(of: viewModel.lastCompletedTranslationID) { _, newValue in
			guard let translationID = newValue else { return }
			guard translationID != lastHandledTranslationID else { return }
			lastHandledTranslationID = translationID
			reviewManager.show()
			saveTranslationEntry()
		}
		.onChange(of: viewModel.nativeText) { _, _ in
			translateTableModeInputIfNeeded()
		}
		.onChange(of: showSpeechRecognition) { _, isPresented in
			guard !isPresented else { return }
			translateTableModeInputIfNeeded()
		}
		.animation(.easeInOut, value: isTableModePresented)
		.translationTask(viewModel.translationConfiguration) { [sessionBindingRequestID] session in
			await viewModel.setTranslationSession(session, for: sessionBindingRequestID)
		}
		.fullScreenCover(isPresented: $showSpeechRecognition) {
			SpeechRecognitionScreen(
				viewModel: speechViewModel,
				text: $viewModel.nativeText,
				sourceLocale: viewModel.nativeLocale,
				targetLocale: viewModel.translatedLocale,
				processTitle: "Use & translate",
				onProcess: {
					processRecognizedSpeech()
				},
				onCancel: {
					showSpeechRecognition = false
				}
			)
		}
		.sheet(isPresented: $showHistory) {
			HistoryScreen { sourceText, translatedText, sourceLang, targetLang in
				applyRetranslate(sourceText: sourceText, translatedText: translatedText, sourceLang: sourceLang, targetLang: targetLang)
			}
		}
	}

	// MARK: - Private helpers

	private func saveTranslationEntry() {
		let entry = TranslationEntry(
			sourceText: viewModel.nativeText,
			translatedText: viewModel.translatedText,
			sourceLang: viewModel.nativeLocale.rawValue,
			targetLang: viewModel.translatedLocale.rawValue
		)
		modelContext.insert(entry)
	}

	private func applyRetranslate(sourceText: String, translatedText: String, sourceLang: String, targetLang: String) {
		if let source = TranslationLocale(rawValue: sourceLang) {
			viewModel.updateNativeLocale(source)
		}
		if let target = TranslationLocale(rawValue: targetLang) {
			viewModel.updateTranslatedLocale(target)
		}
		viewModel.nativeText = sourceText
		viewModel.translatedText = translatedText
	}

	private func processRecognizedSpeech() {
		isInputFocused = false
		showSpeechRecognition = false

		Task { @MainActor in
			await Task.yield()
			if isTableModePresented {
				translateTableModeInputIfNeeded()
			} else {
				viewModel.translate()
			}
		}
	}

	private func translateTableModeInputIfNeeded() {
		guard isTableModePresented else { return }
		guard !showSpeechRecognition else { return }

		let currentInput = viewModel.nativeText.trimmingCharacters(in: .whitespacesAndNewlines)
		guard !currentInput.isEmpty else { return }
		guard currentInput != lastTableModeTranslationInput else { return }
		guard !viewModel.isTranslating else { return }

		lastTableModeTranslationInput = currentInput
		viewModel.translate()
	}
}

// MARK: - DuoTableModeView

private struct DuoTableModeView: View {
	let sourceText: String
	let translatedText: String
	let sourceLocale: TranslationLocale
	let targetLocale: TranslationLocale
	let onExit: () -> Void
	let onSpeakToReply: () -> Void
	let onSwap: () -> Void

	var body: some View {
		GeometryReader { proxy in
			VStack(spacing: 0) {
				DuoTableModePanel(
					roleTitle: "THEM".localized(),
					locale: targetLocale,
					text: translatedText,
					placeholder: "Translated message will appear here".localized(),
					accent: .duoThemAccentDeep,
					textColor: .duoTableThemText,
					backgroundColors: [.duoTableThemBackground, .duoTableThemBackgroundDeep],
					isUpsideDown: true
				)
				.frame(height: proxy.size.height / 2)

				DuoTableModePanel(
					roleTitle: "YOU".localized(),
					locale: sourceLocale,
					text: sourceText,
					placeholder: "Please input your message".localized(),
					accent: .duoYouAccentDeep,
					textColor: .duoTableYouText,
					backgroundColors: [.duoTableYouBackground, .duoTableYouBackgroundDeep],
					isUpsideDown: false,
					onExit: onExit,
					onSpeakToReply: onSpeakToReply
				)
				.frame(height: proxy.size.height / 2)
			}
			.overlay(alignment: .center) {
				Button(action: onSwap) {
					HStack(spacing: -3) {
						Text("↑")
						Text("↓")
					}
						.font(.system(size: 22, weight: .medium, design: .rounded))
						.foregroundStyle(Color.duoTextMuted)
						.frame(width: 64, height: 64)
						.background(Color.duoSurface, in: Circle())
						.shadow(color: .black.opacity(0.12), radius: 18, x: 0, y: 8)
				}
				.buttonStyle(.plain)
				.contentShape(Circle())
				.accessibilityLabel("Swap languages".localized())
			}
		}
		.ignoresSafeArea()
		.background(Color.duoBackground)
		.statusBarHidden(true)
		.accessibilityElement(children: .contain)
	}
}

private struct DuoTableModePanel: View {
	let roleTitle: String
	let locale: TranslationLocale
	let text: String
	let placeholder: String
	let accent: Color
	let textColor: Color
	let backgroundColors: [Color]
	let isUpsideDown: Bool
	var onExit: (() -> Void)?
	var onSpeakToReply: (() -> Void)?

	private var displayText: String {
		text.isEmpty ? placeholder : text
	}

	var body: some View {
		ZStack(alignment: .topTrailing) {
			LinearGradient(
				colors: backgroundColors,
				startPoint: .topLeading,
				endPoint: .bottomTrailing
			)

			GeometryReader { proxy in
				let hasLongText = displayText.count > 80
				let textMaxHeight = max(150, proxy.size.height * (onSpeakToReply == nil ? 0.48 : 0.44))
				let textFontSize: CGFloat = hasLongText ? (isUpsideDown ? 34 : 28) : (isUpsideDown ? 42 : 34)
				let topSpacerHeight: CGFloat = hasLongText ? 24 : 42
				let bottomSpacerHeight: CGFloat = hasLongText ? 28 : (isUpsideDown ? 82 : 62)

				VStack(spacing: 22) {
					Spacer(minLength: topSpacerHeight)

					DuoTableModeLanguagePill(
						roleTitle: roleTitle,
						locale: locale,
						accent: accent
					)

					ScrollView(.vertical) {
						Text(displayText)
							.font(.system(size: textFontSize, weight: .bold, design: .rounded))
							.foregroundStyle(textColor)
							.multilineTextAlignment(.center)
							.lineSpacing(4)
							.minimumScaleFactor(0.45)
							.fixedSize(horizontal: false, vertical: true)
							.padding(.horizontal, 30)
							.frame(maxWidth: .infinity)
					}
					.frame(maxHeight: textMaxHeight)
					.scrollBounceBehavior(.basedOnSize)
					.accessibilityLabel(displayText)

					if let onSpeakToReply {
						Button(action: onSpeakToReply) {
							Text("🎤 \("Speak to reply".localized())")
								.font(.system(size: 18, weight: .bold, design: .rounded))
								.foregroundStyle(accent)
								.padding(.horizontal, 20)
								.frame(minHeight: 42)
								.background(Color.duoSurface, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
								.shadow(color: .black.opacity(0.07), radius: 12, x: 0, y: 6)
						}
						.buttonStyle(.plain)
						.padding(.vertical, 12)
						.padding(.horizontal, 10)
						.contentShape(Rectangle())
						.accessibilityLabel("Speak to reply".localized())
					}

					Spacer(minLength: bottomSpacerHeight)
				}
				.frame(maxWidth: .infinity, maxHeight: .infinity)
			}

			if let onExit {
				Button(action: onExit) {
					Text("× \("Exit".localized())")
						.font(.system(size: 14, weight: .bold, design: .rounded))
						.foregroundStyle(textColor)
						.padding(.horizontal, 13)
						.frame(minHeight: 34)
						.background(Color.duoSurface, in: Capsule())
						.shadow(color: .black.opacity(0.07), radius: 10, x: 0, y: 5)
				}
				.buttonStyle(.plain)
				.padding(.vertical, 10)
				.padding(.horizontal, 8)
				.contentShape(Rectangle())
				.accessibilityLabel("Exit".localized())
				.padding(.top, 32)
				.padding(.trailing, 34)
			}
		}
		.rotationEffect(.degrees(isUpsideDown ? 180 : 0))
	}
}

private struct DuoTableModeLanguagePill: View {
	let roleTitle: String
	let locale: TranslationLocale
	let accent: Color

	var body: some View {
		HStack(spacing: 8) {
			Text(locale.flagEmoji)
				.font(.system(size: 18))

			Text("\(roleTitle) · \(locale.displayName.uppercased())")
				.font(.system(size: 19, weight: .bold, design: .rounded))
				.foregroundStyle(accent)
				.tracking(1.6)
		}
		.padding(.horizontal, 24)
		.frame(minHeight: 54)
		.background(Color.duoSurface, in: Capsule())
		.shadow(color: .black.opacity(0.08), radius: 14, x: 0, y: 8)
		.accessibilityElement(children: .combine)
	}
}

// MARK: - DuoHeaderView

private struct DuoHeaderView: View {
	let onHistoryTapped: () -> Void

	var body: some View {
		HStack(spacing: 12) {
			HStack(spacing: 0) {
				Text("Talk")
					.foregroundStyle(Color.duoTextPrimary)
				Text("Trans")
					.foregroundStyle(Color.duoThemAccent)
			}

			Spacer()

			HStack(spacing: 8) {
				Button(action: onHistoryTapped) {
					Image(systemName: "clock.arrow.circlepath")
						.font(.system(size: 14, weight: .semibold))
						.foregroundStyle(Color.duoThemAccent)
						.frame(width: 32, height: 32)
						.background(Color.duoSurface, in: Circle())
				}
				.accessibilityLabel("Translation history")

				WatchAdButton(
					size: 32,
					cornerRadius: 16,
					iconSize: 14,
					backgroundColor: .duoSurface,
					backgroundOpacity: 1,
					borderOpacity: 0
				)
			}
		}
		.font(.system(size: 19, weight: .bold))
	}
}

// MARK: - DuoModeSelectorView

private struct DuoModeSelectorView: View {
	let isSpeechSelected: Bool
	let onTypeTapped: () -> Void
	let onSpeakTapped: () -> Void

	var body: some View {
		HStack(spacing: 0) {
			modeItem(title: "Type", systemImage: "keyboard", isSelected: !isSpeechSelected, action: onTypeTapped)
			modeItem(title: "Speak", systemImage: "mic", isSelected: isSpeechSelected, action: onSpeakTapped)
		}
		.padding(3)
		.background(Color.duoControlSurface.opacity(0.7), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
		.accessibilityLabel("Input mode")
	}

	private func modeItem(title: String, systemImage: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
		Button(action: action) {
			HStack(spacing: 6) {
				Image(systemName: systemImage)
				Text(title.localized())
			}
			.font(.system(size: 13, weight: .semibold))
			.foregroundStyle(isSelected ? Color.duoTextPrimary : Color.duoTextMuted)
			.frame(maxWidth: .infinity)
			.padding(.vertical, 8)
			.background(
				Group {
					if isSelected {
						RoundedRectangle(cornerRadius: 9, style: .continuous)
							.fill(Color.duoSurface)
					}
				}
			)
		}
		.buttonStyle(.plain)
		.accessibilityAddTraits(isSelected ? [.isSelected] : [])
	}
}

#Preview {
	TranslationScreen()
}
