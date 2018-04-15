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
public struct NaverPapagoNMTError : Codable{
    var message : String;
    var code : String;
    enum ErrorCode : String{
        case N2MT01, N2MT02, N2MT03, N2MT04, N2MT05, N2MT06, N2MT07, N2MT08
        case N2MT99
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
