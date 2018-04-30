//
//  NVAPIManager.swift
//  talktrans
//
//  Created by 영준 이 on 2016. 12. 8..
//  Copyright © 2016년 leesam. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

/**
 (1) 기계번역 API가 지원하는 언어 보기
 - 신규: 한국어(ko) <-> 중국어 번체 (zh-TW)
 - 한국어(ko) <-> 중국어 간체 (zh-CN)
 - 한국어(ko) <-> 영어 (en)
 - 한국어(ko) <-> 일어 (ja)
 */
class NaverPapago : NSObject{
    static let NaverAPIURLV1 = URL(string: "https://openapi.naver.com/v1")!;
    static let shared = NaverPapago();
    
    static let plistName = "NaverPapago";
    private var infos : [String : String]{
        get{
            guard let plist = Bundle.main.path(forResource: type(of: self).plistName, ofType: "plist") else{
                preconditionFailure("Please create plist file named of \(type(of: self).plistName). file[NaverPapago.plist]");
            }
            
            guard let dict = NSDictionary.init(contentsOfFile: plist) as? [String : String] else{
                preconditionFailure("Please \(type(of: self).plistName).plist is not Property List.");
            }
            
            //as? [String : [String : String]]
            
            return dict;
        }
    };
    
    enum NaverAPI : String{
        case NMT
        case SMT
    }
    
    private func clientIDForAPI(api : NaverAPI) -> String{
        guard let value = self.infos["ClientID"] else{
            preconditionFailure("Please add 'ClientID' into \(type(of: self).plistName).plist");
        }
        
        return value;
    }
    
    private func clientSecretForAPI(api : NaverAPI) -> String{
        guard let value = self.infos["ClientSecret"] else{
            preconditionFailure("Please add 'ClientSecret' into \(type(of: self).plistName).plist");
        }
        
        return value;
    }
    
    /*NMT 언어 코드.
     1.ko : 한국어
     2.en : 영어
     3.zh-CN : 중국어 간체
     4.zh-TW : 중국어 번체
     5.es : 스페인어
     6.fr : 프랑스어
     7.vi : 베트남어
     8.th : 태국어
     9.id : 인도네시아어
     10. ja : japan
     */
    static let NMTLangs = ["ko-Kore" : "ko", "ja" : "ja", "en" : "en", "zh-Hans" : "zh-CN", "zh-Hant" : "zh-TW", "es" : "es", "fr" : "fr", "vi" : "vi", "th" : "th",  "id" : "id"];
    static func NMTLang(_ locale : Locale) -> String?{
        return self.NMTLangs.first(where: { (key: String, value: String) -> Bool in
            return locale.identifier.hasPrefix(key);
        })?.value;
    }
    static let SMTLangs = ["ko-Kore" : "ko", "ja" : "ja", "en" : "en", "zh-Hans" : "zh-CN", "zh-Hant" : "zh-TW"];
    static func SMTLang(_ locale : Locale) -> String?{
        return self.SMTLangs.first(where: { (key: String, value: String) -> Bool in
            return locale.identifier.hasPrefix(key);
        })?.value;
    }
    static let DefaultSourceLang = "ko";
    
    typealias TranslateCompletionHandler = ((Int, String?, Error?) -> Void);
    
    static func canSupportTranslate(source : Locale, target : Locale) -> Bool{
        return ((source.languageCode == "ko"
            || target.languageCode == "ko")) && (source.languageCode != target.languageCode);
    }
    
    func requestTranslateByNMT(text : String, source : Locale, target : Locale, completionHandler: TranslateCompletionHandler?){
        var naverReq = NaverPapagoNMTRequest(id: self.clientIDForAPI(api: .NMT),
                                             secret: self.clientSecretForAPI(api: .NMT));
        
        let sourceLang = type(of: self).NMTLang(source) ?? NaverPapago.DefaultSourceLang;
        let targetLang = type(of: self).NMTLang(target) ?? "en";
        naverReq.data.source = sourceLang;
        naverReq.data.target = targetLang;
        naverReq.data.text = text;
        
        let json = String(data: naverReq.urlRequest.httpBody!, encoding: .utf8);
        print("naver => request \(naverReq.urlRequest) -> \(json ?? "")");
        //        UIApplication.shared.isNetworkActivityIndicatorVisible = true;
        Alamofire.request(naverReq.urlRequest).responseObject(success: NaverPapagoNMTResponse.self,
                                                              fail: NaverPapagoNMTError.self,
                                                              failureHandler: {(fail, response) in
                                                                completionHandler?(response.response?.statusCode ?? 599, nil, response.error);
        }) { (success, response) in
            let translatedText = success.message.result.text;
            completionHandler?(response.response?.statusCode ?? 200, translatedText, nil);
        }
    }
    
    func requestTranslateBySMT(text : String, source : Locale, target : Locale, completionHandler: TranslateCompletionHandler?){
        var naverReq = NaverPapagoSMTRequest(id: self.clientIDForAPI(api: .NMT),
                                       secret: self.clientSecretForAPI(api: .NMT));
        
        let sourceLang = type(of: self).SMTLang(source) ?? NaverPapago.DefaultSourceLang;
        let targetLang = type(of: self).SMTLang(target) ?? "en";
        naverReq.data.source = sourceLang;
        naverReq.data.target = targetLang;
        naverReq.data.text = text;
        
        let json = String(data: naverReq.urlRequest.httpBody!, encoding: .utf8);
        print("naver => request \(naverReq.urlRequest) -> \(json ?? "")");
//        UIApplication.shared.isNetworkActivityIndicatorVisible = true;
        Alamofire.request(naverReq.urlRequest).responseObject(success: NaverPapagoSMTResponse.self,
                                                              fail: NaverPapagoSMTError.self,
                                                              failureHandler: {(fail, response) in
            completionHandler?(response.response?.statusCode ?? 599, nil, response.error);
        }) { (success, response) in
            let translatedText = success.message.result.text;
            completionHandler?(response.response?.statusCode ?? 200, translatedText, nil);
        }
        /*Alamofire.request(naverReq.urlRequest).responseData(completionHandler: { (response) in
            guard let data = response.data, let res = response.response else{
                completionHandler?(response.response?.statusCode ?? 599, nil, response.error);
                return;
            }
            
            guard let smtResponse = try? JSONDecoder().decode(NaverPapagoSMTResponse.self, from: data) else {
                _ = try? JSONDecoder().decode(NaverPapagoSMTError.self, from: data);
                completionHandler?(res.statusCode, "", response.error);
                return;
            }
            let translatedText = smtResponse.message.result.text;
            let json = String(data: data, encoding: .utf8) ?? "";
            
            completionHandler?(res.statusCode, translatedText, nil);
            print("naver => response \(res.statusCode) - \(json.description)");
        })*/
    }
}
