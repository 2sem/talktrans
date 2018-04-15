//
//  UIApplication+.swift
//  talktrans
//
//  Created by 영준 이 on 2017. 10. 4..
//  Copyright © 2017년 leesam. All rights reserved.
//

import Foundation
import UIKit

extension UIApplication{
    public var appId : String{
        get{
            return "1186147362";
        }
    }
    
    var displayName : String?{
        get{
            var value = Bundle.main.localizedInfoDictionary?["CFBundleDisplayName"] as? String;
            if value == nil{
                value = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String;
            }
            
            return value;
        }
    }
    
    var urlForItunes : URL{
        get{
            return URL(string :"https://itunes.apple.com/kr/app/sendadv/id\(self.appId)?l=ko&mt=8")!;
        }
    }
    
    func openItunes(){
        self.open(self.urlForItunes, options: [:], completionHandler: nil) ;
    }
    
    func openReview(_ appId : String = "1186147362", completion: ((Bool) -> Void)? = nil){
        var rateUrl = URL(string: "http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=\(appId)&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8");
        
        self.open(rateUrl!, options: [:], completionHandler: completion);
    }
}

