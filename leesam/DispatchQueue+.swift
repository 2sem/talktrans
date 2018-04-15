//
//  DispatchQueue+.swift
//  gersanghelper
//
//  Created by 영준 이 on 2017. 10. 6..
//  Copyright © 2017년 leesam. All rights reserved.
//

import UIKit

extension DispatchQueue{
    //public func sync(execute block: () -> Swift.Void)
    func syncInMain(execute block:@escaping () -> Void){
        if !Thread.isMainThread{
            DispatchQueue.main.async {
                block();
            }
        }else{
            block();
        }
    }
}
