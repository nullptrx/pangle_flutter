import Flutter
import UIKit

public class SwiftPangleFlutterPlugin: NSObject, FlutterPlugin {
    public static let kDefaultFeedAdCount = 3
    public static let kDefaultRewardAmount = 1
    public static let kDefaultFeedTag = "FeedAd"
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
            let appId: String = args["appId"] as! String
            let logLevel: Int? = args["logLevel"] as? Int
            let coppa: UInt? = args["coppa"] as? UInt
            let isPaidApp: Bool? = args["coppa"] as? Bool
            instance.initialize(appId, logLevel: logLevel, coppa: coppa, isPaidApp: isPaidApp)
            result(nil)
        case "loadSplashAd":
            let slotId: String = args["slotId"] as! String
            let tolerateTimeout: Double? = args["tolerateTimeout"] as? Double
            let hideSkipButton: Bool? = args["hideSkipButton"] as? Bool
            instance.loadSplashAd(slotId, tolerateTimeout: tolerateTimeout, hideSkipButton: hideSkipButton)
            result(nil)
        case "loadRewardVideoAd":
            let slotId: String = args["slotId"] as! String
            let userId: String = args["userId"] as? String ?? ""
            let rewardName: String? = args["rewardName"] as? String
            let rewardAmount: Int? = args["rewardAmount"] as? Int
            let extra: String? = args["extra"] as? String
            let model = BURewardedVideoModel()
            model.userId = userId
            if rewardName != nil {
                model.rewardName = rewardName
            }
            if rewardAmount != nil {
                model.rewardAmount = rewardAmount!
            }
            if extra != nil {
                model.extra = extra
            }
            instance.loadRewardVideoAd(slotId, result: result, model: model)
        case "loadFeedAd":
            let slotId: String = args["slotId"] as! String
            let imgSize: Int = args["imgSize"] as! Int
            let count = args["count"] as? Int ?? SwiftPangleFlutterPlugin.kDefaultFeedAdCount
            let tag = args["tag"] as? String ?? SwiftPangleFlutterPlugin.kDefaultFeedTag
            let isSupportDeepLink: Bool = args["isSupportDeepLink"] as? Bool ?? true
            
            instance.loadFeedAd(slotId, result: result, tag: tag, count: count, imgSize: imgSize, isSupportDeepLink: isSupportDeepLink)
            
        case "loadInterstitialAd":
            let slotId: String = args["slotId"] as! String
            let imgSize: Int = args["imgSize"] as! Int
            let isExpress: Bool = args["isExpress"] as? Bool ?? false
            if isExpress {
                instance.loadInterstitialExpressAd(slotId, result: result, imgSize: imgSize)
            } else {
                instance.loadInterstitialAd(slotId, result: result, imgSize: imgSize)
            }
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
