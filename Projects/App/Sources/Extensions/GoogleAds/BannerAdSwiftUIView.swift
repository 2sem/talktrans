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
	let adWidth: CGFloat?

	init(adWidth: CGFloat? = nil) {
		self.adWidth = adWidth
	}

	var body: some View {
		Group {
			if SwiftUIAdManager.isDisabled || adManager.isAdFree {
				EmptyView()
			} else if let bannerView = coordinator.bannerView {
				BannerAdRepresentable(bannerView: bannerView)
            } else {
                Color.clear.frame(height: 0)
            }
		}
		.onChange(of: adManager.isReady, initial: true) { _, isReady in
			guard isReady else { return }
			guard !adManager.isAdFree else { return }
			coordinator.load(withAdManager: adManager, adWidth: adWidth)
		}
		.onChange(of: adManager.isAdFree, initial: true) { _, isAdFree in
			if isAdFree {
				coordinator.reset()
			} else if adManager.isReady {
				coordinator.load(withAdManager: adManager, adWidth: adWidth)
			}
		}
		.onChange(of: adWidth) { _, newValue in
			guard adManager.isReady else { return }
			guard !adManager.isAdFree else { return }
			coordinator.load(withAdManager: adManager, adWidth: newValue)
		}
	}
}

@Observable
final class BannerAdCoordinator {
	var bannerView: BannerView?
	private var hasLoaded = false
	private var loadedWidth: CGFloat?

	func load(withAdManager manager: SwiftUIAdManager, adWidth: CGFloat? = nil) {
		let roundedWidth = adWidth.map { floor($0) }
		guard !hasLoaded || loadedWidth != roundedWidth else { return }

		let size: AdSize
		if let roundedWidth, roundedWidth > 0 {
			size = currentOrientationAnchoredAdaptiveBanner(width: roundedWidth)
		} else {
			size = AdSizeBanner
		}

		if let banner = manager.createBannerAdView(withAdSize: size, forUnit: .banner) {
			self.bannerView = banner
			self.hasLoaded = true
			self.loadedWidth = roundedWidth
			let request = Request()
			banner.load(request)
		}
	}

	func reset() {
		bannerView = nil
		hasLoaded = false
		loadedWidth = nil
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
