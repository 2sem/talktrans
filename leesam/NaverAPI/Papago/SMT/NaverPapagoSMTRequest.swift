//
//  NaverSMTRequest.swift
//  talktrans
//
//  Created by 영준 이 on 2018. 4. 14..
//  Copyright © 2018년 leesam. All rights reserved.
//

import Foundation

public struct NaverPapagoSMTRequest{
    enum HeaderName : String{
        case ClientId = "X-Naver-Client-Id";
        case ClientSecret = "X-Naver-Client-Secret";
        case ContentType = "Content-Type";
    }

    struct RequestData : Codable{
        var source : String;
        var target : String;
        var text : String;
        
        var json : Data?{
            let encoder = JSONEncoder.init();
            encoder.outputFormatting = [.prettyPrinted];
            
            return try? encoder.encode(self);
        }
    }

    
    var clientId : String?{
        mutating get{
            return self[.ClientId];
        }
        set(value){
            self[.ClientId] = value;
        }
    }
    
    var clientSecret : String?{
        mutating get{
            return self[.ClientSecret];
        }
        set(value){
            self[.ClientSecret] = value;
        }
    }
    
    private lazy var _urlRequest : URLRequest = {
        var url = NaverPapago.NaverAPIURLV1;
        url.appendPathComponent("language/translate");
        var req = URLRequest.init(url: url);
        req.httpMethod = "POST";
        
        return req;
    }()
    
    var urlRequest : URLRequest{
        mutating get{
            self._urlRequest.httpBody = self.data.json;
            for header in self._urlRequest.allHTTPHeaderFields ?? [:]{
                print("http header[\(header.key)] : \(header.value)");
            }
            
            return self._urlRequest;
        }
    }
    
    var data : RequestData = RequestData.init(source: "", target: "", text: "");
    
    private subscript(field : HeaderName) -> String?{
        mutating get{
            return self._urlRequest.value(forHTTPHeaderField: field.rawValue);
        }
        
        set(value){
            //print("setting http header[\(field)] : \(value)");
            guard let value = value else{
                self._urlRequest.setValue(nil, forHTTPHeaderField: field.rawValue);
                return;
            }
            
            if self[field] == nil{
                self._urlRequest.addValue(value, forHTTPHeaderField: field.rawValue);
                print("add http header[\(field)] : \(value)");
            }else{
                self._urlRequest.setValue(value, forHTTPHeaderField: field.rawValue);
                print("set http header[\(field)] : \(value)");
            }
        }
    }
    
    init(id: String, secret: String) {
        self.clientId = id;
        self.clientSecret = secret;
        
        self[.ContentType] = "application/json;charset=utf-8";
    }
    
    /*
     req.addValue(self.clientIDForAPI(api: "Translator"), forHTTPHeaderField: "X-Naver-Client-Id");
     req.addValue(self.clientSecretForAPI(api: "Translator"), forHTTPHeaderField: "X-Naver-Client-Secret");
     //        req.addValue("j0xS22P7uh", forHTTPHeaderField: "X-Naver-Client-Secret");
     req.addValue("application/json;charset=utf-8", forHTTPHeaderField: "Content-Type");
     req.httpMethod = "POST";
     */
}
