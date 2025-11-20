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
	
	var body: some View {
		VStack(spacing: 0) {
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
			
			// Separator
			Divider()
				.padding(.horizontal, 16)
			
			// Translated Text
			ZStack(alignment: .topLeading) {
				if text.isEmpty {
					Text(placeholder)
						.font(.system(size: 16))
						.foregroundColor(.appTextPlaceholder)
						.padding(.horizontal, 16)
						.padding(.vertical, 12)
				}
				
				ScrollView {
					Text(text)
						.font(.system(size: 16))
						.foregroundColor(.appTextPrimary)
						.frame(maxWidth: .infinity, alignment: .leading)
						.padding(.horizontal, 16)
						.padding(.vertical, 12)
				}
				.frame(minHeight: 100)
			}
			.padding(.horizontal, 16)
			.padding(.bottom, 16)
		}
		.background(Color.appInputOutputBackground)
		.cornerRadius(16)
	}
}

#Preview {
	TranslationOutputView(
		text: "번역된 문장이 표시됩니다",
		locale: .korean,
		availableLocales: TranslationLocale.allCases,
		placeholder: "Translated message will appear here",
		onLocaleChange: { _ in }
	)
	.padding()
}

