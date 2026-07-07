//
//  WatchAdButton.swift
//  talktrans
//
//  Created by 영준 이 on 3/10/26.
//  Copyright © 2026 leesam. All rights reserved.
//

import SwiftUI

struct WatchAdButton: View {
	@EnvironmentObject private var adManager: SwiftUIAdManager
	@EnvironmentObject private var analyticsManager: AnalyticsManager
	var onAdFreeActivated: (() -> Void)?
	var size: CGFloat = 52
	var cornerRadius: CGFloat = 16
	var iconSize: CGFloat = 18
	var backgroundColor: Color = .duoYouAccent
	var backgroundOpacity: Double = 0.14
	var borderOpacity: Double = 0.24

	@State private var showConfirmation = false

	var body: some View {
		if !adManager.isAdFree {
			Button(action: {
				analyticsManager.logWatchAdTapped()
				showConfirmation = true
			}) {
				Image(systemName: "gift")
					.font(.system(size: iconSize, weight: .semibold))
					.frame(width: size, height: size)
					.background(backgroundColor.opacity(backgroundOpacity))
					.foregroundStyle(Color.duoYouAccentDeep)
					.clipShape(.rect(cornerRadius: cornerRadius, style: .continuous))
					.overlay(
						RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
							.stroke(Color.duoYouAccent.opacity(borderOpacity), lineWidth: 1)
					)
			}
			.buttonStyle(.plain)
			.accessibilityLabel("Remove ads for 1 hour")
			.transition(.opacity.combined(with: .scale(scale: 0.8)))
			.onAppear {
				analyticsManager.logWatchAdPromptShown()
			}
			.confirmationDialog(
				"Remove ads for 1 hour?",
				isPresented: $showConfirmation,
				titleVisibility: .visible
			) {
				Button("Watch Ad") {
					adManager.showRewarded { rewarded in
						if rewarded {
							LSDefaults.activateAdFree()
							adManager.refreshAdFreeStatus()
							onAdFreeActivated?()
							analyticsManager.logWatchAdCompleted()
						} else {
							analyticsManager.logWatchAdDismissed(exitStage: AnalyticsManager.ExitStage.adPlaying)
						}
					}
				}
				Button(role: .cancel) {
					analyticsManager.logWatchAdDismissed(exitStage: AnalyticsManager.ExitStage.confirmationSheet)
				} label: { Text("Cancel") }
			} message: {
				Text("Watch a short ad to enjoy 1 hour ad-free.")
			}
		}
	}
}
