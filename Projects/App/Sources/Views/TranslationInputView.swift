//
//  TranslationInputView.swift
//  talktrans
//
//  Created by 영준 이 on 11/9/25.
//  Copyright © 2025 leesam. All rights reserved.
//

import SwiftUI

struct TranslationInputView: View {
	@Binding var text: String
	var isFocused: FocusState<Bool>.Binding
	let locale: TranslationLocale
	let availableLocales: [TranslationLocale]
	let placeholder: String
	let onLocaleChange: (TranslationLocale) -> Void
	// Called when user taps the swap (clockwise) button. Optional to preserve
	// backward compatibility with existing initializers.
	let onSwap: () -> Void
	let onHistoryTapped: () -> Void
	let maxLength: Int
	@State private var showLanguagePicker = false

	private var counterText: String {
		"\(text.count) / \(maxLength)"
	}

	private var inputAreaHeight: CGFloat {
		180
	}
	
	var body: some View {
		VStack(spacing: 0) {
			HStack(spacing: 10) {
				DuoInputFlagButton(locale: locale) {
					showLanguagePicker = true
				}

				DuoRoleBadge(
					locale: locale,
					label: "\(locale.rawValue.uppercased()) · you",
					accent: .duoYouAccent
				)

				Spacer()

				Text(counterText)
					.font(.system(size: 12))
					.foregroundStyle(Color.duoTextMuted)
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
			
			ZStack(alignment: .topLeading) {
				TextEditor(text: $text)
					.scrollContentBackground(.hidden)
					.font(.system(size: 16))
					.foregroundStyle(Color.duoTextSecondary)
					.frame(height: inputAreaHeight)
					.padding(.horizontal, 12)
					.padding(.vertical, 8)
					.focused(isFocused)
					.onChange(of: text) { oldValue, newValue in
						if newValue.count > maxLength {
							text = String(newValue.prefix(maxLength))
						}
					}
                
				if text.isEmpty {
					Text(placeholder)
						.font(.system(size: 16))
						.foregroundStyle(Color.duoTextMuted)
						.padding(.horizontal, 16)
						.padding(.vertical, 12)
				}
			}
			.frame(height: inputAreaHeight)

		}
		.background(Color.duoSurface)
		.overlay(
			RoundedRectangle(cornerRadius: 20, style: .continuous)
				.stroke(Color.duoYouAccent.opacity(0.22), lineWidth: 1)
		)
		.clipShape(.rect(cornerRadius: 20, style: .continuous))
	}
}

// MARK: - DuoRoleBadge

private struct DuoRoleBadge: View {
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

private struct DuoInputFlagButton: View {
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
		.background(Color.duoYouAccent.opacity(0.12), in: Capsule())
		.accessibilityLabel("Native Language:".localized())
	}
}

#Preview {
	@Previewable @FocusState var isFocused: Bool
	
	TranslationInputView(
		text: .constant(""),
		isFocused: $isFocused,
		locale: .english,
		availableLocales: TranslationLocale.allCases,
		placeholder: "Please input your message to be translated as Korean",
        onLocaleChange: { _ in },
        onSwap: {},
        onHistoryTapped: {},
		maxLength: 500
	)
    .frame(height: 100)
    .padding()
}
