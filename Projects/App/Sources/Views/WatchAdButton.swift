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
	@Binding var isAdFree: Bool
	var onAdFreeActivated: (() -> Void)?

	@State private var showConfirmation = false

	var body: some View {
		if !isAdFree {
			Button(action: {
				showConfirmation = true
			}) {
				Image(systemName: "gift")
					.font(.system(size: 14, weight: .medium))
					.frame(width: 50, height: 50)
					.background(Color.appSecondaryButton)
					.foregroundColor(.appAccent)
					.cornerRadius(12)
			}
			.buttonStyle(.plain)
			.transition(.opacity.combined(with: .scale(scale: 0.8)))
			.confirmationDialog(
				"Remove ads for 1 hour?",
				isPresented: $showConfirmation,
				titleVisibility: .visible
			) {
				Button("Watch Ad") {
					adManager.showRewarded { rewarded in
						guard rewarded else { return }
						LSDefaults.activateAdFree()
						withAnimation(.easeInOut(duration: 0.25)) {
							isAdFree = true
						}
						onAdFreeActivated?()
					}
				}
				Button(role: .cancel) {} label: { Text("Cancel") }
			} message: {
				Text("Watch a short ad to enjoy 1 hour ad-free.")
			}
		}
	}
}
