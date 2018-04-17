//
//  TTDefaults.swift
//  talktrans
//
//  Created by 영준 이 on 2017. 2. 27..
//  Copyright © 2017년 leesam. All rights reserved.
//

import Foundation

class TTDefaults{
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
}
