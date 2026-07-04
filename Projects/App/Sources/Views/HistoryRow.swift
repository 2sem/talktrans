//
//  HistoryRow.swift
//  talktrans
//
//  Created by 영준 이 on 3/25/26.
//  Copyright © 2026 leesam. All rights reserved.
//

import SwiftUI

struct HistoryRow: View {
	let entry: TranslationEntry
	let onFavoriteToggle: () -> Void

	private var sourceLocale: TranslationLocale? {
		TranslationLocale(rawValue: entry.sourceLang)
	}

	private var targetLocale: TranslationLocale? {
		TranslationLocale(rawValue: entry.targetLang)
	}

	private var languageDirection: String {
		let source = sourceLocale?.flagEmoji ?? entry.sourceLang.uppercased()
		let target = targetLocale?.flagEmoji ?? entry.targetLang.uppercased()
		return "\(source) → \(target)"
	}

	var body: some View {
		ZStack(alignment: .leading) {
			RoundedRectangle(cornerRadius: 22, style: .continuous)
				.fill(Color.duoThemAccent)

			RoundedRectangle(cornerRadius: 22, style: .continuous)
				.fill(Color.duoSurface)
				.offset(x: 5)
				.overlay(
					RoundedRectangle(cornerRadius: 22, style: .continuous)
						.stroke(Color.duoDivider.opacity(0.25), lineWidth: 1)
						.offset(x: 5)
				)

			VStack(alignment: .leading, spacing: 8) {
				HStack(alignment: .center, spacing: 8) {
					Text(languageDirection)
						.font(.system(size: 13, weight: .bold))
						.foregroundStyle(Color.duoTextSecondary)

					Spacer(minLength: 0)

					Text(entry.timestamp, style: .time)
						.font(.system(size: 13, weight: .semibold))
						.foregroundStyle(Color.duoTextMuted)
				}

				Text(entry.translatedText)
					.font(.system(size: 18, weight: .bold))
					.foregroundStyle(Color.duoTextPrimary)
					.lineLimit(2)
					.frame(maxWidth: .infinity, alignment: .leading)

				HStack(alignment: .bottom, spacing: 8) {
					Text(entry.sourceText)
						.font(.system(size: 16, weight: .medium))
						.foregroundStyle(Color.duoTextSecondary)
						.lineLimit(2)

					Spacer(minLength: 0)
				}
			}
			.padding(.leading, 30)
			.padding(.trailing, 20)
			.padding(.vertical, 15)
		}
		.clipShape(.rect(cornerRadius: 22, style: .continuous))
		.shadow(color: .black.opacity(0.06), radius: 14, y: 8)
		.contentShape(.rect(cornerRadius: 22, style: .continuous))
	}

}
