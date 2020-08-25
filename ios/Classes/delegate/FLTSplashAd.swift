//
//  FLTSplashAd.swift
//  Pods-Runner
//
//  Created by Jerry on 2020/7/20.
//

import BUAdSDK
import Foundation

internal final class FLTSplashAd: NSObject, BUSplashAdDelegate {
    typealias Success = (BUSplashAdView) -> Void
    typealias Fail = (BUSplashAdView, Error?) -> Void
    
    let success: Success?
    let fail: Fail?
    
    init(success: Success?, fail: Fail?) {
        self.success = success
        self.fail = fail
    }
    
    public func splashAdDidClick(_ splashAd: BUSplashAdView) {
//        isClicked = true
    }
    
    func splashAdDidClickSkip(_ splashAd: BUSplashAdView) {
        splashAd.removeFromSuperview()
        self.success?(splashAd)
    }
    
    public func splashAdDidClose(_ splashAd: BUSplashAdView) {
        splashAd.removeFromSuperview()
        self.success?(splashAd)
    }
    
    public func splashAd(_ splashAd: BUSplashAdView, didFailWithError error: Error?) {
        splashAd.removeFromSuperview()
        self.fail?(splashAd, error)
    }
}
