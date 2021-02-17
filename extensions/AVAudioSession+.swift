//
//  AVAudioSession+.swift
//  talktrans
//
//  Created by 영준 이 on 2021/02/15.
//  Copyright © 2021 leesam. All rights reserved.
//

import Foundation
import AVFoundation

extension AVAudioSession{
    static func fixConditionFalseCrash(){
        let session = self.sharedInstance();
//        AVAudioSession.Category.playback;
        do{
            try session.setCategory(.record, mode: .default, options: .defaultToSpeaker);
            try session.setActive(true, options: .notifyOthersOnDeactivation)
        }catch let error{
            print(#function, error);
        }
    }
}
