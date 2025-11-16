//
//  ReviewManager.swift
//  wherewego
//
//  Created by 영준 이 on 2017. 5. 29..
//  Copyright © 2017년 leesam. All rights reserved.
//

import UIKit
import GoogleMobileAds
import StoreKit

protocol ReviewManagerDelegate : NSObjectProtocol{
    func reviewGetLastShowTime() -> Date;
    func reviewUpdate(showTime : Date);
}

class ReviewManager : NSObject{
    var window : UIWindow;
    var interval : TimeInterval = 60.0 * 60.0 * 3.0;
    var canShowFirstTime = true;
    var delegate : ReviewManagerDelegate?;
    
    fileprivate static var _shared : ReviewManager?;
    static var shared : ReviewManager?{
        get{
            return _shared;
        }
    }
    
    init(_ window : UIWindow, interval : TimeInterval = 60.0 * 60.0 * 3.0) {
        self.window = window;
        self.interval = interval;
        
        super.init();
        if ReviewManager._shared == nil{
            ReviewManager._shared = self;
        }
        //self.reset();
    }
    
    func reset(){
        //RSDefaults.LastFullADShown = Date();
        self.delegate?.reviewUpdate(showTime: Date());
    }
    
    var canShow : Bool{
        get{
            var value = true;
            let now = Date();
            
            guard self.delegate != nil else {
                return value;
            }
            
            let lastShowTime = self.delegate!.reviewGetLastShowTime();
            let time_1970 = Date.init(timeIntervalSince1970: 0);
            
            //(!self.canShowFirstTime &&
            guard self.canShowFirstTime || lastShowTime > time_1970 else{
                if lastShowTime <= time_1970{
                    self.delegate?.reviewUpdate(showTime: now);
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
            return;
        }
    
        self._show();
    }
    
    internal func _show(){
        guard self.window.rootViewController != nil else{
            return;
        }
        
        let name : String = UIApplication.shared.displayName ?? "";
        let acts = [UIAlertAction(title: String(format: "'%@' 평가".localized(), name), style: .default) { (act) in
                if #available(iOS 10.3, *) {
                    SKStoreReviewController.requestReview();
                } else {
                    UIApplication.shared.openReview();
                };
                UIApplication.shared.openReview();
            }, UIAlertAction(title: String(format: "'%@' 추천".localized(), name), style: .default) { (act) in
                        //self.window.rootViewController?.share(["\(UIApplication.shared.urlForItunes.absoluteString)"]);
                UIApplication.shared.shareByKakao();
            }/*,UIAlertAction(title: "제보하기".localized(), style: .default, handler: { (act) in
                //do not gain today
                UIApplication.shared.open(URL(string: "https://open.kakao.com/o/g1jk9Xx")!, options: [:], completionHandler: nil);
            })*/,UIAlertAction(title: "다음에 보기".localized(), style: .default, handler: { (act) in
                //do not gain today
                self.delegate?.reviewUpdate(showTime: Date().addingTimeInterval(60 * 60 * 24));
            }),UIAlertAction(title: "후원하기(동영상광고)".localized(), style: .default, handler: { (act) in
                GADRewardManager.shared?.show(true);
                
            })]
        self.window.rootViewController?.showAlert(title: "앱 평가 및 추천".localized(), msg: String(format: "'%@'을 평가하거나 친구들에게 추천해보세요.".localized(), name), actions: acts, style: .alert);
        self.delegate?.reviewUpdate(showTime: Date());
    }
}

