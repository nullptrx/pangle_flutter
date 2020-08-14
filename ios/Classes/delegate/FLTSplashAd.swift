//
//  SplashAdImpl.swift
//  Pods-Runner
//
//  Created by Jerry on 2020/7/20.
//

import BUAdSDK
import Foundation

public class FLTSplashAd: NSObject, BUSplashAdDelegate {
//    private var isClicked = false
    private var result: FlutterResult?
//    init(_ result: @escaping FlutterResult) {
//        self.result = result
//    }
    
    func removeView(_ splashAd: BUSplashAdView) {
        splashAd.removeFromSuperview()
        splashAd.rootViewController = nil
    }
    
    public func splashAdDidClick(_ splashAd: BUSplashAdView) {
//        isClicked = true
    }
    
    public func splashAdDidClose(_ splashAd: BUSplashAdView) {
//        if isClicked {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                splashAd.removeFromSuperview()
//                self.invoke()
//            }
//        } else {
//        }
        removeView(splashAd)
        invoke()
    }
    
    public func splashAd(_ splashAd: BUSplashAdView, didFailWithError error: Error?) {
        removeView(splashAd)
        let err = error as NSError?
        invoke(code: err?.code ?? -1, message: error?.localizedDescription)
    }
    
    public func splashAdDidClickSkip(_ splashAd: BUSplashAdView) {}
    
    public func splashAdWillClose(_ splashAd: BUSplashAdView) {}
    
    func invoke(code: Int = 0, message: String? = nil) {
        guard result != nil else {
            return
        }
        
        let params = NSMutableDictionary()
        params["code"] = code
        params["message"] = message
        result!(params)
        PangleAdManager.shared.loadSplashAdComplete()
    }
}
