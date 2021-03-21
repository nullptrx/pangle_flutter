//
//  TTAdUtil.swift
//  Pods-Runner
//
//  Created by Jerry on 2020/7/19.
//

import BUAdSDK
import Flutter

public final class PangleAdManager: NSObject {
    public static let shared = PangleAdManager()

    private var expressAdCollection: [String: BUNativeExpressAdView] = [:]

    private var rewardedVideoAdCollection: [Any] = []

    private var fullscreenVideoAdCollection: [Any] = []

    private var taskList: [FLTTaskProtocol] = []

    fileprivate func execTask(_ task: FLTTaskProtocol, _ loadingType: LoadingType? = nil) -> (@escaping (Any) -> Void) -> Void {
        self.taskList.append(task)
        return { result in
            if loadingType == nil {
                task.execute()({ [weak self] task, data in
                    self?.taskList.removeAll(where: { $0 === task })
                    result(data)
                })
            } else {
                task.execute(loadingType!)({ [weak self] task, data in
                    self?.taskList.removeAll(where: { $0 === task })
                    result(data)
                })
            }
        }
    }

    public func initialize(_ args: [String: Any?]) {
        let appId: String = args["appId"] as! String
        let logLevel: Int? = args["logLevel"] as? Int
        let coppa: UInt? = args["coppa"] as? UInt
        let isPaidApp: Bool? = args["coppa"] as? Bool

        BUAdSDKManager.setAppID(appId)

        if isPaidApp != nil {
            BUAdSDKManager.setIsPaidApp(isPaidApp!)
        }

        if logLevel != nil {
            BUAdSDKManager.setLoglevel(BUAdSDKLogLevel(rawValue: logLevel!)!)
        }

        if coppa != nil {
            BUAdSDKManager.setCoppa(coppa!)
        }
    }

    public func loadSplashAd(_ args: [String: Any?], result: @escaping FlutterResult) {
        let isExpress: Bool = args["isExpress"] as? Bool ?? false

        if isExpress {
            let task = FLTSplashExpressAdTask(args)
            self.execTask(task)({ object in
                result(object)
            })
        } else {
            let task = FLTSplashAdTask(args)
            self.execTask(task)({ object in
                result(object)
            })
        }
    }

    public func loadRewardVideoAd(_ args: [String: Any?], result: @escaping FlutterResult) {
        let loadingTypeIndex: Int = args["loadingType"] as! Int
        let loadingType = LoadingType(rawValue: loadingTypeIndex)!

        if loadingType == .preload || loadingType == .normal {
            let success = showRewardedVideoAd(args)({ [unowned self] object in
                if loadingType == .preload {
                    loadRewardVideoAdOnly(args, loadingType: .preload_only)
                }
                result(object)
            })
            if !success {
                loadRewardVideoAdOnly(args, loadingType: .normal, result: result)
            }
        } else {
            loadRewardVideoAdOnly(args, loadingType: .preload_only, result: result)
        }

    }

    private func loadRewardVideoAdOnly(_ args: [String: Any?], loadingType: LoadingType, result: FlutterResult? = nil) {
        let task = FLTRewardedVideoExpressAdTask(args)
        execTask(task, loadingType)({ data in
            if loadingType == .normal || loadingType == .preload_only {
                result?(data)
            }
        })
    }

    public func loadFeedAd(_ args: [String: Any?], result: @escaping FlutterResult) {
        let task = FLTNativeExpressAdTask(args)
        execTask(task)({ data in
            result(data)
        })
    }

    public func loadInterstitialAd(_ args: [String: Any?], result: @escaping FlutterResult) {

        let task = FLTInterstitialExpressAdTask(args)
        execTask(task)({ data in
            result(data)
        })
    }

    public func loadFullscreenVideoAd(_ args: [String: Any?], result: @escaping FlutterResult) {
        let loadingTypeIndex: Int = args["loadingType"] as! Int
        let loadingType = LoadingType(rawValue: loadingTypeIndex)!

        if loadingType == .preload || loadingType == .normal {
            let success = showFullScreenVideoAd()({ [unowned self] object in
                if loadingType == .preload {
                    loadFullscreenVideoAdOnly(args, loadingType: .preload_only)
                }
                result(object)
            })
            if !success {
                loadFullscreenVideoAdOnly(args, loadingType: .normal, result: result)
            }
        } else {
            loadFullscreenVideoAdOnly(args, loadingType: .preload_only, result: result)
        }


    }

    private func loadFullscreenVideoAdOnly(_ args: [String: Any?], loadingType: LoadingType, result: FlutterResult? = nil) {
        let task = FLTFullscreenVideoExpressAdTask(args)
        execTask(task, loadingType)({ data in
            if loadingType == .normal || loadingType == .preload_only {
                result?(data)
            }
        })
    }
}

enum LoadingType: Int {
    case normal
    case preload
    case preload_only
}

extension PangleAdManager {

    public func setExpressAd(_ nativeExpressAdViews: [BUNativeExpressAdView]?) {
        guard let nativeAds = nativeExpressAdViews else {
            return
        }
        var expressAds: [String: BUNativeExpressAdView] = [:]
        for nativeAd in nativeAds {
            expressAds[String(nativeAd.hash)] = nativeAd
        }
        expressAdCollection.merge(expressAds, uniquingKeysWith: { _, last in last })
    }

    public func getExpressAd(_ key: String) -> BUNativeExpressAdView? {
        expressAdCollection[key]
    }

    public func removeExpressAd(_ key: String?) -> Bool {
        if key != nil {
            let value = expressAdCollection.removeValue(forKey: key!)
            return value != nil
        }
        return false
    }

    public func setRewardedVideoAd(_ ad: NSObject?) {
        if ad != nil {
            rewardedVideoAdCollection.append(ad!)
        }
    }

    public func showRewardedVideoAd(_ args: [String: Any?]) -> (@escaping (Any) -> Void) -> Bool {
        { result in
            if self.rewardedVideoAdCollection.count > 0 {
                let obj = self.rewardedVideoAdCollection[0]

                if obj is BURewardedVideoAd {
                    let ad = obj as! BURewardedVideoAd
                    ad.didReceiveSuccess = { [unowned self] verify in
                        self.rewardedVideoAdCollection.removeFirst()
                        result(["code": 0, "verify": verify])
                    }
                    ad.didReceiveFail = { error in
                        self.rewardedVideoAdCollection.removeFirst()
                        let e = error as NSError?
                        result(["code": e?.code ?? -1, "message": e?.localizedDescription ?? ""])
                    }
                    let vc = AppUtil.getVC()
                    ad.show(fromRootViewController: vc)
                } else if obj is BUNativeExpressRewardedVideoAd {
                    let ad = obj as! BUNativeExpressRewardedVideoAd
                    ad.didReceiveSuccess = { verify in
                        self.rewardedVideoAdCollection.removeFirst()
                        result(["code": 0, "verify": verify])
                    }
                    ad.didReceiveFail = { error in
                        self.rewardedVideoAdCollection.removeFirst()
                        let e = error as NSError?
                        result(["code": e?.code ?? -1, "message": e?.localizedDescription ?? ""])
                    }
                    let vc = AppUtil.getVC()
                    ad.show(fromRootViewController: vc)
                    return true
                }
            }

            return false
        }
    }

    public func setFullScreenVideoAd(_ ad: NSObject?) {
        if ad != nil {
            fullscreenVideoAdCollection.append(ad!)
        }
    }

    public func showFullScreenVideoAd() -> (@escaping (Any) -> Void) -> Bool {
        { result in
            if self.fullscreenVideoAdCollection.count > 0 {
                let obj = self.fullscreenVideoAdCollection[0]

                if obj is BUFullscreenVideoAd {
                    let ad = obj as! BUFullscreenVideoAd
                    ad.didReceiveSuccess = {
                        self.fullscreenVideoAdCollection.removeFirst()
                        result(["code": 0])
                    }
                    ad.didReceiveFail = { error in
                        self.fullscreenVideoAdCollection.removeFirst()
                        let e = error as NSError?
                        result(["code": e?.code ?? -1, "message": e?.localizedDescription ?? ""])
                    }
                    let vc = AppUtil.getVC()
                    ad.show(fromRootViewController: vc)
                } else if obj is BUNativeExpressFullscreenVideoAd {
                    let ad = obj as! BUNativeExpressFullscreenVideoAd
                    ad.didReceiveSuccess = {
                        self.fullscreenVideoAdCollection.removeFirst()
                        result(["code": 0])
                    }
                    ad.didReceiveFail = { error in
                        self.fullscreenVideoAdCollection.removeFirst()
                        let e = error as NSError?
                        result(["code": e?.code ?? -1, "message": e?.localizedDescription ?? ""])
                    }
                    let vc = AppUtil.getVC()
                    ad.show(fromRootViewController: vc)
                    return true
                }
            }

            return false
        }
    }
}
