import Flutter
import UIKit

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
    }
    
    private let methodChannel: FlutterMethodChannel
    
    init(_ methodChannel: FlutterMethodChannel) {
        self.methodChannel = methodChannel
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let instance = PangleAdManager.shared
        let args: [String: Any?] = call.arguments as? [String: Any?] ?? [:]
        
        switch call.method {
        case "init":
            instance.initialize(args)
            result(nil)
        case "loadSplashAd":
            instance.loadSplashAd(args)
            result(nil)
        case "loadRewardVideoAd":
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
