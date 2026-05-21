//
//  TTAdUtil.swift
//  Pods-Runner
//
//  Created by Jerry on 2020/7/19.
//

import BUAdSDK
import Flutter

// MARK: - Cached ad wrappers

/// Wraps a cached ad object with a timestamp so we can reject stale entries.
/// A conservative 30-minute TTL is applied uniformly (the iOS Pangle SDK does not
/// expose an expiration timestamp like the Android SDK does).
private struct CachedVideoAd {
    let ad: NSObject
    let loadedAt: Date

    init(_ ad: NSObject) {
        self.ad = ad
        self.loadedAt = Date()
    }

    var isExpired: Bool {
        Date().timeIntervalSince(loadedAt) > 1800
    }
}

/// Wraps a native express ad view with a TTL, mirroring CachedVideoAd.
/// Without this, express ads could sit in the cache indefinitely and render blank
/// or trigger internal SDK errors when finally consumed.
private struct CachedExpressAd {
    let view: BUNativeExpressAdView
    let loadedAt: Date

    init(_ view: BUNativeExpressAdView) {
        self.view = view
        self.loadedAt = Date()
    }

    var isExpired: Bool {
        Date().timeIntervalSince(loadedAt) > 1800
    }
}

// MARK: - PangleAdManager

public final class PangleAdManager: NSObject {
    public static let shared = PangleAdManager()

    // Serial queue that serialises all reads and writes to the three ad caches and
    // taskList, preventing data races between BUAdSDK background callbacks and
    // Flutter method-channel calls on the main thread.
    private let adQueue = DispatchQueue(label: "io.github.nullptrx.pangle.admanager")

    // keyed by BUNativeExpressAdView.hash
    private var expressAdCollection: [String: CachedExpressAd] = [:]

    private var rewardedVideoAdData: [String: [CachedVideoAd]] = [:]

    private var fullscreenVideoAdData: [String: [CachedVideoAd]] = [:]

    private var taskList: [FLTTaskProtocol] = []

    fileprivate func execTask(_ task: FLTTaskProtocol, _ loadingType: LoadingType? = nil) -> (@escaping (Any) -> Void) -> Void {
        adQueue.sync { self.taskList.append(task) }
        return { result in
            if loadingType == nil {
                task.execute()({ [weak self] task, data in
                    self?.adQueue.async { self?.taskList.removeAll(where: { $0 === task }) }
                    result(data)
                })
            } else {
                task.execute(loadingType!)({ [weak self] task, data in
                    self?.adQueue.async { self?.taskList.removeAll(where: { $0 === task }) }
                    result(data)
                })
            }
        }
    }

    public func initialize(_ args: [String: Any?], _ result: @escaping FlutterResult) {
        let appId: String = args["appId"] as! String
        let logLevel: Int? = args["logLevel"] as? Int
        let idfa: String? = args["idfa"] as? String

        let config = BUAdSDKConfiguration.configuration()

        config.appID = appId
        if let logLevel = logLevel {
            config.debugLog = NSNumber(value: logLevel == 0 ? 0 : 1)
        }

        if let idfa = idfa {
            config.customIdfa = idfa
        }

        config.appLogoImage = UIImage(named: "AppIcon")
        if let useMediation = args["useMediation"] as? Bool {
            config.useMediation = useMediation
        }

        BUAdSDKManager.start(asyncCompletionHandler: { success, error in
            DispatchQueue.main.async {
                if success {
                    result(["code": 0, "message": ""] as [String: Any])
                } else {
                    let e = error as NSError?
                    result(["code": e?.code ?? -1, "message": e?.localizedDescription ?? ""] as [String: Any])
                }
            }
        })

    }

    public func loadSplashAd(_ args: [String: Any?], result: @escaping FlutterResult) {
        let task = FLTSplashAdTask(args)
        self.execTask(task)({ object in
            result(object)
        })
    }

    public func loadRewardVideoAd(_ args: [String: Any?], result: @escaping FlutterResult) {
        let loadingTypeIndex: Int = args["loadingType"] as! Int
        let loadingType = LoadingType(rawValue: loadingTypeIndex) ?? .normal

        if loadingType == .preload || loadingType == .normal {
            let success = showRewardedVideoAd(args)({ [weak self] object in
                if loadingType == .preload {
                    self?.loadRewardVideoAdOnly(args, loadingType: .preload_only)
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
        result(FlutterMethodNotImplemented)
    }

    public func loadDrawAd(_ args: [String: Any?], result: @escaping FlutterResult) {
        let task = FLTDrawExpressAdTask(args)
        execTask(task)({ data in
            result(data)
        })
    }

    public func loadStreamAd(_ args: [String: Any?], result: @escaping FlutterResult) {
        guard let slotId = args["slotId"] as? String, !slotId.isEmpty else {
            result(["code": -1, "message": "slotId missing", "count": 0, "data": []] as [String: Any])
            return
        }
        let count = args["adCount"] as? Int ?? 1

        let slot = BUAdSlot()
        slot.id = slotId
        slot.adType = .feed
        if let imgArgs = args["imgSize"] as? [String: Double],
           let w = imgArgs["width"], let h = imgArgs["height"]
        {
            let buSize = BUSize()
            buSize.width = Int(w)
            buSize.height = Int(h)
            slot.imgSize = buSize
        }

        let manager = BUNativeAdsManager(slot: slot)
        let delegate = FLTStreamAdDelegate(
            manager: manager,
            success: { ads in
                let data: [[String: Any?]] = ads.map { ad in
                    let meta = ad.data
                    let imageUrl = meta?.imageAry?.first?.imageURL
                    return [
                        "id": String(ad.hash),
                        "imageMode": meta?.imageMode.rawValue ?? 0,
                        "videoUrl": meta?.videoUrl,
                        "videoDuration": Double(meta?.videoDuration ?? 0),
                        "imageUrl": imageUrl,
                        "title": meta?.adTitle,
                        "description": meta?.adDescription,
                    ]
                }
                result(["code": 0, "message": "", "count": data.count, "data": data] as [String: Any])
            },
            fail: { error in
                let e = error as NSError?
                result(["code": e?.code ?? -1, "message": error?.localizedDescription ?? "", "count": 0, "data": []] as [String: Any])
            }
        )
        delegate.onComplete = { [weak self] d in
            self?.adQueue.async { self?.taskList.removeAll(where: { $0 === d }) }
        }
        manager.delegate = delegate
        adQueue.async { self.taskList.append(delegate) }
        manager.loadAdData(withCount: count)
    }

    public func loadFullscreenVideoAd(_ args: [String: Any?], result: @escaping FlutterResult) {
        let loadingTypeIndex: Int = args["loadingType"] as! Int
        let loadingType = LoadingType(rawValue: loadingTypeIndex) ?? .normal

        if loadingType == .preload || loadingType == .normal {
            let success = showFullScreenVideoAd(args)({ [weak self] object in
                if loadingType == .preload {
                    self?.loadFullscreenVideoAdOnly(args, loadingType: .preload_only)
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

// MARK: - Ad cache operations

extension PangleAdManager {

    // MARK: Express (native feed / banner)

    /// Called from BUAdSDK background threads — protected by adQueue.
    public func setExpressAd(_ nativeExpressAdViews: [BUNativeExpressAdView]?) {
        guard let nativeAds = nativeExpressAdViews else { return }
        adQueue.async {
            for nativeAd in nativeAds {
                self.expressAdCollection[String(nativeAd.hash)] = CachedExpressAd(nativeAd)
            }
        }
    }

    /// Returns nil when the key is unknown or the cached view has expired.
    public func getExpressAd(_ key: String) -> BUNativeExpressAdView? {
        adQueue.sync {
            guard let cached = expressAdCollection[key] else { return nil }
            if cached.isExpired {
                expressAdCollection.removeValue(forKey: key)
                return nil
            }
            return cached.view
        }
    }

    @discardableResult
    public func removeExpressAd(_ key: String?) -> Bool {
        guard let key = key else { return false }
        return adQueue.sync {
            expressAdCollection.removeValue(forKey: key) != nil
        }
    }

    // MARK: Rewarded video

    /// Called from BUAdSDK background threads — protected by adQueue.
    public func setRewardedVideoAd(_ slotId: String, _ ad: NSObject?) {
        guard let ad = ad else { return }
        adQueue.async {
            var data = self.rewardedVideoAdData[slotId] ?? []
            data.append(CachedVideoAd(ad))
            self.rewardedVideoAdData[slotId] = data
        }
    }

    /// 查询指定广告位是否有未过期的激励视频缓存广告
    public func hasRewardedVideoAd(_ slotId: String) -> Bool {
        return adQueue.sync {
            var data = rewardedVideoAdData[slotId] ?? []
            data.removeAll(where: { $0.isExpired })
            rewardedVideoAdData[slotId] = data
            return !data.isEmpty
        }
    }

    public func showRewardedVideoAd(_ args: [String: Any?]) -> (@escaping (Any) -> Void) -> Bool {
        { [self] result in
            let slotId: String = args["slotId"] as! String

            // Pull and clean the queue under the lock; extract the ad reference.
            let adToShow: BUNativeExpressRewardedVideoAd? = adQueue.sync {
                var data = rewardedVideoAdData[slotId] ?? []
                data.removeAll(where: { $0.isExpired })
                rewardedVideoAdData[slotId] = data
                return data.first?.ad as? BUNativeExpressRewardedVideoAd
            }

            guard let ad = adToShow else { return false }

            // Fix: closures read live data from the dict instead of a captured
            // stale local copy, preventing newly-preloaded ads from being lost.
            ad.didReceiveSuccess = { [weak self] verify in
                guard let self = self else { return }
                self.adQueue.async {
                    var live = self.rewardedVideoAdData[slotId] ?? []
                    if !live.isEmpty { live.removeFirst() }
                    self.rewardedVideoAdData[slotId] = live
                }
                result(["code": 0, "verify": verify] as [String: Any])
            }
            ad.didReceiveFail = { [weak self] error in
                guard let self = self else { return }
                self.adQueue.async {
                    var live = self.rewardedVideoAdData[slotId] ?? []
                    if !live.isEmpty { live.removeFirst() }
                    self.rewardedVideoAdData[slotId] = live
                }
                let e = error as NSError?
                result(["code": e?.code ?? -1, "message": e?.localizedDescription ?? ""] as [String: Any])
            }

            let vc = AppUtil.getVC()
            ad.show(fromRootViewController: vc)
            return true
        }
    }

    // MARK: Fullscreen video

    /// Called from BUAdSDK background threads — protected by adQueue.
    public func setFullScreenVideoAd(_ slotId: String, _ ad: NSObject?) {
        guard let ad = ad else { return }
        adQueue.async {
            var data = self.fullscreenVideoAdData[slotId] ?? []
            data.append(CachedVideoAd(ad))
            self.fullscreenVideoAdData[slotId] = data
        }
    }

    /// 查询指定广告位是否有未过期的全屏视频缓存广告
    public func hasFullscreenVideoAd(_ slotId: String) -> Bool {
        return adQueue.sync {
            var data = fullscreenVideoAdData[slotId] ?? []
            data.removeAll(where: { $0.isExpired })
            fullscreenVideoAdData[slotId] = data
            return !data.isEmpty
        }
    }

    public func showFullScreenVideoAd(_ args: [String: Any?]) -> (@escaping (Any) -> Void) -> Bool {
        { [self] result in
            let slotId: String = args["slotId"] as! String

            let adToShow: BUNativeExpressFullscreenVideoAd? = adQueue.sync {
                var data = fullscreenVideoAdData[slotId] ?? []
                data.removeAll(where: { $0.isExpired })
                fullscreenVideoAdData[slotId] = data
                return data.first?.ad as? BUNativeExpressFullscreenVideoAd
            }

            guard let ad = adToShow else { return false }

            ad.didReceiveSuccess = { [weak self] in
                guard let self = self else { return }
                self.adQueue.async {
                    var live = self.fullscreenVideoAdData[slotId] ?? []
                    if !live.isEmpty { live.removeFirst() }
                    self.fullscreenVideoAdData[slotId] = live
                }
                result(["code": 0])
            }
            ad.didReceiveFail = { [weak self] error in
                guard let self = self else { return }
                self.adQueue.async {
                    var live = self.fullscreenVideoAdData[slotId] ?? []
                    if !live.isEmpty { live.removeFirst() }
                    self.fullscreenVideoAdData[slotId] = live
                }
                let e = error as NSError?
                result(["code": e?.code ?? -1, "message": e?.localizedDescription ?? ""] as [String: Any])
            }

            let vc = AppUtil.getVC()
            ad.show(fromRootViewController: vc)
            return true
        }
    }
}
