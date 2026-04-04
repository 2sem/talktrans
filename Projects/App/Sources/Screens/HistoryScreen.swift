//
//  HistoryScreen.swift
//  talktrans
//
//  Created by 영준 이 on 3/25/26.
//  Copyright © 2026 leesam. All rights reserved.
//

import SwiftUI
import SwiftData
import UIKit

// MARK: - HistoryScreen

struct HistoryScreen: View {
	/// Called when user taps Re-translate on a detail sheet.
	let onRetranslate: (String, String, String, String) -> Void

	static let feedbackIssueURLString = "https://github.com/2sem/talktrans/issues/new/choose"

	@Environment(\.dismiss) private var dismiss
	@Environment(\.openURL) private var openURL
	@Environment(\.modelContext) private var modelContext

	@State private var filterMode: HistoryFilter = .all
	@State private var selectedEntry: TranslationEntry?
	@State private var showFeedbackFallbackAlert = false

	var body: some View {
		NavigationStack {
			VStack(spacing: 0) {
				Picker("Filter".localized(), selection: $filterMode) {
					Text("All".localized()).tag(HistoryFilter.all)
					Text("Favorited".localized()).tag(HistoryFilter.favorited)
				}
				.pickerStyle(.segmented)
				.padding(.horizontal, 16)
				.padding(.vertical, 10)

				// Swap list based on filter to keep @Query predicates static
				if filterMode == .favorited {
					HistoryListView(
						predicate: #Predicate<TranslationEntry> { $0.isFavorited == true },
						emptyTitle: "No favorites yet".localized(),
						onFavoriteToggle: toggleFavorite,
						onSelect: { selectedEntry = $0 }
					)
				} else {
					HistoryListView(
						predicate: nil,
						emptyTitle: "No translations yet".localized(),
						onFavoriteToggle: toggleFavorite,
						onSelect: { selectedEntry = $0 }
					)
				}
			}
			.navigationTitle("History".localized())
			.navigationBarTitleDisplayMode(.large)
			.toolbar {
				ToolbarItem(placement: .topBarLeading) {
					Button(action: openFeedbackIssue) {
						Image(systemName: "bubble.left.and.text.bubble.right")
					}
					.accessibilityLabel("Send Feedback".localized())
				}
				ToolbarItem(placement: .topBarTrailing) {
					Button("Done".localized()) {
						dismiss()
					}
				}
			}
			.alert("Unable to Open Link".localized(), isPresented: $showFeedbackFallbackAlert) {
				Button("Copy Link".localized()) {
					UIPasteboard.general.string = Self.feedbackIssueURLString
				}
				Button("OK".localized(), role: .cancel) { }
			} message: {
				Text("Please copy and open the feedback link manually.".localized())
			}
			.sheet(item: $selectedEntry) { entry in
				HistoryDetailSheet(entry: entry) { sourceText, translatedText, sourceLang, targetLang in
					dismiss()
					onRetranslate(sourceText, translatedText, sourceLang, targetLang)
				}
				.presentationDetents([.large])
				.presentationDragIndicator(.visible)
			}
		}
	}

	private func openFeedbackIssue() {
		guard let issueURL = URL(string: Self.feedbackIssueURLString) else {
			showFeedbackFallbackAlert = true
			return
		}

		openURL(issueURL) { accepted in
			if !accepted {
				showFeedbackFallbackAlert = true
			}
		}
	}

	private func toggleFavorite(_ entry: TranslationEntry) {
		entry.isFavorited.toggle()
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
	private let onFavoriteToggle: (TranslationEntry) -> Void
	private let onSelect: (TranslationEntry) -> Void

	@Environment(\.modelContext) private var modelContext

	init(
		predicate: Predicate<TranslationEntry>?,
		emptyTitle: String,
		onFavoriteToggle: @escaping (TranslationEntry) -> Void,
		onSelect: @escaping (TranslationEntry) -> Void
	) {
		let descriptor = FetchDescriptor<TranslationEntry>(
			predicate: predicate,
			sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
		)
		_entries = Query(descriptor)
		self.emptyTitle = emptyTitle
		self.onFavoriteToggle = onFavoriteToggle
		self.onSelect = onSelect
	}

	var body: some View {
		if entries.isEmpty {
			ContentUnavailableView(
				emptyTitle,
				systemImage: "clock.arrow.circlepath"
			)
			.frame(maxWidth: .infinity, maxHeight: .infinity)
		} else {
			List {
				ForEach(daySections, id: \.date) { section in
					Section(header: Text(section.date, style: .date)) {
						ForEach(section.entries) { entry in
							Button {
								onSelect(entry)
							} label: {
								HistoryRow(entry: entry) {
									onFavoriteToggle(entry)
								}
							}
							.buttonStyle(.plain)
						}
						.onDelete { indexSet in
							delete(section: section, at: indexSet)
						}
					}
				}
			}
			.listStyle(.insetGrouped)
		}
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
