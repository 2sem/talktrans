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
	let maxLength: Int
	
	var body: some View {
		VStack(spacing: 0) {
            HStack{
                // Language Picker
                LanguagePickerButton(
                    title: "Native Language:".localized(),
                    locale: locale,
                    availableLocales: availableLocales,
                    onSelect: onLocaleChange
                )
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 12)
                
				// Swap Button - calls onSwap closure when tapped
				Button(action: {
					onSwap()
				}) {
					Image(systemName: "arrow.clockwise")
						.font(.system(size: 14, weight: .medium))
                        .foregroundColor(.appAccent)
                }.padding(.horizontal, 16)
            }
			
			// Separator
			Divider()
				.padding(.horizontal, 16)
			
			// Text Input
			ZStack(alignment: .topLeading) {
				TextEditor(text: $text)
					.scrollContentBackground(.hidden)
					.font(.system(size: 16))
					.foregroundColor(.appTextPrimary)
					.frame(minHeight: 100)
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
                        .foregroundColor(.appTextPlaceholder)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                }
			}
			.padding(.horizontal, 16)
			.padding(.bottom, 16)
		}
		.background(Color.appInputOutputBackground)
		.cornerRadius(16)
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
        onSwap: {  },
		maxLength: 100
	)
    .frame(height: 100)
    .padding()
}

