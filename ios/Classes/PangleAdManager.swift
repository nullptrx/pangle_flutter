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
    
    private var feedAdCollection: [String: BUNativeAd] = [:]
    
    private var expressAdCollection: [String: BUNativeExpressAdView] = [:]
    
    private var rewardedVideoAdCollection: [BURewardedVideoAd] = []
    
    private var rewardedVideoExpressAdCollection: [BUNativeExpressRewardedVideoAd] = []
    
    private var taskList: [FLTTaskProtocol] = []
    
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
    
    public func loadSplashAd(_ args: [String: Any?]) {
        let isExpress: Bool = args["isExpress"] as? Bool ?? false
        
        if isExpress {
            let task = FLTSplashExpressAdTask(args)
            task.execute()({ [weak self] task, _ in
                self?.taskList.removeAll(where: { $0 === task })
                                            })
            self.taskList.append(task)
        } else {
            let task = FLTSplashAdTask(args)
            task.execute()({ [weak self] task, _ in
                self?.taskList.removeAll(where: { $0 === task })
                                  })
            self.taskList.append(task)
        }
    }
    
    public func loadRewardVideoAd(_ args: [String: Any?], result: @escaping FlutterResult) {
        let isExpress: Bool = args["isExpress"] as? Bool ?? false
        let loadingTypeIndex: Int = args["loadingType"] as! Int
        var loadingType = LoadingType(rawValue: loadingTypeIndex)!
        
        var result: FlutterResult? = result
        if loadingType == .preload || loadingType == .normal {
            let success = self.showRewardedVideoAd(isExpress)({ object in
                result?(object)
            })
            if success {
                if loadingType == .normal {
                    return
                }
            } else {
                loadingType = .normal
            }
        }
        
        if isExpress {
            let task = FLTRewardedVideoExpressAdTask(args)
            task.execute(loadingType)({ [weak self] task, object, ad in
                result?(object)
                self?.setRewardedVideoAd(ad)
                self?.taskList.removeAll(where: { $0 === task })
                                     })
            self.taskList.append(task)
        } else {
            let task = FLTRewardedVideoAdTask(args)
            task.execute(loadingType)({ [weak self] task, object, ad in
                result?(object)
                self?.setRewardedVideoAd(ad)
                self?.taskList.removeAll(where: { $0 === task })
                           })
            self.taskList.append(task)
        }
    }
    
    public func loadFeedAd(_ args: [String: Any?], result: @escaping FlutterResult) {
        let isExpress: Bool = args["isExpress"] as? Bool ?? false
        
        if isExpress {
            let task = FLTNativeExpressAdTask(args)
            task.execute()({ [weak self] task, object, views in
                result(object)
                self?.setExpressAd(views)
                self?.taskList.removeAll(where: { $0 === task })
                            })
            self.taskList.append(task)
        } else {
            let task = FLTNativeAdTask(args)
            task.execute()({ [weak self] task, object, ads in
                result(object)
                self?.setFeedAd(ads)
                self?.taskList.removeAll(where: { $0 === task })
                               })
            self.taskList.append(task)
        }
    }
    
    public func loadInterstitialAd(_ args: [String: Any?], result: @escaping FlutterResult) {
        let isExpress: Bool = args["isExpress"] as? Bool ?? false
        
        if isExpress {
            let task = FLTInterstitialExpressAdTask(args)
            task.execute()({ [weak self] task, object in
                result(object)
                self?.taskList.removeAll(where: { $0 === task })
                       })
            self.taskList.append(task)
            
        } else {
            let task = FLTInterstitialAdTask(args)
            task.execute()({ [weak self] task, object in
                result(object)
                self?.taskList.removeAll(where: { $0 === task })
            })
            self.taskList.append(task)
        }
    }
}

enum LoadingType: Int {
    case normal
    case preload
    case preload_only
}

extension PangleAdManager {
    public func setFeedAd(_ nativeAds: [BUNativeAd]?) {
        guard let nativeAds = nativeAds else {
            return
        }
        var feedAds: [String: BUNativeAd] = [:]
        for nativeAd in nativeAds {
            feedAds[String(nativeAd.hash)] = nativeAd
        }
        self.feedAdCollection.merge(feedAds, uniquingKeysWith: { _, last in last })
    }
    
    public func getFeedAd(_ key: String) -> BUNativeAd? {
        return self.feedAdCollection[key]
    }
    
    public func removeFeedAd(_ key: String?) {
        if key != nil {
            self.feedAdCollection.removeValue(forKey: key!)
        }
    }
    
    public func setExpressAd(_ nativeExpressAdViews: [BUNativeExpressAdView]?) {
        guard let nativeAds = nativeExpressAdViews else {
            return
        }
        var expressAds: [String: BUNativeExpressAdView] = [:]
        for nativeAd in nativeAds {
            expressAds[String(nativeAd.hash)] = nativeAd
        }
        self.expressAdCollection.merge(expressAds, uniquingKeysWith: { _, last in last })
    }
    
    public func getExpressAd(_ key: String) -> BUNativeExpressAdView? {
        return self.expressAdCollection[key]
    }
    
    public func removeExpressAd(_ key: String?) {
        if key != nil {
            self.expressAdCollection.removeValue(forKey: key!)
        }
    }
    
    public func setRewardedVideoAd(_ ad: NSObject?) {
        if ad is BUNativeExpressRewardedVideoAd {
            self.rewardedVideoExpressAdCollection.append(ad as! BUNativeExpressRewardedVideoAd)
        } else if ad is BURewardedVideoAd {
            self.rewardedVideoAdCollection.append(ad as! BURewardedVideoAd)
        }
    }
    
    public func showRewardedVideoAd(_ isExpress: Bool) -> (@escaping (Any) -> Void) -> Bool {
        return { result in
            if isExpress {
                if self.rewardedVideoExpressAdCollection.count > 0 {
                    let ad = self.rewardedVideoExpressAdCollection[0]
                    ad.didReceiveSuccess = { verify in
                        self.rewardedVideoExpressAdCollection.removeFirst()
                        result(["code": 0, "verify": verify])
                    }
                    ad.didReceiveFail = { error in
                        let e = error as NSError?
                        result(["code": e?.code ?? -1, "message": e?.localizedDescription ?? ""])
                    }
                    let vc = AppUtil.getVC()
                    ad.show(fromRootViewController: vc)
                    return true
                }
            } else {
                if self.rewardedVideoAdCollection.count > 0 {
                    let ad = self.rewardedVideoAdCollection[0]
                    ad.didReceiveSuccess = { verify in
                        self.rewardedVideoAdCollection.removeFirst()
                        result(["code": 0, "verify": verify])
                    }
                    ad.didReceiveFail = { error in
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
