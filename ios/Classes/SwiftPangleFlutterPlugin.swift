import Flutter
import UIKit
import BUAdSDK

#if canImport(AppTrackingTransparency)
import AppTrackingTransparency
#endif
#if canImport(AdSupport)
import AdSupport
#endif

public class SwiftPangleFlutterPlugin: NSObject, FlutterPlugin {
    public static let kDefaultFeedAdCount = 3
    public static let kDefaultRewardAmount = 1
    public static let kDefaultSplashTimeout = 3000

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "nullptrx.github.io/pangle", binaryMessenger: registrar.messenger())
        let instance = SwiftPangleFlutterPlugin(channel)
        registrar.addMethodCallDelegate(instance, channel: channel)

        let bannerViewFactory = BannerViewFactory(messenger: registrar.messenger())
        registrar.register(bannerViewFactory, withId: "nullptrx.github.io/pangle_bannerview")

        let feedViewFactory = FeedViewFactory(messenger: registrar.messenger())
        registrar.register(feedViewFactory, withId: "nullptrx.github.io/pangle_feedview")

        let splashViewFactory = SplashViewFactory(messenger: registrar.messenger())
        registrar.register(splashViewFactory, withId: "nullptrx.github.io/pangle_splashview")
    }

    private let methodChannel: FlutterMethodChannel

    init(_ methodChannel: FlutterMethodChannel) {
        self.methodChannel = methodChannel
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let instance = PangleAdManager.shared

        switch call.method {
        case "getSdkVersion":
            result(BUAdSDKManager.sdkVersion)
        case "init":
            let args: [String: Any?] = call.arguments as? [String: Any?] ?? [:]
            instance.initialize(args)
            result(["code": 0, "message": ""])
        case "getTrackingAuthorizationStatus":
            if #available(iOS 14.0, *) {
                result(ATTrackingManager.trackingAuthorizationStatus.rawValue)
            } else {
                result(nil)
            }
        case "requestTrackingAuthorization":
            /// 适配App Tracking Transparency（ATT）
            if #available(iOS 14.0, *) {
                ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
                    result(status.rawValue)
                })
            } else {
                result(nil)
            }
        case "loadSplashAd":
            let args: [String: Any?] = call.arguments as? [String: Any?] ?? [:]
            instance.loadSplashAd(args, result: result)
        case "loadRewardedVideoAd":
            let args: [String: Any?] = call.arguments as? [String: Any?] ?? [:]
            instance.loadRewardVideoAd(args, result: result)
        case "loadFeedAd":
            let args: [String: Any?] = call.arguments as? [String: Any?] ?? [:]
            instance.loadFeedAd(args, result: result)
        case "removeFeedAd":
            let args: [String] = call.arguments as? [String] ?? []
            var count = 0
            for arg in args {
                let success = instance.removeExpressAd(arg)
                if success {
                    count += 1
                }
            }
            result(count)
        case "loadInterstitialAd":
            let args: [String: Any?] = call.arguments as? [String: Any?] ?? [:]
            instance.loadInterstitialAd(args, result: result)
        case "loadFullscreenVideoAd":
            let args: [String: Any?] = call.arguments as? [String: Any?] ?? [:]
            instance.loadFullscreenVideoAd(args, result: result)
        case "getThemeStatus":
            result(BUAdSDKManager.themeStatus().rawValue)
        case "setThemeStatus":
            let value: Int = call.arguments as? Int ?? 0
            let status: BUAdSDKThemeStatus = BUAdSDKThemeStatus.init(rawValue: value) ?? .normal
            BUAdSDKManager.setThemeStatus(status)
            result(BUAdSDKManager.themeStatus().rawValue)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
