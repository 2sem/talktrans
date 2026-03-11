//
//  AnalyticsManager.swift
//  talktrans
//
//  Created by 영준 이 on 3/11/26.
//  Copyright © 2026 leesam. All rights reserved.
//

import Foundation
import Firebase

// MARK: - AnalyticsManager

final class AnalyticsManager: ObservableObject {
}

	// MARK: - Init

	init() {}

	// MARK: - Event Names

	enum Event {
		static let watchAdPromptShown = "watch_ad_prompt_shown"
		static let watchAdTapped = "watch_ad_tapped"
		static let watchAdCompleted = "watch_ad_completed"
		static let watchAdDismissed = "watch_ad_dismissed"
	}

	// MARK: - Parameter Keys

	enum Param {
		static let exitStage = "exit_stage"
	}

	// MARK: - Exit Stage Values

	enum ExitStage {
		static let confirmationSheet = "confirmation_sheet"
		static let adPlaying = "ad_playing"
	}

	// MARK: - Log Methods

	/// Watch Ad 유도 버튼이 화면에 표시됐을 때 호출
	func logWatchAdPromptShown() {
		Analytics.logEvent(Event.watchAdPromptShown, parameters: nil)
	}

	/// 사용자가 Watch Ad 버튼을 탭했을 때 호출
	func logWatchAdTapped() {
		Analytics.logEvent(Event.watchAdTapped, parameters: nil)
	}

	/// 광고를 끝까지 시청하고 1시간 무광고가 활성화됐을 때 호출
	func logWatchAdCompleted() {
		Analytics.logEvent(Event.watchAdCompleted, parameters: nil)
	}

	/// 사용자가 광고 시청 없이 이탈했을 때 호출
	func logWatchAdDismissed(exitStage: String) {
		Analytics.logEvent(Event.watchAdDismissed, parameters: [
			Param.exitStage: exitStage
		])
	}
}
