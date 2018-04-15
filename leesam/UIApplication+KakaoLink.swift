//
//  UIApplication+KakaoLink.swift
//  democracyaction
//
//  Created by 영준 이 on 2017. 7. 7..
//  Copyright © 2017년 leesam. All rights reserved.
//

import Foundation
import KakaoLink
import KakaoMessageTemplate

extension UIApplication{
    func shareByKakao(){
        var kakaoLink = KMTLinkObject();
        var kakaoContent = KMTContentObject(title: UIApplication.shared.displayName ?? "", imageURL: URL(string: "https://is1-ssl.mzstatic.com/image/thumb/Purple128/v4/8d/f9/04/8df90400-4feb-c7ec-bb2e-b52261a7d5f1/mzl.hyjsxhof.png/150x150bb.jpg")!, link: kakaoLink);
        kakaoContent.imageWidth = 120;
        kakaoContent.imageHeight = 120; //160
        kakaoContent.desc = "해외, 국내 여행시 외국인을 만나면 당황하셨나요?";
        
        var kakaoTemplate = KMTFeedTemplate.init(builderBlock: { (kakaoBuilder) in
            kakaoBuilder.content = kakaoContent;
            //kakaoBuilder.buttons?.add(kakaoWebButton);
            //link can't have more than two buttons
            // - content's url, button1 url, button2 url
            /*kakaoBuilder.addButton(KLKButtonObject(builderBlock: { (buttonBuilder) in
                buttonBuilder.link = KLKLinkObject(builderBlock: { (linkBuilder) in
                    linkBuilder.webURL = URL(string: "https://itunes.apple.com/us/app/id1243863489?mt=8");
                    linkBuilder.mobileWebURL = URL(string: "https://itunes.apple.com/us/app/id1243863489?mt=8");
                })
                buttonBuilder.title = "애플 앱스토어";
            }));*/
            
            /*kakaoBuilder.addButton(KLKButtonObject(builderBlock: { (buttonBuilder) in
                buttonBuilder.link = KLKLinkObject(builderBlock: { (linkBuilder) in
                    linkBuilder.webURL = URL(string: "https://play.google.com/store/apps/details?id=kr.co.ncredif.directdemocracy");
                    linkBuilder.mobileWebURL = URL(string: "https://play.google.com/store/apps/details?id=kr.co.ncredif.directdemocracy");
                    //linkBuilder.mobileWebURL = URL(string: "www.daum.net");
                })
                buttonBuilder.title = "구글플레이";
            }));*/
            /*kakaoBuilder.addButton(KLKButtonObject(builderBlock: { (buttonBuilder) in
                buttonBuilder.link = KLKLinkObject(builderBlock: { (linkBuilder) in
                    linkBuilder.webURL = URL(string: "https://youtu.be/0n0oQkLX_4s");
                    //linkBuilder.webURL = URL(string: "https://www.youtube.com/watch?v=0n0oQkLX_4s");

                    linkBuilder.mobileWebURL = linkBuilder.webURL;
                })
                buttonBuilder.title = "언론보도";
            }));*/
            
            kakaoBuilder.addButton(KMTButtonObject(builderBlock: { (buttonBuilder) in
                buttonBuilder.link = KMTLinkObject(builderBlock: { (linkBuilder) in
                    //linkBuilder.webURL = URL(string: "https://itunes.apple.com/us/app/id1243863489?mt=8");
                    //linkBuilder.mobileWebURL = URL(string: "https://itunes.apple.com/us/app/id1243863489?mt=8");
                })
                buttonBuilder.title = "다운로드";
            }));
            
            //https://youtu.be/0n0oQkLX_4s
        })
        
        KLKTalkLinkCenter.shared().sendDefault(with: kakaoTemplate, success: { (warn, args) in
            print("kakao warn[\(warn)] args[\(args)]")
        }, failure: { (error) in
            print("kakao error[\(error)]")
        })
    }
    
    func _shareByKakao(){
        var kakaoNews1 = KMTContentObject(title: "‘문자행동’ 어플 개발자 인터뷰···“민주주의 발전에 한손 보탤 수 있길”", imageURL: URL(string: "http://img.khan.co.kr/news/2017/06/23/l_2017062301003119000246131.jpg")!, link: KMTLinkObject(builderBlock: { (linkBuilder) in
            linkBuilder.webURL = URL(string: "http://news.khan.co.kr/kh_news/khan_art_view.html?artid=201706231651011&code=940100");
            //linkBuilder.webURL = URL(string: "http://www.daum.net");
            linkBuilder.mobileWebURL = linkBuilder.webURL;
        }));
        kakaoNews1.desc = "경향신문";
        var kakaoNews2 = KMTContentObject(title: "국회의원 연락처 한 곳에…‘문자행동’ 어플까지 나왔네", imageURL: URL(string: "http://img.hani.co.kr/imgdb/resize/2017/0623/00501745_20170623.JPG")!, link: KMTLinkObject(builderBlock: { (linkBuilder) in
            linkBuilder.webURL = URL(string: "http://www.hani.co.kr/arti/society/society_general/799996.html");
            linkBuilder.mobileWebURL = linkBuilder.webURL;
        }));
        kakaoNews2.desc = "한겨례";
        var kakaoNews3 = KMTContentObject(builderBlock: { (contentBuilder) in
            contentBuilder.title = "\"문자 폭탄\" VS \"문자 행동\" 논란 속에…'의견 앱' 등장";
            contentBuilder.desc = "SBS";
            contentBuilder.imageURL = URL(string: "https://www.youtube.com/watch?v=0n0oQkLX_4s")!;
            contentBuilder.link = KMTLinkObject(builderBlock: { (linkBuilder) in
                linkBuilder.webURL = URL(string: "https://youtu.be/0n0oQkLX_4s");
                linkBuilder.mobileWebURL = linkBuilder.webURL;
            });
        })
        //kakaoNews3.desc = "SBS";
        
        var kakaoTemplate = KMTListTemplate(builderBlock: { (kakaoBuilder) in
            kakaoBuilder.headerTitle = "문자행동 - 내 손안의 민주주의";
            kakaoBuilder.headerLink = KMTLinkObject(builderBlock: { (linkBuilder) in
                var searchUrl = URLComponents(string: "http://search.daum.net/search");
                searchUrl?.queryItems = [URLQueryItem(name: "q", value: "문자행동")];
                linkBuilder.webURL = searchUrl?.url;
            });
            kakaoBuilder.contents = [kakaoNews1, kakaoNews2, kakaoNews3];
            //kakaoBuilder.buttons?.add(kakaoWebButton);
            //link can't have more than two buttons
            // - content's url, button1 url, button2 url
            kakaoBuilder.addButton(KMTButtonObject(builderBlock: { (buttonBuilder) in
                buttonBuilder.link = KMTLinkObject(builderBlock: { (linkBuilder) in
                    linkBuilder.webURL = URL(string: "http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=\(UIApplication.shared.appId)&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8");
                    //linkBuilder.webURL = URL(string: "https://www.youtube.com/watch?v=0n0oQkLX_4s");
                    
                    linkBuilder.mobileWebURL = linkBuilder.webURL;
                })
                buttonBuilder.title = "응원하기";
            }));
            
            kakaoBuilder.addButton(KMTButtonObject(builderBlock: { (buttonBuilder) in
                buttonBuilder.link = KMTLinkObject(builderBlock: { (linkBuilder) in
                    //linkBuilder.webURL = URL(string: "https://itunes.apple.com/us/app/id1243863489?mt=8");
                    //linkBuilder.mobileWebURL = URL(string: "https://itunes.apple.com/us/app/id1243863489?mt=8");
                })
                buttonBuilder.title = "앱 다운로드";
            }));
            
            //https://youtu.be/0n0oQkLX_4s
        })
        
        KLKTalkLinkCenter.shared().sendDefault(with: kakaoTemplate, success: { (warn, args) in
            print("kakao warn[\(warn)] args[\(args)]")
        }, failure: { (error) in
            print("kakao error[\(error)]")
        })
    }
}
