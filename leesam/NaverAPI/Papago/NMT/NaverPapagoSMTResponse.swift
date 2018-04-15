//
//  NaverPapagoSMTResponse.swift
//  talktrans
//
//  Created by 영준 이 on 2018. 4. 14..
//  Copyright © 2018년 leesam. All rights reserved.
//

import Foundation

/**
 "message":
 {
 "@type":"response",
 "@service":"naverservice.labs.api",
 "@version":"1.0.0",
 "result":
 {
 "translatedText":"So glad to see you."}
 }
 }
 
 {"message":{"@type":"response","@service":"naverservice.labs.api","@version":"1.0.0","result":{"translatedText":"Hello.","srcLangType":"ko"}}}
 */
public struct NaverPapagoNMTResponse : Codable{
    struct Message: Codable{
        struct Result: Codable{
            var source: String;
            var text: String;
            
            enum CodingKeys: String, CodingKey{
                case source = "srcLangType"
                case text = "translatedText"
            }
            
            init(from decoder: Decoder) throws {
                let values = try decoder.container(keyedBy: CodingKeys.self);
                self.source = try values.decode(String.self, forKey: .source);
                self.text = try values.decode(String.self, forKey: .text);
            }
        }
        
        var type : String;
        var service : String;
        var version : String;
        var result : Result;
        
        enum CodingKeys: String, CodingKey{
            case type = "@type"
            case service = "@service"
            case version = "@version"
            case result
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self);
            self.type = try container.decode(String.self, forKey: .type);
            self.service = try container.decode(String.self, forKey: .service);
            self.version = try container.decode(String.self, forKey: .version);
            self.result = try container.decode(Result.self, forKey: .result);
        }
    }
    
    var message : Message;
}
