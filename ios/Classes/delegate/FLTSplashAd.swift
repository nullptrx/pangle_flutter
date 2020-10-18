//
//  FLTSplashAd.swift
//  Pods-Runner
//
//  Created by Jerry on 2020/7/20.
//

import BUAdSDK
import Foundation

internal final class FLTSplashAd: NSObject, BUSplashAdDelegate {
    typealias Success = (String) -> Void
    typealias Fail = (Error?) -> Void
    
    let success: Success?
    let fail: Fail?
    
    init(success: Success?, fail: Fail?) {
        self.success = success
        self.fail = fail
    }
    
    public func splashAdDidClick(_ splashAd: BUSplashAdView) {
        self.success?("click")
        splashAd.removeFromSuperview()
    }
    
    func splashAdDidClickSkip(_ splashAd: BUSplashAdView) {
        self.success?("skip")
        splashAd.removeFromSuperview()
    }
    
    public func splashAdDidClose(_ splashAd: BUSplashAdView) {
        self.success?("timeover")
        splashAd.removeFromSuperview()
    }
    
    public func splashAd(_ splashAd: BUSplashAdView, didFailWithError error: Error?) {
        self.fail?(error)
        splashAd.removeFromSuperview()
    }
}
