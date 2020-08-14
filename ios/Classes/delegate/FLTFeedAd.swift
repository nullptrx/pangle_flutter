//
//  FeedAdImpl.swift
//  ttad
//
//  Created by Jerry on 2020/7/26.
//

import BUAdSDK
import Flutter

public class FLTFeedAd: NSObject, BUNativeAdsManagerDelegate {
    private var result: FlutterResult?
    init(_ result: @escaping FlutterResult) {
        self.result = result
    }
    
    public func nativeAdsManager(_ adsManager: BUNativeAdsManager, didFailWithError error: Error?) {
        let err = error as NSError?
        invoke(code: err?.code ?? -1, message: error?.localizedDescription)
    }

    public func nativeAdsManagerSuccess(toLoad adsManager: BUNativeAdsManager, nativeAds nativeAdDataArray: [BUNativeAd]?) {
        if nativeAdDataArray != nil {
            let keys = PangleAdManager.shared.setFeedAd(nativeAdDataArray!)
            invoke(code: 0, count: keys.count, data: keys)
        } else {
            invoke(code: -1)
        }
    }

    func invoke(code: Int = 0, message: String? = nil, count: Int = 0, data: [String]? = nil) {
        guard result != nil else {
            return
        }

        var params: [String: Any] = [:]
        params["code"] = code
        if message != nil {
            params["message"] = message
        }
        params["count"] = count
        if data != nil {
            params["data"] = data
        } else {
            params["data"] = []
        }
        result!(params)
        PangleAdManager.shared.loadFeedAdComplete()
    }
}
