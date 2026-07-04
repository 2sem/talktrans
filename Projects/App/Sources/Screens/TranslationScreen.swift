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
					}
				)
				.transition(.scale)
			} else {
				// Normal Mode - Show all UI elements
				VStack(spacing: 8) {
					DuoHeaderView(
						onHistoryTapped: { showHistory = true },
						onSettingsTapped: { }
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
					isInputFocused = false
					showSpeechRecognition = false
					viewModel.translate()
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
}

// MARK: - DuoTableModeView

private struct DuoTableModeView: View {
	let sourceText: String
	let translatedText: String
	let sourceLocale: TranslationLocale
	let targetLocale: TranslationLocale
	let onExit: () -> Void
	let onSpeakToReply: () -> Void

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
				HStack(spacing: -3) {
					Text("↑")
					Text("↓")
				}
					.font(.system(size: 30, weight: .medium, design: .rounded))
					.foregroundStyle(Color.duoTextMuted)
					.frame(width: 92, height: 92)
					.background(Color.duoSurface, in: Circle())
					.shadow(color: .black.opacity(0.14), radius: 28, x: 0, y: 12)
					.accessibilityHidden(true)
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

			VStack(spacing: 22) {
				Spacer(minLength: 42)

				DuoTableModeLanguagePill(
					roleTitle: roleTitle,
					locale: locale,
					accent: accent
				)

				Text(displayText)
					.font(.system(size: isUpsideDown ? 42 : 34, weight: .bold, design: .rounded))
					.foregroundStyle(textColor)
					.multilineTextAlignment(.center)
					.lineSpacing(4)
					.minimumScaleFactor(0.45)
					.lineLimit(4)
					.padding(.horizontal, 30)

				if let onSpeakToReply {
					Button(action: onSpeakToReply) {
						Text("🎤 \("Speak to reply".localized())")
							.font(.system(size: 23, weight: .bold, design: .rounded))
							.foregroundStyle(accent)
							.padding(.horizontal, 28)
							.frame(minHeight: 72)
							.background(Color.duoSurface, in: RoundedRectangle(cornerRadius: 26, style: .continuous))
							.shadow(color: .black.opacity(0.08), radius: 16, x: 0, y: 8)
					}
					.buttonStyle(.plain)
				}

				Spacer(minLength: isUpsideDown ? 82 : 62)
			}
			.frame(maxWidth: .infinity, maxHeight: .infinity)

			if let onExit {
				Button(action: onExit) {
					Text("× \("Exit".localized())")
						.font(.system(size: 19, weight: .bold, design: .rounded))
						.foregroundStyle(textColor)
						.padding(.horizontal, 20)
						.frame(minHeight: 58)
						.background(Color.duoSurface, in: Capsule())
						.shadow(color: .black.opacity(0.08), radius: 14, x: 0, y: 8)
				}
				.buttonStyle(.plain)
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
	let onSettingsTapped: () -> Void

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

				Button(action: onSettingsTapped) {
					Image(systemName: "gearshape")
						.font(.system(size: 14, weight: .semibold))
						.foregroundStyle(Color.duoYouAccent)
						.frame(width: 32, height: 32)
						.background(Color.duoSurface, in: Circle())
				}
				.accessibilityLabel("Settings")
			}
		}
		.font(.system(size: 19, weight: .bold))
		.accessibilityElement(children: .combine)
		.accessibilityLabel("TalkTrans")
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
