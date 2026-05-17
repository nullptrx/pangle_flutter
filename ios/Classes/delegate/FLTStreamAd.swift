//
//  FLTStreamAd.swift
//  pangle_flutter
//

import BUAdSDK

internal final class FLTStreamAdDelegate: NSObject, BUNativeAdsManagerDelegate, FLTTaskProtocol {
    typealias Success = ([BUNativeAd]) -> Void
    typealias Fail = (Error?) -> Void

    private let successHandler: Success?
    private let failHandler: Fail?
    // Retains the manager so it isn't released while loading.
    private var manager: BUNativeAdsManager?
    // Called after success/fail so the owning task list can remove this delegate.
    var onComplete: ((FLTStreamAdDelegate) -> Void)?

    init(manager: BUNativeAdsManager, success: Success?, fail: Fail?) {
        self.manager = manager
        self.successHandler = success
        self.failHandler = fail
    }

    func nativeAdsManagerSuccessToLoad(_ adsManager: BUNativeAdsManager, nativeAds: [BUNativeAd]?) {
        manager = nil
        successHandler?(nativeAds ?? [])
        onComplete?(self)
    }

    func nativeAdsManager(_ adsManager: BUNativeAdsManager, didFailWithError error: Error?) {
        manager = nil
        failHandler?(error)
        onComplete?(self)
    }
}
