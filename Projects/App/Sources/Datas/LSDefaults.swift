//
//  TTDefaults.swift
//  talktrans
//
//  Created by 영준 이 on 2017. 2. 27..
//  Copyright © 2017년 leesam. All rights reserved.
//

import Foundation

class LSDefaults{
    static var Defaults : UserDefaults{
        get{
            return UserDefaults.standard;
        }
    }
    
    class Keys{
        static let IsUpsideDown = "IsUpsideDown";
        static let IsRotateFixed = "IsRotateFixed";
        
        static let LastFullADShown = "LastFullADShown";
        static let LastShareShown = "LastShareShown";
        static let LastRewardShown = "LastRewardShown";
        static let LastOpeningAdPrepared = "LastOpeningAdPrepared";

        static let LaunchCount = "LaunchCount";
        
        static let TranslationSourceLocale = "TranslationSourceLocale"
        static let TranslationTargetLocale = "TranslationTargetLocale"
        static let TranslationOutputRotationAngle = "TranslationOutputRotationAngle"
        static let TranslationOutputFontSize = "TranslationOutputFontSize"
        
        static let AdsShownCount = "AdsShownCount";
        static let AdsTrackingRequested = "AdsTrackingRequested";
        static let ReviewRequestedDate = "ReviewRequestedDate";
    }
    
    static var isUpsideDown : Bool?{
        get{
            return Defaults.bool(forKey: Keys.IsUpsideDown);
        }
        
        set(value){
            Defaults.set(value, forKey: Keys.IsUpsideDown);
        }
    }
    
    static var isRotateFixed : Bool?{
        get{
            return Defaults.bool(forKey: Keys.IsRotateFixed);
        }
        
        set(value){
            Defaults.set(value, forKey: Keys.IsRotateFixed);
        }
    }
    
    static var LastFullADShown : Date{
        get{
            let seconds = Defaults.double(forKey: Keys.LastFullADShown);
            return Date.init(timeIntervalSince1970: seconds);
        }
        
        set(value){
            Defaults.set(value.timeIntervalSince1970, forKey: Keys.LastFullADShown);
        }
    }
    
    static var LastShareShown : Date{
        get{
            let seconds = Defaults.double(forKey: Keys.LastShareShown);
            return Date.init(timeIntervalSince1970: seconds);
        }
        
        set(value){
            Defaults.set(value.timeIntervalSince1970, forKey: Keys.LastShareShown);
        }
    }
    
    static var LastRewardShown : Date{
        get{
            let seconds = Defaults.double(forKey: Keys.LastRewardShown);
            return Date.init(timeIntervalSince1970: seconds);
        }
        
        set(value){
            Defaults.set(value.timeIntervalSince1970, forKey: Keys.LastRewardShown);
        }
    }
    
    static var LastOpeningAdPrepared : Date{
        get{
            let seconds = Defaults.double(forKey: Keys.LastOpeningAdPrepared);
            return Date.init(timeIntervalSince1970: seconds);
        }
        
        set(value){
            Defaults.set(value.timeIntervalSince1970, forKey: Keys.LastOpeningAdPrepared);
        }
    }
    
    static func increaseLaunchCount(){
        self.LaunchCount = self.LaunchCount.advanced(by: 1);
    }
    
    static var LaunchCount : Int{
        get{
            //UIApplication.shared.version
            return Defaults.integer(forKey: Keys.LaunchCount);
        }
        
        set(value){
            Defaults.set(value, forKey: Keys.LaunchCount);
        }
    }
    
    static var translationSourceLocale: String? {
        get {
            return Defaults.string(forKey: Keys.TranslationSourceLocale)
        }
        set(value) {
            Defaults.set(value, forKey: Keys.TranslationSourceLocale)
        }
    }
    
    static var translationTargetLocale: String? {
        get {
            return Defaults.string(forKey: Keys.TranslationTargetLocale)
        }
        set(value) {
            Defaults.set(value, forKey: Keys.TranslationTargetLocale)
        }
    }
    
    static var translationOutputRotationAngle: Double {
        get {
            if Defaults.object(forKey: Keys.TranslationOutputRotationAngle) == nil {
                // Default to 180 degrees if not set
                return 180
            }
            return Defaults.double(forKey: Keys.TranslationOutputRotationAngle)
        }
        set(value) {
            Defaults.set(value, forKey: Keys.TranslationOutputRotationAngle)
        }
    }

    static var translationOutputFontSize: CGFloat {
        get {
            if Defaults.object(forKey: Keys.TranslationOutputFontSize) == nil {
                // Default to 16 points if not set
                return 16
            }
            return CGFloat(Defaults.double(forKey: Keys.TranslationOutputFontSize))
        }
        set(value) {
            Defaults.set(Double(value), forKey: Keys.TranslationOutputFontSize)
        }
    }

    static var AdsTrackingRequested : Bool{
            get{
                return Defaults.bool(forKey: Keys.AdsTrackingRequested);
            }
            
            set{
                Defaults.set(newValue, forKey: Keys.AdsTrackingRequested);
            }
        }
        
        static var isReviewRequested: Bool {
            get {
                return ReviewRequestedDate != nil
            }
        }
        
        static var ReviewRequestedDate: Date? {
            get {
                let seconds = Defaults.double(forKey: Keys.ReviewRequestedDate)
                return seconds > 0 ? Date(timeIntervalSince1970: seconds) : nil
            }
            
            set {
                if let value = newValue {
                    Defaults.set(value.timeIntervalSince1970, forKey: Keys.ReviewRequestedDate)
                } else {
                    Defaults.removeObject(forKey: Keys.ReviewRequestedDate)
                }
            }
        }
        
        static func updateReviewRequestDate() {
            ReviewRequestedDate = Date()
        }
}
