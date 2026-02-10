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
	@State private var rotationAngle: Double = LSDefaults.translationOutputRotationAngle
	@State private var fontSize: CGFloat = LSDefaults.translationOutputFontSize
	@State private var magnification: CGFloat = 1.0

	// Computed property for effective font size with constraints
	private var effectiveFontSize: CGFloat {
		let size = fontSize * magnification
		return min(max(size, 16), 48) // Constrain between 16 (default) and 48 points
	}
	
	// Computed property for rotation angle based on device orientation
	private var effectiveRotationAngle: Double {
		// Disable rotation in landscape mode
		deviceOrientation.isLandscape ? 0 : rotationAngle
	}

	var body: some View {
		VStack(spacing: 0) {
			HStack {
				// Language Picker
				LanguagePickerButton(
					title: "Translated Language:".localized(),
					locale: locale,
					availableLocales: availableLocales,
					onSelect: onLocaleChange
				)
				.padding(.horizontal, 16)
				.padding(.top, 16)
				.padding(.bottom, 12)
				
				Spacer()
				
				// Rotate Button - rotates entire view 180 degrees when tapped
				Button(action: {
					let newAngle = rotationAngle + 180
					withAnimation(.easeInOut(duration: 0.3)) {
						rotationAngle = newAngle
					}
					LSDefaults.translationOutputRotationAngle = newAngle
				}) {
					if effectiveRotationAngle.truncatingRemainder(dividingBy: 360) != 0 {
						Image(systemName: "pin.fill")
							.font(.system(size: 14, weight: .medium))
							.foregroundColor(.appAccent)
							.rotationEffect(.degrees(45))
					} else {
						Image(systemName: "arrow.triangle.2.circlepath")
							.font(.system(size: 14, weight: .medium))
							.foregroundColor(.appAccent)
					}
				}
				.disabled(deviceOrientation.isLandscape) // Disable rotation button in landscape
				.opacity(deviceOrientation.isLandscape ? 0.5 : 1.0) // Visual feedback for disabled state
				.rotationEffect(.degrees(-effectiveRotationAngle))
				.padding(.horizontal, 16)
			}
			
			// Separator
			Divider()
				.padding(.horizontal, 16)
			
			// Translated Text
			ZStack(alignment: .bottomTrailing) {
				ZStack(alignment: .topLeading) {
					if text.isEmpty {
						Text(placeholder)
							.font(.system(size: effectiveFontSize))
							.foregroundColor(.appTextPlaceholder)
							.padding(.horizontal, 16)
							.padding(.vertical, 12)
					}

					ScrollView {
						Text(text)
							.font(.system(size: effectiveFontSize))
							.foregroundColor(.appTextPrimary)
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

				// Full Screen Toggle Button
				Button(action: {
					onToggleFullScreen()
				}) {
					Image(systemName: isFullScreen ? "arrow.down.right.and.arrow.up.left" : "arrow.up.left.and.arrow.down.right")
						.font(.system(size: 14, weight: .medium))
						.foregroundColor(.appAccent)
						.padding(8)
						.background(
							Circle()
								.fill(Color.appInputOutputBackground.opacity(0.8))
								.shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
						)
				}
				.rotationEffect(.degrees(-effectiveRotationAngle))
				.padding(.trailing, 12)
				.padding(.bottom, 12)
			}
			.padding(.horizontal, 16)
			.padding(.bottom, 16)
		}
		.background(Color.appInputOutputBackground)
		.cornerRadius(16)
		.rotationEffect(.degrees(effectiveRotationAngle))
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

