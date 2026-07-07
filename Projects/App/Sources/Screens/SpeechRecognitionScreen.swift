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
	@State private var transcriptContentHeight: CGFloat = 0
	@State private var isListeningStatusPulsing = false
	@State private var recognitionPrefixText = ""

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
					.padding(.horizontal, hasLongDisplayText ? 32 : 44)
					.padding(.top, 50)

				Spacer(minLength: shouldUseTranscriptFirstMode ? 42 : (hasLongDisplayText ? 78 : 132))

				if !shouldUseTranscriptFirstMode {
					microphoneButton
				}

				recognizedText
					.padding(.top, shouldUseTranscriptFirstMode ? 0 : (hasLongDisplayText ? 34 : 76))

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
			.overlay(alignment: .topLeading) {
				transcriptOverflowMeasurement
			}
		}
		.onChange(of: viewModel.recognizedText) { _, newValue in
			if !newValue.isEmpty {
				text = combinedRecognitionText(newSegment: newValue)
			}
		}
		.onAppear {
			isListeningStatusPulsing = true
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
			HStack(spacing: 10) {
				Text(sourceLocale.flagEmoji)
					.font(.system(size: 15))

				Text(verbatim: hasLongDisplayText ? sourceLocale.displayName : "Speaking \(sourceLocale.displayName)")
					.font(.system(size: hasLongDisplayText ? 16 : 17, weight: .bold))
					.foregroundStyle(Color.duoYouAccentDeep)
					.lineLimit(1)
			}

			if hasLongDisplayText {
				Spacer(minLength: 10)

				if shouldUseTranscriptFirstMode {
					compactListeningControl
				} else {
					listeningStatus
				}
			}
		}
		.padding(.horizontal, hasLongDisplayText ? 16 : 18)
		.padding(.vertical, 12)
		.frame(maxWidth: hasLongDisplayText ? .infinity : nil)
		.background(Color.duoYouAccent.opacity(0.13))
		.clipShape(.capsule)
		.accessibilityElement(children: .combine)
		.accessibilityLabel(hasLongDisplayText ? "Speaking \(sourceLocale.displayName), listening" : "Speaking \(sourceLocale.displayName)")
	}

	private var listeningStatus: some View {
		HStack(spacing: 6) {
			Circle()
				.fill(Color.duoYouAccentDeep)
				.frame(width: 7, height: 7)
				.opacity(viewModel.isRecognizing ? 1 : 0.45)

			Text(verbatim: viewModel.isRecognizing ? "Listening" : "Paused")
				.font(.system(size: 13, weight: .bold))
				.foregroundStyle(Color.duoYouAccentDeep.opacity(0.82))
		}
		.scaleEffect(listeningStatusScale)
		.opacity(listeningStatusOpacity)
		.animation(.easeInOut(duration: 0.85).repeatForever(autoreverses: true), value: isListeningStatusPulsing)
	}

	private var compactListeningControl: some View {
		Button(action: toggleRecognition) {
			HStack(spacing: 8) {
				Circle()
					.fill(Color.duoYouAccentDeep)
					.frame(width: 7, height: 7)
					.opacity(viewModel.isRecognizing ? 1 : 0.45)

				Text(verbatim: viewModel.isRecognizing ? "Stop" : "Continue")
					.font(.system(size: 13, weight: .bold))
					.foregroundStyle(Color.duoYouAccentDeep)
			}
			.scaleEffect(listeningStatusScale)
			.opacity(listeningStatusOpacity)
			.animation(.easeInOut(duration: 0.85).repeatForever(autoreverses: true), value: isListeningStatusPulsing)
			.padding(.horizontal, 12)
			.padding(.vertical, 8)
			.background(Color.duoYouAccent.opacity(0.13))
			.clipShape(.capsule)
			.contentShape(.capsule)
		}
		.buttonStyle(.plain)
		.accessibilityLabel(viewModel.isRecognizing ? "Stop listening" : "Continue speaking")
	}

	private var microphoneButton: some View {
		Button(action: toggleRecognition) {
			ZStack {
				Circle()
					.fill(Color.duoYouAccent.opacity(0.08))
					.frame(width: micOuterDiameter, height: micOuterDiameter)
					.overlay(
						Circle()
							.stroke(Color.duoYouAccent.opacity(0.28), lineWidth: 1.5)
					)
					.scaleEffect(viewModel.isRecognizing ? 1.08 : 1)
					.opacity(viewModel.isRecognizing ? 0.88 : 1)
					.animation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true), value: viewModel.isRecognizing)

				Circle()
					.fill(
						LinearGradient(
							colors: [.duoYouAccent, .duoYouAccentDeep],
							startPoint: .top,
							endPoint: .bottom
						)
					)
					.frame(width: micCoreDiameter, height: micCoreDiameter)
					.shadow(color: Color.duoYouAccent.opacity(0.28), radius: 20, y: 12)

				Image(systemName: "mic.fill")
					.resizable()
					.scaledToFit()
					.frame(width: micIconSize, height: micIconSize)
					.foregroundStyle(.white)
			}
			.frame(width: micOuterDiameter, height: micOuterDiameter)
		}
		.buttonStyle(.plain)
		.accessibilityLabel(viewModel.isRecognizing ? "Stop listening" : "Start listening")
	}

	private var micOuterDiameter: CGFloat {
		hasLongDisplayText ? 142 : 178
	}

	private var micCoreDiameter: CGFloat {
		hasLongDisplayText ? 96 : 118
	}

	private var micIconSize: CGFloat {
		hasLongDisplayText ? 42 : 52
	}

	private var recognizedText: some View {
		Group {
			if hasLongDisplayText || shouldUseTranscriptFirstMode {
				transcriptCard
			} else {
				Text(displayText)
					.font(.system(size: 30, weight: .bold))
					.foregroundStyle(text.isEmpty ? Color.duoTextMuted : Color.duoTextPrimary)
					.multilineTextAlignment(.center)
					.lineSpacing(8)
					.fixedSize(horizontal: false, vertical: true)
					.frame(maxWidth: .infinity)
					.padding(.horizontal, 56)
			}
		}
		.accessibilityLabel(text.isEmpty ? "No recognized text yet" : "Recognized text: \(text)")
	}

	private var transcriptCard: some View {
		ScrollView(.vertical) {
			Text(displayText)
				.font(.system(size: shouldUseTranscriptFirstMode ? 23 : 24, weight: .bold))
				.foregroundStyle(Color.duoTextPrimary)
				.multilineTextAlignment(.center)
				.lineSpacing(6)
				.fixedSize(horizontal: false, vertical: true)
				.frame(maxWidth: .infinity)
				.padding(.bottom, 6)
		}
		.frame(maxHeight: transcriptMaxHeight)
		.scrollBounceBehavior(.basedOnSize)
		.padding(.horizontal, 56)
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

	private var transcriptOverflowMeasurement: some View {
		GeometryReader { proxy in
			Text(displayText)
				.font(.system(size: 24, weight: .bold))
				.lineSpacing(6)
				.fixedSize(horizontal: false, vertical: true)
				.frame(width: max(1, proxy.size.width - transcriptMeasurementHorizontalInset), alignment: .leading)
				.opacity(0)
				.accessibilityHidden(true)
				.background(
					GeometryReader { textProxy in
						Color.clear.preference(key: TranscriptContentHeightKey.self, value: textProxy.size.height)
					}
				)
		}
		.allowsHitTesting(false)
		.frame(height: 0)
		.clipped()
		.onPreferenceChange(TranscriptContentHeightKey.self) { height in
			transcriptContentHeight = height
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

	private var shouldUseTranscriptFirstMode: Bool {
		transcriptNeedsScrolling
	}

	private var transcriptNeedsScrolling: Bool {
		transcriptContentHeight > compactTranscriptMaxHeight + 1
	}

	private var transcriptMaxHeight: CGFloat {
		shouldUseTranscriptFirstMode ? expandedTranscriptMaxHeight : compactTranscriptMaxHeight
	}

	private var compactTranscriptMaxHeight: CGFloat {
		218
	}

	private var expandedTranscriptMaxHeight: CGFloat {
		360
	}

	private var transcriptMeasurementHorizontalInset: CGFloat {
		104
	}

	private var listeningStatusScale: CGFloat {
		viewModel.isRecognizing && isListeningStatusPulsing ? 1.04 : 1
	}

	private var listeningStatusOpacity: Double {
		viewModel.isRecognizing && isListeningStatusPulsing ? 0.72 : 1
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
		recognitionPrefixText = text.trimmingCharacters(in: .whitespacesAndNewlines)
		viewModel.startRecognition(locale: sourceLocale.locale) { _ in
			// Text is mirrored through recognizedText onChange.
		}
	}

	private func combinedRecognitionText(newSegment: String) -> String {
		let trimmedSegment = newSegment.trimmingCharacters(in: .whitespacesAndNewlines)
		guard !recognitionPrefixText.isEmpty else { return trimmedSegment }
		guard !trimmedSegment.isEmpty else { return recognitionPrefixText }

		if recognitionPrefixText.last?.isWhitespace == true {
			return recognitionPrefixText + trimmedSegment
		}

		return recognitionPrefixText + " " + trimmedSegment
	}

	#if targetEnvironment(simulator)
	private func applySimulatorScreenshotMock() {
		let existingText = text.trimmingCharacters(in: .whitespacesAndNewlines)
		let mockText = existingText.isEmpty ? "가장 가까운 지하철역이\n어디예요?" : existingText
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

private struct TranscriptContentHeightKey: PreferenceKey {
	static var defaultValue: CGFloat = 0

	static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
		value = max(value, nextValue())
	}
}
