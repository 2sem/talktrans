//
//  UIApplication+.swift
//  talktrans
//
//  Created by 영준 이 on 2021/08/16.
//  Copyright © 2021 leesam. All rights reserved.
//

import UIKit

extension UIApplication {
	var firstRootViewController: UIViewController? {
		connectedScenes
			.compactMap { $0 as? UIWindowScene }
			.flatMap { $0.windows }
			.first(where: { $0.isKeyWindow })?.rootViewController
	}
	
	/// Returns the first key window from all connected scenes.
	var firstKeyWindow: UIWindow? {
		connectedScenes
			.compactMap { $0 as? UIWindowScene }
			.flatMap { $0.windows }
			.first { $0.isKeyWindow }
	}
}
