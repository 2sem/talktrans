//
//  LanguageSelectionView.swift
//  talktrans
//
//  Created by 영준 이 on 11/9/25.
//  Copyright © 2025 leesam. All rights reserved.
//

import SwiftUI
import UIKit

enum LanguageSelectionRole {
	case source
	case target

	var accent: Color {
		switch self {
		case .source: return .duoYouAccent
		case .target: return .duoThemAccent
		}
	}

	var accentDeep: Color {
		switch self {
		case .source: return .duoYouAccentDeep
		case .target: return .duoThemAccentDeep
		}
	}

	var sectionTitle: String {
		switch self {
		case .source: return "Your language"
		case .target: return "Their language"
		}
	}

}

struct LanguageSelectionScreen: View {
	let languages: [TranslationLocale]
	let selectedLocale: TranslationLocale
	let selectedRole: LanguageSelectionRole
	let sourceLocale: TranslationLocale?
	let targetLocale: TranslationLocale?
	let onSelect: (TranslationLocale) -> Void

	@Environment(\.dismiss) private var dismiss
	@State private var searchText = ""

	init(
		languages: [TranslationLocale],
		selectedLocale: TranslationLocale,
		selectedRole: LanguageSelectionRole = .target,
		sourceLocale: TranslationLocale? = nil,
		targetLocale: TranslationLocale? = nil,
		onSelect: @escaping (TranslationLocale) -> Void
	) {
		self.languages = languages
		self.selectedLocale = selectedLocale
		self.selectedRole = selectedRole
		self.sourceLocale = sourceLocale
		self.targetLocale = targetLocale
		self.onSelect = onSelect
	}

	private var currentSourceLocale: TranslationLocale {
		sourceLocale ?? (selectedRole == .source ? selectedLocale : .korean)
	}

	private var currentTargetLocale: TranslationLocale {
		targetLocale ?? (selectedRole == .target ? selectedLocale : .english)
	}

	private var filteredLanguages: [TranslationLocale] {
		let trimmedSearch = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
		guard !trimmedSearch.isEmpty else { return languages }

		return languages.filter { locale in
			locale.displayName.localizedCaseInsensitiveContains(trimmedSearch)
				|| locale.nativeDisplayName.localizedCaseInsensitiveContains(trimmedSearch)
				|| locale.rawValue.localizedCaseInsensitiveContains(trimmedSearch)
		}
	}

	private var searchPlaceholder: String {
		String(format: "Search %d languages", languages.count)
	}

	var body: some View {
		ZStack {
			LinearGradient(
				colors: [
					.duoBackground,
					.duoBackground,
					selectedRole.accent.opacity(0.1)
				],
				startPoint: .topLeading,
				endPoint: .bottomTrailing
			)
			.ignoresSafeArea()

			VStack(spacing: 18) {
				header
				summaryCard
				searchField
				languageList
			}
			.padding(.horizontal, 16)
			.padding(.top, 18)
			.padding(.bottom, 8)
		}
	}
}

// MARK: - Layout

private extension LanguageSelectionScreen {
	var header: some View {
		HStack(spacing: 12) {
			Button(action: { dismiss() }) {
				Image(systemName: "xmark")
					.font(.system(size: 15, weight: .bold))
					.foregroundStyle(Color.duoTextPrimary)
					.frame(width: 44, height: 44)
					.background(Color.duoSurface.opacity(0.9), in: Circle())
					.overlay(
						Circle()
							.stroke(Color.duoDivider.opacity(0.75), lineWidth: 1)
					)
			}
			.accessibilityLabel("Close".localized())

			VStack(alignment: .leading, spacing: 3) {
				Text("Languages".localized())
					.font(.system(size: 28, weight: .bold, design: .rounded))
					.foregroundStyle(Color.duoTextPrimary)

				Text(selectedRole.sectionTitle.localized())
					.font(.system(size: 13, weight: .semibold))
					.foregroundStyle(selectedRole.accent)
			}

			Spacer()
		}
	}

	var summaryCard: some View {
		HStack(spacing: 10) {
			LanguageSummaryColumn(
				title: "YOU".localized(),
				locale: currentSourceLocale,
				accent: .duoYouAccent,
				isActive: selectedRole == .source
			)

			Image(systemName: "arrow.left.arrow.right")
				.font(.system(size: 14, weight: .bold))
				.foregroundStyle(Color.duoTextMuted)
				.frame(width: 36, height: 36)
				.background(Color.duoControlSurface, in: Circle())
				.accessibilityHidden(true)

			LanguageSummaryColumn(
				title: "THEM".localized(),
				locale: currentTargetLocale,
				accent: .duoThemAccent,
				isActive: selectedRole == .target
			)
		}
		.padding(12)
		.background(Color.duoSurface.opacity(0.96), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
		.overlay(
			RoundedRectangle(cornerRadius: 24, style: .continuous)
				.stroke(Color.duoDivider.opacity(0.75), lineWidth: 1)
		)
		.shadow(color: .black.opacity(0.12), radius: 18, x: 0, y: 10)
	}

	var searchField: some View {
		HStack(spacing: 10) {
			Image(systemName: "magnifyingglass")
				.font(.system(size: 15, weight: .semibold))
				.foregroundStyle(selectedRole.accent)

			TextField(searchPlaceholder.localized(), text: $searchText)
				.font(.system(size: 16, weight: .medium))
				.foregroundStyle(Color.duoTextPrimary)
				.textInputAutocapitalization(.never)
				.autocorrectionDisabled()

			if !searchText.isEmpty {
				Button(action: { searchText = "" }) {
					Image(systemName: "xmark.circle.fill")
						.font(.system(size: 16, weight: .semibold))
						.foregroundStyle(Color.duoTextMuted)
				}
				.accessibilityLabel("Clear search".localized())
			}
		}
		.padding(.horizontal, 14)
		.frame(height: 48)
		.background(Color.duoSurface.opacity(0.94), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
		.overlay(
			RoundedRectangle(cornerRadius: 16, style: .continuous)
				.stroke(selectedRole.accent.opacity(0.2), lineWidth: 1)
		)
	}

	var languageList: some View {
		VStack(alignment: .leading, spacing: 10) {
			Text(selectedRole.sectionTitle.localized())
				.font(.system(size: 12, weight: .bold))
				.foregroundStyle(Color.duoTextMuted)
				.textCase(.uppercase)
				.padding(.horizontal, 4)

			ScrollView {
				LazyVStack(spacing: 10) {
					ForEach(filteredLanguages, id: \.self) { locale in
						LanguageRow(
							locale: locale,
							isSelected: locale == selectedLocale,
							accent: selectedRole.accent,
							accentDeep: selectedRole.accentDeep
						) {
							onSelect(locale)
							dismiss()
						}
					}
				}
				.padding(.bottom, 16)
			}
			.scrollIndicators(.hidden)
		}
	}
}

// MARK: - Components

private struct LanguageSummaryColumn: View {
	let title: String
	let locale: TranslationLocale
	let accent: Color
	let isActive: Bool

	var body: some View {
		VStack(alignment: .leading, spacing: 8) {
			Text(title)
				.font(.system(size: 11, weight: .bold))
				.foregroundStyle(accent)

			HStack(spacing: 8) {
				LanguageFlagView(locale: locale, width: 32, height: 22)

				VStack(alignment: .leading, spacing: 1) {
					Text(locale.displayName)
						.font(.system(size: 15, weight: .semibold))
						.foregroundStyle(Color.duoTextPrimary)
						.lineLimit(1)

					Text(locale.rawValue.uppercased())
						.font(.system(size: 11, weight: .bold))
						.foregroundStyle(Color.duoTextMuted)
				}
			}
		}
		.frame(maxWidth: .infinity, alignment: .leading)
		.padding(12)
		.background(accent.opacity(isActive ? 0.14 : 0.07), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
		.overlay(
			RoundedRectangle(cornerRadius: 18, style: .continuous)
				.stroke(accent.opacity(isActive ? 0.34 : 0.12), lineWidth: 1)
		)
		.accessibilityElement(children: .combine)
	}
}

private struct LanguageRow: View {
	let locale: TranslationLocale
	let isSelected: Bool
	let accent: Color
	let accentDeep: Color
	let action: () -> Void

	var body: some View {
		Button(action: action) {
			HStack(spacing: 13) {
				LanguageFlagView(locale: locale, width: 40, height: 28)

				VStack(alignment: .leading, spacing: 3) {
					Text(locale.displayName)
						.font(.system(size: 16, weight: .semibold))
						.foregroundStyle(Color.duoTextPrimary)
						.lineLimit(1)

					Text(locale.nativeDisplayName)
						.font(.system(size: 13, weight: .medium))
						.foregroundStyle(Color.duoTextSecondary)
						.lineLimit(1)
				}

				Spacer(minLength: 12)

				if isSelected {
					Image(systemName: "checkmark.circle.fill")
						.font(.system(size: 22, weight: .semibold))
						.foregroundStyle(accent)
				} else {
					Image(systemName: "circle")
						.font(.system(size: 22, weight: .medium))
						.foregroundStyle(Color.duoDivider)
				}
			}
			.padding(.horizontal, 14)
			.padding(.vertical, 12)
			.frame(minHeight: 64)
			.background(
				RoundedRectangle(cornerRadius: 18, style: .continuous)
					.fill(isSelected ? accent.opacity(0.14) : Color.duoSurface.opacity(0.92))
			)
			.overlay(alignment: .leading) {
				RoundedRectangle(cornerRadius: 18, style: .continuous)
					.fill(
						LinearGradient(
							colors: [accent, accentDeep],
							startPoint: .top,
							endPoint: .bottom
						)
					)
					.frame(width: isSelected ? 5 : 0)
			}
			.overlay(
				RoundedRectangle(cornerRadius: 18, style: .continuous)
					.stroke(isSelected ? accent.opacity(0.45) : Color.duoDivider.opacity(0.58), lineWidth: 1)
			)
		}
		.buttonStyle(.plain)
		.accessibilityLabel("\(locale.displayName), \(locale.nativeDisplayName)")
		.accessibilityValue(isSelected ? "Selected".localized() : "")
		.accessibilityHint("Select \(locale.displayName)".localized())
	}
}

private struct LanguageFlagView: View {
	let locale: TranslationLocale
	let width: CGFloat
	let height: CGFloat

	var body: some View {
		Group {
			if let flagImage = UIImage(named: locale.flagImageName) {
				Image(uiImage: flagImage)
					.resizable()
					.scaledToFill()
			} else {
				Text(locale.flagEmoji)
					.font(.system(size: height * 0.75))
			}
		}
		.frame(width: width, height: height)
		.clipShape(.rect(cornerRadius: 5, style: .continuous))
		.accessibilityHidden(true)
	}
}

#Preview {
	LanguageSelectionScreen(
		languages: TranslationLocale.allCases,
		selectedLocale: .english,
		selectedRole: .target,
		sourceLocale: .korean,
		targetLocale: .english,
		onSelect: { _ in }
	)
}
