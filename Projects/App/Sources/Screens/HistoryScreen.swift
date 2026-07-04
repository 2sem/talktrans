//
//  HistoryScreen.swift
//  talktrans
//
//  Created by 영준 이 on 3/25/26.
//  Copyright © 2026 leesam. All rights reserved.
//

import SwiftUI
import SwiftData

// MARK: - HistoryScreen

struct HistoryScreen: View {
	/// Called when user taps Re-translate on a detail sheet.
	let onRetranslate: (String, String, String, String) -> Void

	@Environment(\.dismiss) private var dismiss
	@Environment(\.modelContext) private var modelContext

	@State private var filterMode: HistoryFilter = .all

	var body: some View {
		NavigationStack {
			ZStack {
				LinearGradient(
					colors: [
						.duoBackground,
						.duoBackground,
						.duoThemAccent.opacity(0.07),
						.duoYouAccent.opacity(0.05)
					],
					startPoint: .topLeading,
					endPoint: .bottomTrailing
				)
				.ignoresSafeArea()

				VStack(spacing: 16) {
					header

					Picker("Filter".localized(), selection: $filterMode) {
						Text("All".localized()).tag(HistoryFilter.all)
						Text("Favorited".localized()).tag(HistoryFilter.favorited)
					}
					.pickerStyle(.segmented)
					.padding(4)
					.background(Color.duoControlSurface.opacity(0.9))
					.clipShape(.rect(cornerRadius: 14, style: .continuous))
					.padding(.horizontal, 16)

					// Swap list based on filter to keep @Query predicates static
					if filterMode == .favorited {
						HistoryListView(
							predicate: #Predicate<TranslationEntry> { $0.isFavorited == true },
							emptyTitle: "No favorites yet".localized(),
							emptySubtitle: "Star important translations to find them faster.".localized(),
							onFavoriteToggle: toggleFavorite,
							onSelect: applyHistoryEntry
						)
					} else {
						HistoryListView(
							predicate: nil,
							emptyTitle: "No translations yet".localized(),
							emptySubtitle: "Your recent conversations will appear here.".localized(),
							onFavoriteToggle: toggleFavorite,
							onSelect: applyHistoryEntry
						)
					}
				}
				.padding(.top, 18)
			}
			.toolbarVisibility(.hidden, for: .navigationBar)
		}
	}

	private var header: some View {
		HStack(alignment: .center, spacing: 12) {
			Text("History".localized())
				.font(.system(size: 30, weight: .black, design: .rounded))
				.foregroundStyle(Color.duoTextPrimary)

			Spacer(minLength: 0)

			Button("Done".localized()) {
				dismiss()
			}
			.font(.system(size: 16, weight: .bold))
			.foregroundStyle(Color.duoThemAccentDeep)
			.padding(.horizontal, 18)
			.frame(height: 42)
			.background(Color.duoSurface.opacity(0.92))
			.clipShape(.capsule)
		}
		.padding(.horizontal, 16)
	}

	private func toggleFavorite(_ entry: TranslationEntry) {
		entry.isFavorited.toggle()
	}

	private func applyHistoryEntry(_ entry: TranslationEntry) {
		dismiss()
		onRetranslate(entry.sourceText, entry.translatedText, entry.sourceLang, entry.targetLang)
	}
}

// MARK: - Filter Enum

private enum HistoryFilter: Hashable {
	case all
	case favorited
}

// MARK: - HistoryListView (owns @Query)

private struct HistoryListView: View {
	@Query private var entries: [TranslationEntry]

	private let emptyTitle: String
	private let emptySubtitle: String
	private let onFavoriteToggle: (TranslationEntry) -> Void
	private let onSelect: (TranslationEntry) -> Void

	@Environment(\.modelContext) private var modelContext

	init(
		predicate: Predicate<TranslationEntry>?,
		emptyTitle: String,
		emptySubtitle: String,
		onFavoriteToggle: @escaping (TranslationEntry) -> Void,
		onSelect: @escaping (TranslationEntry) -> Void
	) {
		let descriptor = FetchDescriptor<TranslationEntry>(
			predicate: predicate,
			sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
		)
		_entries = Query(descriptor)
		self.emptyTitle = emptyTitle
		self.emptySubtitle = emptySubtitle
		self.onFavoriteToggle = onFavoriteToggle
		self.onSelect = onSelect
	}

	var body: some View {
		if entries.isEmpty {
			emptyState
		} else {
			List {
				ForEach(daySections, id: \.date) { section in
					Section {
						ForEach(section.entries) { entry in
							Button {
								onSelect(entry)
							} label: {
								HistoryRow(entry: entry) {
									onFavoriteToggle(entry)
								}
							}
							.buttonStyle(.plain)
							.swipeActions(edge: .leading, allowsFullSwipe: true) {
								Button {
									onFavoriteToggle(entry)
								} label: {
									Label(
										entry.isFavorited ? "Remove Favorite".localized() : "Add Favorite".localized(),
										systemImage: entry.isFavorited ? "star.slash" : "star.fill"
									)
								}
								.tint(Color.duoYouAccent)
							}
							.listRowInsets(.init(top: 6, leading: 16, bottom: 6, trailing: 16))
							.listRowSeparator(.hidden)
							.listRowBackground(Color.clear)
						}
						.onDelete { indexSet in
							delete(section: section, at: indexSet)
						}
					} header: {
						Text(section.date, style: .date)
							.font(.system(size: 13, weight: .bold))
							.foregroundStyle(Color.duoTextSecondary)
							.textCase(nil)
					}
				}
			}
			.listStyle(.plain)
			.scrollContentBackground(.hidden)
			.background(Color.clear)
		}
	}

	private var emptyState: some View {
		VStack(spacing: 16) {
			Image(systemName: "clock.arrow.circlepath")
				.font(.system(size: 34, weight: .semibold))
				.foregroundStyle(Color.duoThemAccentDeep)
				.frame(width: 76, height: 76)
				.background(Color.duoThemAccent.opacity(0.13))
				.clipShape(.circle)

			VStack(spacing: 8) {
				Text(emptyTitle)
					.font(.system(size: 22, weight: .bold))
					.foregroundStyle(Color.duoTextPrimary)

				Text(emptySubtitle)
					.font(.system(size: 15, weight: .medium))
					.foregroundStyle(Color.duoTextSecondary)
					.multilineTextAlignment(.center)
			}
		}
		.padding(.horizontal, 32)
		.frame(maxWidth: .infinity, maxHeight: .infinity)
	}

	// MARK: Grouping

	private struct DaySection {
		let date: Date
		var entries: [TranslationEntry]
	}

	private var daySections: [DaySection] {
		var buckets: [Date: [TranslationEntry]] = [:]
		for entry in entries {
			let day = Calendar.current.startOfDay(for: entry.timestamp)
			buckets[day, default: []].append(entry)
		}
		return buckets
			.map { DaySection(date: $0.key, entries: $0.value) }
			.sorted { $0.date > $1.date }
	}

	private func delete(section: DaySection, at offsets: IndexSet) {
		for index in offsets {
			modelContext.delete(section.entries[index])
		}
	}
}
