//
//  GADInterstitial+.swift
//  talktrans
//
//  Created by 영준 이 on 2017. 4. 12..
//  Copyright © 2017년 leesam. All rights reserved.
//

import Foundation
import GoogleMobileAds

/**
 GoogleADUnitID/{name}
 */
extension GADInterstitial {
    static func loadUnitId(name : String) -> String?{
        var value : String?;
        var unitList = Bundle.main.infoDictionary?["GoogleADUnitID"] as? [String : String];
        guard unitList != nil else{
            print("Add [String : String] Dictionary as 'GoogleADUnitID'");
            return value;
        }
        
        guard !(unitList ?? [:]).isEmpty else{
            print("Add Unit into 'GoogleADUnitID'");
            return value;
        }
        
        value = unitList?[name];
        guard value != nil else{
            print("Add unit \(name) into GoogleADUnitID");
            return value;
        }
        
        return value;
    }
}
