//
//  FeedAdImpl.swift
//  ttad
//
//  Created by Jerry on 2020/7/26.
//

import BUAdSDK

internal final class FLTNativeAd: NSObject, BUNativeAdsManagerDelegate {
    typealias Success = (BUNativeAdsManager, [BUNativeAd]) -> Void
    typealias Fail = (BUNativeAdsManager, Error?) -> Void

    let success: Success?
    let fail: Fail?

    init(success: Success?, fail: Fail?) {
        self.success = success
        self.fail = fail
    }

    public func nativeAdsManager(_ adsManager: BUNativeAdsManager, didFailWithError error: Error?) {
        fail?(adsManager, error)
    }

    public func nativeAdsManagerSuccess(toLoad adsManager: BUNativeAdsManager, nativeAds nativeAdDataArray: [BUNativeAd]?) {
        success?(adsManager, nativeAdDataArray ?? [])
    }
}
