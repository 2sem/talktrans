//
//  DataRequest+.swift
//  talktrans
//
//  Created by 영준 이 on 2018. 4. 14..
//  Copyright © 2018년 leesam. All rights reserved.
//

import Foundation
import Alamofire

extension DataRequest {
    /** Adds a handler to be called once the request has finished.

        - parameter success: The type of success instance.
        - parameter fail: The type of failure instance.
        - parameter queue: The queue on which the completion handler is dispatched.
        - parameter failureHandler: The code to be executed once the request has failed.
        - parameter completionHandler: The code to be executed once the request has successed.
        - returns: The request.
     */
    @discardableResult
    public func responseObject<S, F>(success : S.Type, fail : F.Type,
        queue: DispatchQueue? = nil,
        failureHandler: @escaping (F?, DataResponse<Data>) -> Void,
        completionHandler: @escaping (S, DataResponse<Data>) -> Void)
        -> Self where S : Codable, F : Codable
    {
        return self.response(
            queue: queue,
            responseSerializer: DataRequest.dataResponseSerializer()
        ){ (response) in
            guard let data = response.data else{
                failureHandler(nil, response);
                return;
            }
            
            let json = String(data: data, encoding: .utf8) ?? "";
            print(" => response code[\(response.response?.statusCode ?? 0)] - json[\(json.description)]");
            
            guard let success = try? JSONDecoder().decode(S.self, from: data) else {
                failureHandler(nil, response);
                return;
            }
            
            completionHandler(success, response);
            //print("naver => response \(res.statusCode) - \(json.description)");
        }
    }
}


