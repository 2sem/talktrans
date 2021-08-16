//
//  GADRewardManager.swift
//  relatedstocks
//
//  Created by 영준 이 on 2017. 8. 25..
//  Copyright © 2017년 leesam. All rights reserved.
//

import UIKit
import GoogleMobileAds

protocol GADRewardManagerDelegate : NSObjectProtocol{
    func GADRewardGetLastShowTime() -> Date;
    func GADRewardUpdate(showTime : Date);
    func GADRewardWillLoad();
    func GADRewardUserCompleted();
}

extension GADRewardManagerDelegate{
    func GADRewardWillLoad(){}
    func GADRewardUserCompleted(){}
}

class GADRewardManager : NSObject{
    var window : UIWindow;
    var unitId : String;
    var interval : TimeInterval = 60.0 * 60.0 * 3.0;
    var canShowFirstTime = true;
    var delegate : GADRewardManagerDelegate?;
    var rewarded = false;
    
    fileprivate static var _shared : GADRewardManager?;
    static var shared : GADRewardManager?{
        get{
            return _shared;
        }
    }
    
    init(_ window : UIWindow, unitId : String, interval : TimeInterval = 60.0 * 60.0 * 3.0) {
        self.window = window;
        self.unitId = unitId;
        self.interval = interval;
        
        super.init();
        //self.reset();
        if GADRewardManager._shared == nil{
            GADRewardManager._shared = self;
        }
    }
    
    func reset(){
        //RSDefaults.LastFullADShown = Date();
        self.delegate?.GADRewardUpdate(showTime: Date());
    }
    
    var rewardAd : GADRewardedAd?;
    var canShow : Bool{
        get{
            var value = true;
            let now = Date();
            
            guard self.delegate != nil else {
                return value;
            }
            
            let lastShowTime = self.delegate!.GADRewardGetLastShowTime();
            let time_1970 = Date.init(timeIntervalSince1970: 0);
            
            //(!self.canShowFirstTime &&
            guard self.canShowFirstTime || lastShowTime > time_1970 else{
                if lastShowTime <= time_1970{
                    self.delegate?.GADRewardUpdate(showTime: now);
                }
                value = false;
                return value;
            }
            
            let spent = now.timeIntervalSince(lastShowTime);
            value = spent > self.interval;
            print("time spent \(spent) since \(lastShowTime). now[\(now)]");
            
            return value;
        }
    }
    
    func show(_ force : Bool = false){
        guard self.canShow || force else {
            //self.window.rootViewController?.showAlert(title: "알림", msg: "1시간에 한번만 후원하실 수 있습니다 ^^;", actions: [UIAlertAction(title: "확인", style: .default, handler: nil)], style: .alert);
            return;
        }
        
        self._show();
    }
    
    func _show(){
        /*guard self.canShow else {
         return;
         }*/
        
        guard !(self.rewardAd?.isReady() ?? false) else{
            print("reward ad is already ready - self.rewardAd?.isReady");
            self.__show();
            return;
        }
    
//        self.rewardAd?.delegate = self;
        let req = GADRequest();
        #if DEBUG
        let unitId = "ca-app-pub-3940256099942544/1712485313"
        #else
        let unitId = self.unitId;
        #endif
        /*if let alert = UIApplication.shared.keyWindow?.rootViewController?.presentedViewController as? UIAlertController{
         alert.dismiss(animated: false, completion: nil);
         }
         }*/
        
        print("create new reward ad");
//        self.rewardAd = GADRewardedAd(adUnitId: self.);
        GADRewardedAd.load(withAdUnitID: unitId, request: req) { [weak self](newAd, error) in
            self?.rewardAd = newAd
            self?.rewardAd?.fullScreenContentDelegate = self;
            
            guard error == nil else{
                return;
            }
            
            print("reward is ready to be presented");
            self?._show();
        }
        self.delegate?.GADRewardWillLoad();
    }
    
    private func __show(){
        guard self.window.rootViewController != nil else{
            return;
        }
        
        /*guard self.canShow else {
         return;
         }*/
        
        //ignore if alert is being presented
        /*if let alert = UIApplication.shared.keyWindow?.rootViewController?.presentedViewController as? UIAlertController{
         alert.dismiss(animated: false, completion: nil);
         }*/
        
        guard !(UIApplication.shared.keyWindow?.rootViewController?.presentedViewController is UIAlertController) else{
            //alert.dismiss(animated: false, completion: nil);
            self.rewardAd = nil;
            return;
        }
        
        print("present full ad view[\(self.window.rootViewController?.description ?? "")]");
        self.rewarded = false;
        self.rewardAd?.present(fromRootViewController: self.window.rootViewController!, userDidEarnRewardHandler: { [weak self] in
            guard let reward = self?.rewardAd?.adReward else{
                return;
            }
            
            print("user reward. type[\(reward.type)] amount[\(reward.amount)]");
            self?.rewarded = true;
        })
        self.delegate?.GADRewardUpdate(showTime: Date());
        //RSDefaults.LastFullADShown = Date();
    }
}

extension GADRewardManager : GADFullScreenContentDelegate{
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("reward has been compleated");
        
        self.rewardAd = nil;
        
        guard self.rewarded else{
            return;
        }
        
        self.window.rootViewController?.showAlert(title: "후원해주셔서 감사합니다.", msg: "불편하신 사항은 리뷰에 남겨주시면 반영하겠습니다.", actions: [UIAlertAction.init(title: "확인", style: .default, handler: nil), UIAlertAction.init(title: "평가하기", style: .default, handler: { (act) in
            UIApplication.shared.openReview();
        })], style: .alert);
        self.delegate?.GADRewardUserCompleted();
    }
    
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("reward fail[\(error)]");
    }
}
