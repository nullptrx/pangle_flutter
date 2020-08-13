//
//  FLTInterstitialAd.swift
//  pangle_flutter
//
//  Created by Jerry on 2020/8/12.
//

import BUAdSDK
import Flutter

class FLTInterstitialExpressAd: NSObject, BUNativeExpresInterstitialAdDelegate {
    private var result: FlutterResult?
    init(_ result: @escaping FlutterResult) {
        self.result = result
    }
    
    func nativeExpresInterstitialAdDidLoad(_ interstitialAd: BUNativeExpressInterstitialAd) {}
    
    func nativeExpresInterstitialAdRenderFail(_ interstitialAd: BUNativeExpressInterstitialAd, error: Error?) {
        let err = error as NSError?
        invoke(code: err?.code ?? -1, message: error?.localizedDescription)
    }
    
    func nativeExpresInterstitialAd(_ interstitialAd: BUNativeExpressInterstitialAd, didFailWithError error: Error?) {
        let err = error as NSError?
        invoke(code: err?.code ?? -1, message: error?.localizedDescription)
    }
    
    func nativeExpresInterstitialAdDidClick(_ interstitialAd: BUNativeExpressInterstitialAd) {
    }
    
    func nativeExpresInterstitialAdDidClose(_ interstitialAd: BUNativeExpressInterstitialAd) {
    }
    
    func nativeExpresInterstitialAdWillClose(_ interstitialAd: BUNativeExpressInterstitialAd) {}
    
    func nativeExpresInterstitialAdWillVisible(_ interstitialAd: BUNativeExpressInterstitialAd) {}
    
    func nativeExpresInterstitialAdRenderSuccess(_ interstitialAd: BUNativeExpressInterstitialAd) {
        let vc = AppUtil.getVC()
        interstitialAd.show(fromRootViewController: vc)
        invoke()
    }
    
    func nativeExpresInterstitialAdDidCloseOtherController(_ interstitialAd: BUNativeExpressInterstitialAd, interactionType: BUInteractionType) {}
    
    func invoke(code: Int = 0, message: String? = nil) {
        guard result != nil else {
            return
        }
        
        let params = NSMutableDictionary()
        params["code"] = code
        params["message"] = message
        result!(params)
        PangleAdManager.shared.loadInterstitialExpressAdComplete()
    }
}
