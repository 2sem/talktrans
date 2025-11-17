//
//  LanguagePickerButton.swift
//  talktrans
//
//  Created by 영준 이 on 11/9/25.
//  Copyright © 2025 leesam. All rights reserved.
//

import SwiftUI

struct LanguagePickerButton: View {
    let title: String
	let locale: TranslationLocale
	let availableLocales: [TranslationLocale]
	let onSelect: (TranslationLocale) -> Void
	@State private var showLanguagePicker = false
	
	var body: some View {
		Button(action: {
			showLanguagePicker = true
		}) {
			HStack(spacing: 8) {
                Text(title)
                
                Spacer()
				
                if let flagImage = UIImage.init(named: locale.flagImageName) {
                    Image.init(uiImage: flagImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .clipShape(Circle())
                }
				
				// Chevron
				Image(systemName: "chevron.down")
					.font(.system(size: 12, weight: .medium))
					.foregroundColor(.secondary)
			}
		}
		.sheet(isPresented: $showLanguagePicker) {
			LanguageSelectionScreen(
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
        title: "Language",
		locale: .english,
		availableLocales: TranslationLocale.allCases,
		onSelect: { _ in }
	)
	.padding()
}

