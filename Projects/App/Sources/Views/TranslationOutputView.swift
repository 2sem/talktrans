//
//  TranslationOutputView.swift
//  talktrans
//
//  Created by 영준 이 on 11/9/25.
//  Copyright © 2025 leesam. All rights reserved.
//

import SwiftUI

struct TranslationOutputView: View {
	let text: String
	let locale: TranslationLocale
	let availableLocales: [TranslationLocale]
	let placeholder: String
	let onLocaleChange: (TranslationLocale) -> Void
	let isFullScreen: Bool
	let onToggleFullScreen: () -> Void
	let deviceOrientation: UIDeviceOrientation
	@State private var fontSize: CGFloat = LSDefaults.translationOutputFontSize
	@State private var magnification: CGFloat = 1.0
	@State private var isFontSizeSheetPresented: Bool = false
	@State private var showLanguagePicker = false

	// Computed property for effective font size with constraints
	private var effectiveFontSize: CGFloat {
		let size = fontSize * magnification
		return min(max(size, 16), 48) // Constrain between 16 (default) and 48 points
	}

	// Computed property for rotation angle based on device orientation
	private var effectiveRotationAngle: Double {
		// Duo Table Mode stays upright; the old manual rotation control is removed.
		0
	}

	private var textAreaHeight: CGFloat? {
		isFullScreen ? nil : 170
	}

	var body: some View {
		VStack(spacing: 0) {
			HStack(spacing: 10) {
				DuoOutputFlagButton(locale: locale) {
					showLanguagePicker = true
				}

				DuoOutputRoleBadge(
					locale: locale,
					label: "\(locale.rawValue.uppercased()) · for them",
					accent: .duoThemAccent
				)

				Spacer()

				Button(action: {
					isFontSizeSheetPresented = true
				}) {
					Image(systemName: "textformat.size")
						.font(.system(size: 14, weight: .medium))
						.foregroundStyle(Color.duoThemAccent)
						.frame(width: 32, height: 32)
						.background(Color.duoThemAccent.opacity(0.12), in: Circle())
				}
				.rotationEffect(.degrees(-effectiveRotationAngle))
				.sheet(isPresented: $isFontSizeSheetPresented) {
					FontSizeSheetView(fontSize: $fontSize)
						.presentationDetents([.height(220)])
						.presentationDragIndicator(.visible)
				}

				// Share Button
				if !text.isEmpty {
					ShareLink(item: text) {
						Image(systemName: "square.and.arrow.up")
							.font(.system(size: 14, weight: .medium))
							.foregroundStyle(Color.duoThemAccent)
							.frame(width: 32, height: 32)
							.background(Color.duoThemAccent.opacity(0.12), in: Circle())
					}
					.rotationEffect(.degrees(-effectiveRotationAngle))
				}

			}
			.sheet(isPresented: $showLanguagePicker) {
				LanguageSelectionScreen(
					languages: availableLocales,
					selectedLocale: locale,
					onSelect: onLocaleChange
				)
				.presentationDetents([.medium, .large])
			}
			.padding(.horizontal, 15)
			.padding(.top, 15)
			.padding(.bottom, 11)

			Divider()
				.overlay(Color.duoDivider.opacity(0.65))
				.padding(.horizontal, 15)

			ZStack(alignment: .bottomTrailing) {
				ZStack(alignment: .topLeading) {
					if text.isEmpty {
						Text(placeholder)
							.font(.system(size: effectiveFontSize))
							.foregroundStyle(Color.duoTextMuted)
							.padding(.horizontal, 16)
							.padding(.vertical, 12)
					}

					ScrollView {
						Text(text)
							.font(.system(size: effectiveFontSize))
							.foregroundStyle(Color.duoTextPrimary)
							.frame(maxWidth: .infinity, alignment: .leading)
							.padding(.horizontal, 16)
							.padding(.vertical, 12)
					}
					.frame(minHeight: 100)
				}
				.simultaneousGesture(
					MagnifyGesture()
						.onChanged { value in
							magnification = value.magnification
						}
						.onEnded { value in
							let newSize = fontSize * value.magnification
							fontSize = min(max(newSize, 16), 48)
							LSDefaults.translationOutputFontSize = fontSize
							magnification = 1.0
						}
				)

			}
			.padding(.horizontal, 16)
			.padding(.bottom, 16)
			.frame(height: textAreaHeight)
		}
		.background(Color.duoElevatedSurface)
		.overlay(
			RoundedRectangle(cornerRadius: 20, style: .continuous)
				.stroke(Color.duoThemAccent.opacity(0.24), lineWidth: 1)
		)
		.clipShape(.rect(cornerRadius: 20, style: .continuous))
		.rotationEffect(.degrees(effectiveRotationAngle))
	}
}

// MARK: - DuoOutputRoleBadge

private struct DuoOutputRoleBadge: View {
	let locale: TranslationLocale
	let label: String
	let accent: Color

	var body: some View {
		Text(label.localized())
			.font(.system(size: 15, weight: .semibold))
			.foregroundStyle(accent)
			.lineLimit(2)
	}
}

private struct DuoOutputFlagButton: View {
	let locale: TranslationLocale
	let action: () -> Void

	var body: some View {
		Button(action: action) {
			if let flagImage = UIImage(named: locale.flagImageName) {
				Image(uiImage: flagImage)
					.resizable()
					.scaledToFill()
					.frame(width: 34, height: 24)
					.clipShape(.rect(cornerRadius: 4, style: .continuous))
			}
		}
		.frame(width: 48, height: 38)
		.background(Color.duoThemAccent.opacity(0.12), in: Capsule())
		.accessibilityLabel("Translated Language:".localized())
	}
}

// MARK: - FontSizeSheetView

private struct FontSizeSheetView: View {
	@Binding var fontSize: CGFloat

	var body: some View {
		VStack(spacing: 16) {
			Text("Font Size".localized())
				.font(.headline)
				.padding(.top, 16)

			// Live preview
			Text("Aa")
				.font(.system(size: fontSize))
				.foregroundColor(.appTextPrimary)
				.animation(.easeInOut(duration: 0.1), value: fontSize)
				.frame(height: 52)

			// Slider with step buttons
			HStack(spacing: 12) {
				Button(action: {
					let newSize = max(fontSize - 2, 16)
					fontSize = newSize
					LSDefaults.translationOutputFontSize = newSize
				}) {
					Image(systemName: "textformat.size.smaller")
						.font(.system(size: 18, weight: .medium))
						.foregroundColor(.appAccent)
				}

				Slider(value: $fontSize, in: 16...48, step: 1) { _ in
					LSDefaults.translationOutputFontSize = fontSize
				}

				Button(action: {
					let newSize = min(fontSize + 2, 48)
					fontSize = newSize
					LSDefaults.translationOutputFontSize = newSize
				}) {
					Image(systemName: "textformat.size.larger")
						.font(.system(size: 18, weight: .medium))
						.foregroundColor(.appAccent)
				}
			}
			.padding(.horizontal, 24)
			.padding(.bottom, 16)
		}
	}
}

#Preview {
	struct PreviewWrapper: View {
		@State private var isFullScreen = false

		var body: some View {
			TranslationOutputView(
				text: "번역된 문장이 표시됩니다",
				locale: .korean,
				availableLocales: TranslationLocale.allCases,
				placeholder: "Translated message will appear here",
				onLocaleChange: { _ in },
				isFullScreen: isFullScreen,
				onToggleFullScreen: {
					isFullScreen.toggle()
				},
				deviceOrientation: .portrait
			)
			.padding()
		}
	}

	return PreviewWrapper()
}
