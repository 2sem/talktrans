//
//  NaverPapagoSMTError.swift
//  talktrans
//
//  Created by 영준 이 on 2018. 4. 14..
//  Copyright © 2018년 leesam. All rights reserved.
//

import Foundation

/**
 {
    "errorMessage":"text parameter is needed (text 파라미터가 필요합니다.)",
    "errorCode":"TR07"
 }
 */
public struct NaverPapagoSMTError : Codable{
    var message : String;
    var code : String;
    enum ErrorCode : String{
        case TR01, TR02, TR03, TR04, TR05, TR06, TR07, TR08
        case TR99
    }
    
    enum CodingKeys: String, CodingKey{
        case message = "errorMessage"
        case code = "errorCode"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self);
        self.message = try container.decode(String.self, forKey: .message);
        self.code = try container.decode(String.self, forKey: .code);
    }
}
