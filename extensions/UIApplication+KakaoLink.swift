//
//  UIApplication+KakaoLink.swift
//  democracyaction
//
//  Created by 영준 이 on 2017. 7. 7..
//  Copyright © 2017년 leesam. All rights reserved.
//

import Foundation
import KakaoSDKShare
import KakaoSDKTemplate

extension UIApplication{
    func shareByKakao(){
        let kakaoLink = Link();
        let kakaoContent = Content.init(title: UIApplication.shared.displayName ?? "",
                                        imageUrl: URL(string: "https://is1-ssl.mzstatic.com/image/thumb/Purple128/v4/8d/f9/04/8df90400-4feb-c7ec-bb2e-b52261a7d5f1/mzl.hyjsxhof.png/150x150bb.jpg")!,
                                        imageWidth: 120,
                                        imageHeight: 120,
                                        description: "해외, 국내 여행시 외국인을 만나면 당황하셨나요?",
                                        link: kakaoLink)
        
        let kakaoTemplate = FeedTemplate.init(content: kakaoContent,
                                              buttons: [.init(title: "다운로드",
                                                              link: .init())])
        
        ShareApi.shared.shareDefault(templatable: kakaoTemplate) { result, error in
            guard let result = result else {
                print("kakao error[\(error.debugDescription )]")
                return
            }
            
            UIApplication.shared.open(result.url)
            print("kakao warn[\(result.warningMsg?.debugDescription ?? "")] args[\(result.argumentMsg?.debugDescription ?? "")]")
        }
    }
}
