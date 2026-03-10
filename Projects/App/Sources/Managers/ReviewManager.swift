//
//  ReviewManager.swift
//  App
//
//  Created by 영준 이 on 11/25/25.
//

import UIKit
import LSExtensions
import StoreKit

class ReviewManager : ObservableObject {
    var canShow: Bool {
        guard LSDefaults.translationCompletedCount >= 3 else { return false }
        guard let lastDate = LSDefaults.ReviewRequestedDate else { return true }
        #if DEBUG
        return Date().timeIntervalSince(lastDate) > 5 * 60
        #else
        return Date().timeIntervalSince(lastDate) > 90 * 86400
        #endif
    }
    
    func show(_ force : Bool = false) {
        guard self.canShow || force else {
            return
        }
    
        Task{ [unowned self] in
            await self._show()
        }
    }
    
    @MainActor internal func _show() {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        
        AppStore.requestReview(in: scene)
        
        // 리뷰 요청 기록
        LSDefaults.updateReviewRequestDate()
    }
}
