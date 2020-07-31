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
    private var tag: String
    init(_ result: @escaping FlutterResult, tag: String) {
        self.result = result
        self.tag = tag
    }

    public func nativeAdsManager(_ adsManager: BUNativeAdsManager, didFailWithError error: Error?) {
        invoke(code: -1, message: error?.localizedDescription)
    }

    public func nativeAdsManagerSuccess(toLoad adsManager: BUNativeAdsManager, nativeAds nativeAdDataArray: [BUNativeAd]?) {
        if nativeAdDataArray != nil {
            PangleAdManager.shared.setFeedAd(tag, feedAds: nativeAdDataArray!)
        }
        invoke(code: 0, message: nil, count: nativeAdDataArray?.count ?? 0)
    }

    func invoke(code: Int = 0, message: String? = nil, count: Int = 0) {
        guard result != nil else {
            return
        }

        let params = NSMutableDictionary()
        params["code"] = code
        params["message"] = message
        params["count"] = count
        result!(params)
        PangleAdManager.shared.loadFeedAdComplete()
    }
}
