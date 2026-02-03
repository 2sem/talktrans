//
//  BannerAdSwiftUIView.swift
//  App
//
//  Created by 영준 이 on 11/25/25.
//

import SwiftUI
import GoogleMobileAds

struct BannerAdSwiftUIView: View {
	@EnvironmentObject private var adManager: SwiftUIAdManager
	@State private var coordinator = BannerAdCoordinator()

	var body: some View {
		Group {
			if SwiftUIAdManager.isDisabled {
				EmptyView()
			} else if let bannerView = coordinator.bannerView {
				BannerAdRepresentable(bannerView: bannerView)
			}
		}
		.onChange(of: adManager.isReady, initial: true) { _, isReady in
			guard isReady else { return }
			coordinator.load(withAdManager: adManager)
		}
	}
}

@Observable
final class BannerAdCoordinator {
	var bannerView: BannerView?
	private var hasLoaded = false

	func load(withAdManager manager: SwiftUIAdManager) {
		guard !hasLoaded else { return }

		if let banner = manager.createBannerAdView(withAdSize: AdSizeBanner, forUnit: .banner) {
			self.bannerView = banner
			self.hasLoaded = true
			let request = Request()
			banner.load(request)
		}
	}
}

private struct BannerAdRepresentable: UIViewRepresentable {
	let bannerView: BannerView

	func makeUIView(context: Context) -> BannerView {
		return bannerView
	}

	func updateUIView(_ uiView: BannerView, context: Context) {
		// Nothing to update
	}
}
