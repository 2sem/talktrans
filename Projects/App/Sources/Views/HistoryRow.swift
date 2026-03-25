//
//  HistoryRow.swift
//  talktrans
//
//  Created by 영준 이 on 3/25/26.
//  Copyright © 2026 leesam. All rights reserved.
//

import SwiftUI
import SwiftData

struct HistoryRow: View {
	let entry: TranslationEntry
	let onFavoriteToggle: () -> Void

	private var sourceFlagName: String? {
		TranslationLocale(rawValue: entry.sourceLang)?.flagImageName
	}

	private var targetFlagName: String? {
		TranslationLocale(rawValue: entry.targetLang)?.flagImageName
	}

	var body: some View {
		HStack(alignment: .top, spacing: 12) {
			// MARK: Text stack
			VStack(alignment: .leading, spacing: 4) {
				Text(entry.sourceText)
					.font(.caption)
					.foregroundColor(.appTextPlaceholder)
					.lineLimit(2)

				Text(entry.translatedText)
					.font(.body)
					.foregroundColor(.appTextPrimary)
					.lineLimit(2)
			}
			.frame(maxWidth: .infinity, alignment: .leading)

			// MARK: Right controls
			VStack(alignment: .trailing, spacing: 8) {
				// Flag pair
				HStack(spacing: 4) {
					if let src = sourceFlagName {
						Image(src)
							.resizable()
							.scaledToFit()
							.frame(width: 20, height: 14)
							.cornerRadius(2)
					}
					Image(systemName: "arrow.right")
						.font(.system(size: 9, weight: .medium))
						.foregroundColor(.appTextPlaceholder)
					if let tgt = targetFlagName {
						Image(tgt)
							.resizable()
							.scaledToFit()
							.frame(width: 20, height: 14)
							.cornerRadius(2)
					}
				}

				// Relative timestamp
				Text(entry.timestamp, style: .relative)
					.font(.caption2)
					.foregroundColor(.appTextPlaceholder)
					.multilineTextAlignment(.trailing)

				// Action row
				HStack(spacing: 12) {
					// Favorite toggle
					Button(action: onFavoriteToggle) {
						Image(systemName: entry.isFavorited ? "star.fill" : "star")
							.font(.system(size: 14, weight: .medium))
							.foregroundColor(entry.isFavorited ? .yellow : .appTextPlaceholder)
					}
					.buttonStyle(.plain)

					// Share
					ShareLink(item: entry.translatedText) {
						Image(systemName: "square.and.arrow.up")
							.font(.system(size: 14, weight: .medium))
							.foregroundColor(.appTextPlaceholder)
					}
					.buttonStyle(.plain)
				}
			}
		}
		.padding(.vertical, 4)
	}
}
