//
//  HistoryDetailSheet.swift
//  talktrans
//
//  Created by 영준 이 on 3/25/26.
//  Copyright © 2026 leesam. All rights reserved.
//

import SwiftUI
import SwiftData

struct HistoryDetailSheet: View {
	let entry: TranslationEntry
	/// Called when the user taps Re-translate.  Arguments: (sourceText, translatedText, sourceLang, targetLang)
	let onRetranslate: (String, String, String, String) -> Void

	@Environment(\.dismiss) private var dismiss
	@State private var isRotated: Bool = false

	private var rotationAngle: Double {
		isRotated ? 180 : 0
	}

	var body: some View {
		NavigationStack {
			ScrollView {
				VStack(alignment: .leading, spacing: 24) {
					// Source block
					VStack(alignment: .leading, spacing: 8) {
						Label {
							if let locale = TranslationLocale(rawValue: entry.sourceLang) {
								Text(locale.displayName.localized())
									.font(.caption)
									.foregroundColor(.appTextPlaceholder)
							}
						} icon: {
							if let flag = TranslationLocale(rawValue: entry.sourceLang)?.flagImageName {
								Image(flag)
									.resizable()
									.scaledToFit()
									.frame(width: 20, height: 14)
									.cornerRadius(2)
							}
						}

						Text(entry.sourceText)
							.font(.body)
							.foregroundColor(.appTextPrimary)
							.frame(maxWidth: .infinity, alignment: .leading)
					}
					.padding(16)
					.background(Color.appInputOutputBackground)
					.cornerRadius(12)

					// Translated block
					VStack(alignment: .leading, spacing: 8) {
						HStack {
							Label {
								if let locale = TranslationLocale(rawValue: entry.targetLang) {
									Text(locale.displayName.localized())
										.font(.caption)
										.foregroundColor(.appTextPlaceholder)
								}
							} icon: {
								if let flag = TranslationLocale(rawValue: entry.targetLang)?.flagImageName {
									Image(flag)
										.resizable()
										.scaledToFit()
										.frame(width: 20, height: 14)
										.cornerRadius(2)
								}
							}

							Spacer()

							// 180° rotation toggle for face-to-face reading
							Button(action: {
								withAnimation(.easeInOut(duration: 0.3)) {
									isRotated.toggle()
								}
							}) {
								Image(systemName: isRotated ? "pin.fill" : "arrow.triangle.2.circlepath")
									.font(.system(size: 14, weight: .medium))
									.foregroundColor(.appAccent)
									.rotationEffect(.degrees(isRotated ? 45 : 0))
							}
							.buttonStyle(.plain)
						}

						Text(entry.translatedText)
							.font(.title3)
							.foregroundColor(.appTextPrimary)
							.frame(maxWidth: .infinity, alignment: .leading)
							.rotationEffect(.degrees(rotationAngle))
							.animation(.easeInOut(duration: 0.3), value: isRotated)
					}
					.padding(16)
					.background(Color.appInputOutputBackground)
					.cornerRadius(12)

					// Action buttons
					HStack(spacing: 12) {
						// Re-translate
						Button(action: {
							dismiss()
							onRetranslate(entry.sourceText, entry.translatedText, entry.sourceLang, entry.targetLang)
						}) {
							Label("Re-translate".localized(), systemImage: "arrow.clockwise")
								.font(.system(size: 15, weight: .semibold))
								.frame(maxWidth: .infinity)
								.frame(height: 48)
								.background(
									LinearGradient(
										colors: [.appAccentGradientStart, .appAccentGradientEnd],
										startPoint: .leading,
										endPoint: .trailing
									)
								)
								.foregroundColor(.white)
								.cornerRadius(12)
						}
						.buttonStyle(.plain)

						// Share translated text
						ShareLink(item: entry.translatedText) {
							Image(systemName: "square.and.arrow.up")
								.font(.system(size: 16, weight: .medium))
								.frame(width: 48, height: 48)
								.background(Color.appSecondaryButton)
								.foregroundColor(.appTextPrimary)
								.cornerRadius(12)
						}
						.buttonStyle(.plain)
					}
				}
				.padding(16)
			}
			.navigationTitle("Detail".localized())
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .topBarTrailing) {
					Button("Done".localized()) {
						dismiss()
					}
				}
			}
		}
	}
}
