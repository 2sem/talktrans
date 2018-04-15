//
//  NSError+.swift
//  talktrans
//
//  Created by 영준 이 on 2016. 12. 8..
//  Copyright © 2016년 leesam. All rights reserved.
//

import Foundation

extension NSError{
    func isAssistantError() -> Bool{
        return self.domain == "kAFAssistantErrorDomain";
    }
    
    func getSiriError() -> NSError?{
        var value : NSError?;
        if self.isAssistantError(){
            if let siriError = self.userInfo["NSUnderlyingError"] as? NSError{
                if siriError.domain.hasPrefix("Siri"){
                    value = siriError;
                }
            }
        }
        
        return value;
    }
    
    func isSiriConnectionError() -> Bool{
        var value = false;
        
//        print("[\(#function)] error main \(self.domain)");
        if self.domain == "SiriCoreSiriConnectionErrorDomain"{
            value = true;
        }
        else if let siriError = self.getSiriError() {
//            print("[\(#function)] error siri \(siriError.domain)");
            value = (siriError.domain == "SiriCoreSiriConnectionErrorDomain");
        }
        
        return value;
    }
}
