//
//  LanguageSelectionView.swift
//  talktrans
//
//  Created by 영준 이 on 11/9/25.
//  Copyright © 2025 leesam. All rights reserved.
//

import SwiftUI

struct LanguageSelectionScreen: View {
	let languages: [TranslationLocale]
	let selectedLocale: TranslationLocale
	let onSelect: (TranslationLocale) -> Void
	@Environment(\.dismiss) var dismiss
	
	var body: some View {
		VStack(spacing: 0) {
			// Header
			HStack {
				Button(action: { dismiss() }) {
					Image(systemName: "xmark")
						.font(.system(size: 16, weight: .medium))
						.foregroundColor(.primary)
				}
				.padding(.leading, 16)
				
				Spacer()
				
				Text("Select Language")
					.font(.system(size: 17, weight: .semibold))
					.foregroundColor(.primary)
				
				Spacer()
				
				// Balance for close button
				Color.clear
					.frame(width: 44, height: 44)
					.padding(.trailing, 16)
			}
			.padding(.vertical, 16)
			.frame(height: 56)
			
			Divider()
			
			// Language List
			ScrollView {
				VStack(spacing: 0) {
					ForEach(languages, id: \.self) { locale in
						Button(action: {
							onSelect(locale)
							dismiss()
						}) {
							HStack {
								// Flag
								Image(locale.flagImageName)
									.resizable()
									.scaledToFit()
									.frame(width: 32, height: 32)
									.clipShape(Circle())
								
								// Language Name
								Text(locale.displayName)
									.font(.system(size: 17))
									.foregroundColor(.primary)
								
								Spacer()
								
								// Checkmark
								if locale == selectedLocale {
									Image(systemName: "checkmark")
										.font(.system(size: 16, weight: .semibold))
										.foregroundColor(.purple)
								}
							}
							.padding(.horizontal, 16)
							.padding(.vertical, 12)
							.background(
								locale == selectedLocale ? Color.purple.opacity(0.1) : Color.clear
							)
						}
						.buttonStyle(PlainButtonStyle())
						
						if locale != languages.last {
							Divider()
								.padding(.leading, 64)
						}
					}
				}
			}
		}
		.background(Color(.systemBackground))
		.cornerRadius(16, corners: [.topLeft, .topRight])
	}
}

#Preview {
	LanguageSelectionScreen(
		languages: TranslationLocale.allCases,
		selectedLocale: .english,
		onSelect: { _ in }
	)
}

