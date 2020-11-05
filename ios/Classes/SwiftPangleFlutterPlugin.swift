import Flutter
import UIKit

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
        let args: [String: Any?] = call.arguments as? [String: Any?] ?? [:]
        
        switch call.method {
        case "getSdkVersion":
            result(BUAdSDKManager.sdkVersion)
        case "init":
            instance.initialize(args)
            result(nil)
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
            instance.loadSplashAd(args, result: result)
        case "loadRewardedVideoAd":
            instance.loadRewardVideoAd(args, result: result)
        case "loadFeedAd":
            instance.loadFeedAd(args, result: result)
        case "loadInterstitialAd":
            instance.loadInterstitialAd(args, result: result)
        case "loadFullscreenVideoAd":
            instance.loadFullscreenVideoAd(args, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
