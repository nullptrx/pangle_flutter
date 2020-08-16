//
//  FLTBannerAd.swift
//  pangle_flutter
//
//  Created by nullptrX on 2020/8/16.
//

import BUAdSDK

@available(*, unavailable)
internal final class FLTBannerAd: NSObject, BUBannerAdViewDelegate {
    typealias Success = (BUBannerAdView, BUNativeAd?) -> Void
    typealias Fail = (BUBannerAdView, Error?) -> Void
    typealias Dislike = (BUBannerAdView, [BUDislikeWords]?) -> Void
    let success: Success?
    let fail: Fail?
    let dislike: Dislike?

    init(success: Success?, fail: Fail?, dislike: Dislike?) {
        self.success = success
        self.fail = fail
        self.dislike = dislike
    }

    public func bannerAdViewDidLoad(_ bannerAdView: BUBannerAdView, withAdmodel nativeAd: BUNativeAd?) {
        self.success?(bannerAdView, nativeAd)
    }

    public func bannerAdView(_ bannerAdView: BUBannerAdView, didLoadFailWithError error: Error?) {
        self.fail?(bannerAdView, error)
    }

    public func bannerAdView(_ bannerAdView: BUBannerAdView, dislikeWithReason filterwords: [BUDislikeWords]?) {
        self.dislike?(bannerAdView, filterwords)
    }
}
