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
	let locale: TranslationLocale
	let availableLocales: [TranslationLocale]
	let placeholder: String
	let onLocaleChange: (TranslationLocale) -> Void
	let maxLength: Int
	
	var body: some View {
		VStack(spacing: 0) {
			// Language Picker
			LanguagePickerButton(
				locale: locale,
				availableLocales: availableLocales,
				onSelect: onLocaleChange
			)
			.padding(.horizontal, 16)
			.padding(.top, 16)
			.padding(.bottom, 12)
			
			// Text Input
			ZStack(alignment: .topLeading) {
				if text.isEmpty {
					Text(placeholder)
						.font(.system(size: 16))
						.foregroundColor(.secondary)
						.padding(.horizontal, 16)
						.padding(.vertical, 12)
				}
				
				TextEditor(text: $text)
					.font(.system(size: 16))
					.frame(minHeight: 100)
					.padding(.horizontal, 12)
					.padding(.vertical, 8)
					.onChange(of: text) { oldValue, newValue in
						if newValue.count > maxLength {
							text = String(newValue.prefix(maxLength))
						}
					}
			}
			.padding(.horizontal, 16)
			.padding(.bottom, 16)
		}
		.background(Color.purple.opacity(0.05))
		.cornerRadius(16)
	}
}

#Preview {
	TranslationInputView(
		text: .constant(""),
		locale: .english,
		availableLocales: TranslationLocale.allCases,
		placeholder: "Please input your message to be translated as Korean",
		onLocaleChange: { _ in },
		maxLength: 100
	)
	.padding()
}

