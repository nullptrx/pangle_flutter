//
//  FLTInterstitialAd.swift
//  pangle_flutter
//
//  Created by Jerry on 2020/8/13.
//

import BUAdSDK
import Flutter

class FLTInterstitialAd: NSObject, BUInterstitialAdDelegate {
    private var result: FlutterResult?
    init(_ result: @escaping FlutterResult) {
        self.result = result
    }
    
    func interstitialAdDidLoad(_ interstitialAd: BUInterstitialAd) {
        let vc = AppUtil.getVC()
        interstitialAd.show(fromRootViewController: vc)
        invoke()
    }
    
    func interstitialAd(_ interstitialAd: BUInterstitialAd, didFailWithError error: Error?) {
        let err = error as NSError?
        invoke(code: err?.code ?? -1, message: error?.localizedDescription)
    }
    
    func interstitialAdDidClick(_ interstitialAd: BUInterstitialAd) {}
    
    func interstitialAdDidClose(_ interstitialAd: BUInterstitialAd) {}
    
    func interstitialAdWillClose(_ interstitialAd: BUInterstitialAd) {}
    
    func interstitialAdWillVisible(_ interstitialAd: BUInterstitialAd) {}
    
    func interstitialAdDidCloseOtherController(_ interstitialAd: BUInterstitialAd, interactionType: BUInteractionType) {}
    
    func invoke(code: Int = 0, message: String? = nil) {
        guard result != nil else {
            return
        }
        
        let params = NSMutableDictionary()
        params["code"] = code
        params["message"] = message
        result!(params)
        PangleAdManager.shared.loadInterstitialAdComplete()
    }
}
