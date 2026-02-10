//
//  GADRewardedAd+.swift
//  talktrans
//
//  Created by 영준 이 on 2021/08/16.
//  Copyright © 2021 leesam. All rights reserved.
//

import Foundation
import GoogleMobileAds

extension RewardedAd{
    func isReady(for viewController: UIViewController? = nil) -> Bool{
        do{
            let rootVC = viewController ?? UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first(where: { $0.isKeyWindow })?.rootViewController
            if let viewController = rootVC{
                try self.canPresent(from: viewController);
                return true;
            }
            return false
        }catch{}
        
        return false;
    }
}
