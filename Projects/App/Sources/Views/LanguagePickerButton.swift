//
//  LanguagePickerButton.swift
//  talktrans
//
//  Created by 영준 이 on 11/9/25.
//  Copyright © 2025 leesam. All rights reserved.
//

import SwiftUI

struct LanguagePickerButton: View {
	let locale: TranslationLocale
	let availableLocales: [TranslationLocale]
	let onSelect: (TranslationLocale) -> Void
	@State private var showLanguagePicker = false
	
	var body: some View {
		Button(action: {
			showLanguagePicker = true
		}) {
			HStack(spacing: 8) {
				// Language Label
				Text(locale.displayName)
					.font(.system(size: 14, weight: .medium))
					.foregroundColor(.purple)
					.padding(.horizontal, 12)
					.padding(.vertical, 6)
					.background(Color.purple.opacity(0.1))
					.cornerRadius(12)
				
				// Flag
				Image(locale.flagImageName)
					.resizable()
					.scaledToFit()
					.frame(width: 24, height: 24)
					.clipShape(Circle())
				
				// Chevron
				Image(systemName: "chevron.down")
					.font(.system(size: 12, weight: .medium))
					.foregroundColor(.secondary)
				
				Spacer()
				
				// Refresh Button
				Button(action: {
					// Refresh action (can be implemented later)
				}) {
					Image(systemName: "arrow.clockwise")
						.font(.system(size: 14, weight: .medium))
						.foregroundColor(.secondary)
				}
			}
		}
		.sheet(isPresented: $showLanguagePicker) {
			LanguageSelectionView(
				languages: availableLocales,
				selectedLocale: locale,
				onSelect: onSelect
			)
			.presentationDetents([.medium, .large])
		}
	}
}

#Preview {
	LanguagePickerButton(
		locale: .english,
		availableLocales: TranslationLocale.allCases,
		onSelect: { _ in }
	)
	.padding()
}

