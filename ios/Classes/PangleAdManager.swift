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
        let isExpress: Bool = args["isExpress"] as? Bool ?? false
        let loadingTypeIndex: Int = args["loadingType"] as! Int
        var loadingType = LoadingType(rawValue: loadingTypeIndex)!
        
        if loadingType == .preload || loadingType == .normal {
            let success = self.showRewardedVideoAd(isExpress)({ object in
                result(object)
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
            self.execTask(task, loadingType)({ data in
                if loadingType == .normal || loadingType == .preload_only {
                    result(data)
                }
            })
        } else {
            let task = FLTRewardedVideoAdTask(args)
            self.execTask(task, loadingType)({ data in
                if loadingType == .normal || loadingType == .preload_only {
                    result(data)
                }
            })
        }
    }
    
    public func loadFeedAd(_ args: [String: Any?], result: @escaping FlutterResult) {
        let isExpress: Bool = args["isExpress"] as? Bool ?? false
        
        if isExpress {
            let task = FLTNativeExpressAdTask(args)
            self.execTask(task)({ data in
                result(data)
            })
        } else {
            let task = FLTNativeAdTask(args)
            self.execTask(task)({ data in
                result(data)
            })
        }
    }
    
    public func loadInterstitialAd(_ args: [String: Any?], result: @escaping FlutterResult) {
        
        let task = FLTInterstitialExpressAdTask(args)
        self.execTask(task)({ data in
            result(data)
        })
    }
    
    public func loadFullscreenVideoAd(_ args: [String: Any?], result: @escaping FlutterResult) {
        let isExpress: Bool = args["isExpress"] as? Bool ?? false
        let loadingTypeIndex: Int = args["loadingType"] as! Int
        var loadingType = LoadingType(rawValue: loadingTypeIndex)!
        
        if loadingType == .preload || loadingType == .normal {
            let success = self.showFullScreenVideoAd(isExpress)({ object in
                result(object)
            })
            if success {
                if loadingType == .normal {
                    return
                }
                return
            } else {
                loadingType = .normal
            }
        }
        
        if isExpress {
            let task = FLTFullscreenVideoExpressAdTask(args)
            self.execTask(task, loadingType)({ data in
                if loadingType == .normal || loadingType == .preload_only {
                    result(data)
                }
            })
        } else {
            let task = FLTFullscreenVideoAdTask(args)
            self.execTask(task, loadingType)({ data in
                if loadingType == .normal || loadingType == .preload_only {
                    result(data)
                }
            })
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
//        if ad is BUNativeExpressRewardedVideoAd {
//            self.rewardedVideoExpressAdCollection.append(ad as! BUNativeExpressRewardedVideoAd)
//        } else if ad is BURewardedVideoAd {
//            self.rewardedVideoAdCollection.append(ad as! BURewardedVideoAd)
//        }
        if ad != nil {
            self.rewardedVideoAdCollection.append(ad!)
        }
    }
    
    public func showRewardedVideoAd(_ isExpress: Bool) -> (@escaping (Any) -> Void) -> Bool {
        return { result in
            if self.rewardedVideoAdCollection.count > 0 {
                let obj = self.rewardedVideoAdCollection[0]
                
                if obj is BURewardedVideoAd {
                    let ad = obj as! BURewardedVideoAd
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
            self.fullscreenVideoAdCollection.append(ad!)
        }
    }
    
    public func showFullScreenVideoAd(_ isExpress: Bool) -> (@escaping (Any) -> Void) -> Bool {
        return { result in
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
