//
//  WatchAdButton.swift
//  talktrans
//
//  Created by 영준 이 on 3/10/26.
//  Copyright © 2026 leesam. All rights reserved.
//

import SwiftUI

struct WatchAdButton: View {
	let onReward: () -> Void
	@State private var showConfirmation = false

	var body: some View {
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
		.confirmationDialog(
			"Remove ads for 1 hour?",
			isPresented: $showConfirmation,
			titleVisibility: .visible
		) {
			Button("Watch Ad", action: onReward)
			Button(role: .cancel) {} label: { Text("Cancel") }
		} message: {
			Text("Watch a short ad to enjoy 1 hour ad-free.")
		}
	}
}
