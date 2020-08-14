//
//  FLTFeedExpressAd.swift
//  pangle_flutter
//
//  Created by Jerry on 2020/8/14.
//

import BUAdSDK
import Flutter

class FLTFeedExpressAd: NSObject, BUNativeExpressAdViewDelegate {
    private var result: FlutterResult?
    init(_ result: @escaping FlutterResult) {
        self.result = result
    }

    public func nativeExpressAdFail(toLoad nativeExpressAd: BUNativeExpressAdManager, error: Error?) {
        let err = error as NSError?
        invoke(code: err?.code ?? -1, message: error?.localizedDescription)
    }

    public func nativeExpressAdViewRenderFail(_ nativeExpressAdView: BUNativeExpressAdView, error: Error?) {
        let err = error as NSError?
//        invoke(code: err?.code ?? -1, message: error?.localizedDescription)
        // 通过观察者方式回调给目标FeedView
        let param: [String: Any] = [
            "feedId": String(nativeExpressAdView.hash),
            "code": err?.code ?? -1,
            "type": "fail",
            "message": error?.localizedDescription ?? "",
        ]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.kFeedView), object: self, userInfo: param)
    }

    public func nativeExpressAdViewPlayerDidPlayFinish(_ nativeExpressAdView: BUNativeExpressAdView, error: Error) {}

    public func nativeExpressAdSuccess(toLoad nativeExpressAd: BUNativeExpressAdManager, views: [BUNativeExpressAdView]) {
        let keys = PangleAdManager.shared.setExpressAd(views)
        invoke(code: 0, count: keys.count, data: keys)
    }

    public func nativeExpressAdView(_ nativeExpressAdView: BUNativeExpressAdView, stateDidChanged playerState: BUPlayerPlayState) {}

    public func nativeExpressAdView(_ nativeExpressAdView: BUNativeExpressAdView, dislikeWithReason filterWords: [BUDislikeWords]) {
        let param: [String: Any] = [
            "feedId": String(nativeExpressAdView.hash),
            "code": -1,
            "type": "dislike",
            "message": filterWords.description,
        ]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.kFeedView), object: self, userInfo: param)
    }

    public func nativeExpressAdViewDidCloseOtherController(_ nativeExpressAdView: BUNativeExpressAdView, interactionType: BUInteractionType) {}

    public func nativeExpressAdViewDidClick(_ nativeExpressAdView: BUNativeExpressAdView) {}

    public func nativeExpressAdViewWillShow(_ nativeExpressAdView: BUNativeExpressAdView) {}

    public func nativeExpressAdViewRenderSuccess(_ nativeExpressAdView: BUNativeExpressAdView) {}

    public func nativeExpressAdViewWillPresentScreen(_ nativeExpressAdView: BUNativeExpressAdView) {}

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
        PangleAdManager.shared.loadFeedExpressAdComplete()
    }
}
