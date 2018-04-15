//
//  String+.swift
//  talktrans
//
//  Created by 영준 이 on 2016. 12. 11..
//  Copyright © 2016년 leesam. All rights reserved.
//

import Foundation

extension String{
    func localized(_ defaultText : String? = nil, locale: Locale? = Locale.current) -> String{
        var value = self;
        var bundlePath : String? = nil;
        if bundlePath == nil{
            bundlePath = Bundle.main.path(forResource: locale?.identifier, ofType: "lproj");
        }
        if bundlePath == nil{
            bundlePath = Bundle.main.path(forResource: locale?.languageCode, ofType: "lproj");
        }
        if bundlePath == nil{
            bundlePath = Bundle.main.path(forResource: "\(locale?.languageCode ?? "")-\(locale?.scriptCode ?? "")", ofType: "lproj");
        }
        //check if specified lang equals to base lang
        if bundlePath == nil && locale?.languageCode == "en"{
            bundlePath = Bundle.main.path(forResource: nil, ofType: "lproj");
        }
        if bundlePath == nil{
            value = NSLocalizedString(defaultText ?? self, comment: "");
        }else{
            var bundle = Bundle(path: bundlePath!)!;
//            value = bundle.localizedString(forKey: self, value: defaultText ?? self, table: nil);
            
            value = bundle.localizedString(forKey: self, value: defaultText ?? self, table: nil);
//            value = NSLocalizedString(self, tableName: nil, bundle: bundle, value: defaultText ?? self, comment: "");
        }
        
        return value;
//        return NSLocalizedString(defaultText ?? self, comment: "");
    }
}
