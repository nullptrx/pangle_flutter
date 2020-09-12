//
//  FLTBannerAd.swift
//  pangle_flutter
//
//  Created by nullptrX on 2020/8/16.
//

import BUAdSDK

@available(*, unavailable)
internal final class FLTBannerAd: NSObject, BUBannerAdViewDelegate {
    typealias Success = (BUNativeAd?) -> Void
    typealias Fail = (Error?) -> Void
    typealias Dislike = ([BUDislikeWords]?) -> Void
    let success: Success?
    let fail: Fail?
    let dislike: Dislike?

    init(success: Success?, fail: Fail?, dislike: Dislike?) {
        self.success = success
        self.fail = fail
        self.dislike = dislike
    }

    public func bannerAdViewDidLoad(_ bannerAdView: BUBannerAdView, withAdmodel nativeAd: BUNativeAd?) {
        self.success?(nativeAd)
    }

    public func bannerAdView(_ bannerAdView: BUBannerAdView, didLoadFailWithError error: Error?) {
        self.fail?(error)
    }

    public func bannerAdView(_ bannerAdView: BUBannerAdView, dislikeWithReason filterwords: [BUDislikeWords]?) {
        self.dislike?(filterwords)
    }
}
