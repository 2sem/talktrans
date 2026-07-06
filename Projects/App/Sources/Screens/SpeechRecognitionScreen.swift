//
//  SpeechRecognitionScreen.swift
//  App
//
//  Created by 영준 이 on 11/17/25.
//
import SwiftUI

struct SpeechRecognitionScreen: View {
	@ObservedObject var viewModel: SpeechRecognitionViewModel
	@Binding var text: String
	let sourceLocale: TranslationLocale
	let targetLocale: TranslationLocale
	var processTitle: String?
	var onProcess: (() -> Void)?
	var onCancel: (() -> Void)?

	var body: some View {
		ZStack {
			LinearGradient(
				colors: [
					.duoBackground,
					.duoBackground,
					.duoYouAccent.opacity(0.05),
					.duoThemAccent.opacity(0.04)
				],
				startPoint: .top,
				endPoint: .bottom
			)
			.ignoresSafeArea()

			VStack(spacing: 0) {
				speakerPill
					.frame(maxWidth: .infinity, alignment: .leading)
					.padding(.horizontal, 44)
					.padding(.top, 50)

				Spacer(minLength: 132)

				microphoneButton

				recognizedText
					.padding(.top, hasLongDisplayText ? 44 : 76)

				if shouldShowErrorMessage, let errorMessage = viewModel.errorMessage {
					errorMessageView(errorMessage)
						.padding(.top, 18)
						.padding(.horizontal, 40)
				}

				Spacer(minLength: 34)

				actionButtons
					.padding(.horizontal, 32)
					.padding(.bottom, 64)
			}
			.frame(maxWidth: .infinity, maxHeight: .infinity)
		}
		.onChange(of: viewModel.recognizedText) { _, newValue in
			if !newValue.isEmpty {
				text = newValue
			}
		}
		.onAppear {
			viewModel.resetSessionState()
			#if targetEnvironment(simulator)
			applySimulatorScreenshotMock()
			#else
			startRecognition()
			#endif
		}
		.onDisappear {
			viewModel.stopRecognition()
		}
	}

	private var speakerPill: some View {
		HStack(spacing: 10) {
			Text(sourceLocale.flagEmoji)
				.font(.system(size: 15))

			Text(verbatim: "Speaking \(sourceLocale.displayName)")
				.font(.system(size: 17, weight: .bold))
				.foregroundStyle(Color.duoYouAccentDeep)
		}
		.padding(.horizontal, 18)
		.padding(.vertical, 12)
		.background(Color.duoYouAccent.opacity(0.13))
		.clipShape(.capsule)
		.accessibilityElement(children: .combine)
		.accessibilityLabel("Speaking \(sourceLocale.displayName)")
	}

	private var microphoneButton: some View {
		Button(action: toggleRecognition) {
			ZStack {
				Circle()
					.fill(Color.duoYouAccent.opacity(0.08))
					.frame(width: 178, height: 178)
					.overlay(
						Circle()
							.stroke(Color.duoYouAccent.opacity(0.28), lineWidth: 1.5)
					)
					.scaleEffect(viewModel.isRecognizing ? 1.08 : 1)

				Circle()
					.fill(
						LinearGradient(
							colors: [.duoYouAccent, .duoYouAccentDeep],
							startPoint: .top,
							endPoint: .bottom
						)
					)
					.frame(width: 118, height: 118)
					.shadow(color: Color.duoYouAccent.opacity(0.28), radius: 20, y: 12)

				Image(systemName: viewModel.isRecognizing ? "stop.fill" : "mic.fill")
					.font(.system(size: 44, weight: .semibold))
					.foregroundStyle(.white)
			}
			.animation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true), value: viewModel.isRecognizing)
		}
		.buttonStyle(.plain)
		.accessibilityLabel(viewModel.isRecognizing ? "Stop listening" : "Start listening")
	}

	private var recognizedText: some View {
		ScrollView(.vertical) {
			Text(displayText)
				.font(.system(size: hasLongDisplayText ? 24 : 30, weight: .bold))
				.foregroundStyle(text.isEmpty ? Color.duoTextMuted : Color.duoTextPrimary)
				.multilineTextAlignment(.center)
				.lineSpacing(hasLongDisplayText ? 6 : 8)
				.fixedSize(horizontal: false, vertical: true)
				.frame(maxWidth: .infinity)
				.padding(.horizontal, 56)
		}
		.frame(maxHeight: hasLongDisplayText ? 220 : 150)
		.scrollBounceBehavior(.basedOnSize)
		.accessibilityLabel(text.isEmpty ? "No recognized text yet" : "Recognized text: \(text)")
	}

	private var actionButtons: some View {
		HStack(spacing: 20) {
			Button(action: cancel) {
				Text(verbatim: "Cancel")
					.font(.system(size: 18, weight: .bold))
					.frame(maxWidth: .infinity)
					.frame(height: 64)
					.background(Color.duoControlSurface)
					.foregroundStyle(Color.duoTextSecondary)
					.clipShape(.rect(cornerRadius: 18, style: .continuous))
			}

			if let onProcess, let processTitle {
				Button(action: {
					viewModel.stopRecognition()
					onProcess()
				}) {
					Text(verbatim: processTitle)
						.font(.system(size: 18, weight: .bold))
						.frame(maxWidth: .infinity)
						.frame(height: 64)
						.background(
							LinearGradient(
								colors: [.duoThemAccent, .duoThemAccentDeep],
								startPoint: .leading,
								endPoint: .trailing
							)
						)
						.foregroundStyle(.white)
						.clipShape(.rect(cornerRadius: 18, style: .continuous))
				}
				.disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
				.opacity(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.72 : 1)
			}
		}
	}

	private var shouldShowErrorMessage: Bool {
		#if targetEnvironment(simulator)
		return false
		#else
		return true
		#endif
	}

	private var displayText: String {
		let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
		if !trimmedText.isEmpty {
			return trimmedText
		}

		if viewModel.errorMessage != nil {
			return "Tap mic to try again"
		}

		return "Listening…"
	}

	private var hasLongDisplayText: Bool {
		displayText.count > 80 || displayText.components(separatedBy: .newlines).count > 3
	}

	private func errorMessageView(_ message: String) -> some View {
		Text(message)
			.font(.system(size: 14, weight: .semibold))
			.foregroundStyle(Color.duoYouAccentDeep)
			.multilineTextAlignment(.center)
			.padding(14)
			.frame(maxWidth: .infinity)
			.background(Color.duoYouAccent.opacity(0.12))
			.clipShape(.rect(cornerRadius: 16, style: .continuous))
	}

	private func toggleRecognition() {
		#if targetEnvironment(simulator)
		applySimulatorScreenshotMock()
		return
		#else
		if viewModel.isRecognizing {
			viewModel.stopRecognition()
			return
		}

		startRecognition()
		#endif
	}

	private func startRecognition() {
		viewModel.startRecognition(locale: sourceLocale.locale) { _ in
			// Text is mirrored through recognizedText onChange.
		}
	}

	#if targetEnvironment(simulator)
	private func applySimulatorScreenshotMock() {
		let mockText = "가장 가까운 지하철역이\n어디예요?"
		viewModel.stopRecognition()
		viewModel.errorMessage = nil
		viewModel.recognizedText = mockText
		text = mockText
	}
	#else
	private func applySimulatorScreenshotMock() { }
	#endif

	private func cancel() {
		viewModel.stopRecognition()
		onCancel?()
	}
}
