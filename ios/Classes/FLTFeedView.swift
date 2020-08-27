//
//  FLTFeedView.swift
//  ttad
//
//  Created by Jerry on 2020/7/19.
//

import BUAdSDK
import Flutter

public class FLTFeedView: NSObject, FlutterPlatformView {
    private let methodChannel: FlutterMethodChannel
    private let container: UIView
    private var isExpress = false
    private var feedId: String?
    private let width: Float?
    private let height: Float?

    init(_ frame: CGRect, id: Int64, params: [String: Any], messenger: FlutterBinaryMessenger) {
        self.container = UIView(frame: frame)

        let channelName = String(format: "nullptrx.github.io/pangle_feedview_%ld", id)
        self.methodChannel = FlutterMethodChannel(name: channelName, binaryMessenger: messenger)

        self.feedId = params["feedId"] as? String
        self.isExpress = params["isExpress"] as? Bool ?? false
        self.width = params["width"] as? Float
        self.height = params["height"] as? Float
        super.init()

        self.methodChannel.setMethodCallHandler(self.handle(_:result:))
        if self.feedId != nil {
            if self.isExpress {
                let nad = PangleAdManager.shared.getExpressAd(self.feedId!)
                self.loadExpressAd(nad)
            } else {
                let nad = PangleAdManager.shared.getFeedAd(self.feedId!)
                self.loadAd(nad)
            }
        }
    }

    deinit {
        if self.feedId != nil {
            if self.isExpress {
                PangleAdManager.shared.removeExpressAd(self.feedId!)
            } else {
                PangleAdManager.shared.removeFeedAd(self.feedId!)
            }
        }
        removeAllView()
    }

    public func view() -> UIView {
        return self.container
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "update":
            let args: [String: Any?] = call.arguments as? [String: Any?] ?? [:]
            let feedId = args["feedId"] as? String
            let isExpress = args["isExpress"] as? Bool ?? false
            if feedId != nil {
                if isExpress {
                    let nad = PangleAdManager.shared.getExpressAd(feedId!)
                    self.loadExpressAd(nad)
                } else {
                    let nad = PangleAdManager.shared.getFeedAd(feedId!)
                    self.loadAd(nad)
                }
            }
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func invoke(width: CGFloat, height: CGFloat) {
        var params = [String: Any]()
        params["width"] = width
        params["height"] = height
        self.methodChannel.invokeMethod("update", arguments: params)
    }

    private func removeAllView() {
        self.container.subviews.forEach { $0.removeFromSuperview() }
    }

    private func disposeView() {
        self.removeAllView()
        if self.isExpress {
            PangleAdManager.shared.removeExpressAd(self.feedId)
        } else {
            PangleAdManager.shared.removeFeedAd(self.feedId)
        }

        self.methodChannel.invokeMethod("remove", arguments: nil)
        self.methodChannel.setMethodCallHandler(nil)
    }

    func loadAd(_ ad: BUNativeAd?) {
        guard let nativeAd: BUNativeAd = ad else {
            return
        }

        // TODO: 使用AppUtil.getCurrentVC()，界面刷新时获取时，得到的VC会是UIViewController, 不是FlutterViewController
//        guard let vc = AppUtil.getCurrentVC() else {
//            return
//        }

        // 1. 判断nativeAd.rootViewController是否nil, nil赋值vc, 非nil不赋值
        // 2. 使用(UIApplication.shared.delegate?.window??.rootViewController)!获取rootVC，目前没发现问题。但据说可能跳转后无法回到当前页面，有待考证

        let viewController = AppUtil.getVC()
        nativeAd.rootViewController = viewController

        nativeAd.delegate = self

        var isVideoCell = false
        let width = UIScreen.main.bounds.width
//        let width = self.container.bounds.width
//        let width: CGFloat = 340
        var height: CGFloat = 0.0
        var tabCell: BUDFeedAdBaseTableViewCell?
        switch nativeAd.data!.imageMode {
        case .adModeSmallImage:
            height = BUDFeedAdLeftTableViewCell.cellHeight(withModel: nativeAd, width: width)
            tabCell = BUDFeedAdLeftTableViewCell()
        case .adModeLargeImage, .adModeImagePortrait:
            height = BUDFeedAdLargeTableViewCell.cellHeight(withModel: nativeAd, width: width)
            tabCell = BUDFeedAdLargeTableViewCell()
        case .adModeGroupImage:
            height = BUDFeedAdGroupTableViewCell.cellHeight(withModel: nativeAd, width: width)
            tabCell = BUDFeedAdGroupTableViewCell()
        case .videoAdModeImage:
            height = BUDFeedVideoAdTableViewCell.cellHeight(withModel: nativeAd, width: width)
            tabCell = BUDFeedVideoAdTableViewCell()
            isVideoCell = true
        case .videoAdModePortrait:
            break
        default:
            break
        }
        guard let cell: BUDFeedAdBaseTableViewCell = tabCell else {
            return
        }

        let type = nativeAd.data!.interactionType
        if isVideoCell {
            let videoCell = cell as? BUDFeedVideoAdTableViewCell
            nativeAd.registerContainer(videoCell!, withClickableViews: [videoCell!.creativeButton!])
        } else {
            if type == .download {
                cell.customBtn.setTitle(String.localizedStringWithFormat(ClickDownload), for: .normal)
                nativeAd.registerContainer(cell, withClickableViews: [cell.customBtn])
            } else if type == .phone {
                cell.customBtn.setTitle(String.localizedStringWithFormat(Call), for: .normal)
                nativeAd.registerContainer(cell, withClickableViews: [cell.customBtn])
            } else if type == .URL {
                cell.customBtn.setTitle(String.localizedStringWithFormat(ExternalLink), for: .normal)
                nativeAd.registerContainer(cell, withClickableViews: [cell.customBtn])
            } else if type == .page {
                cell.customBtn.setTitle(String.localizedStringWithFormat(InternalLink), for: .normal)
                nativeAd.registerContainer(cell, withClickableViews: [cell.customBtn])
            } else {
                cell.customBtn.setTitle(String.localizedStringWithFormat(NoClick), for: .normal)
            }
        }

        self.removeAllView()
        let frame = CGRect(x: 0, y: 0, width: width, height: height)
        cell.contentView.frame = frame
        cell.frame = frame
        cell.refreshUI(withModel: nativeAd)
        self.container.frame = frame
        self.container.addSubview(cell)
        self.container.updateConstraints()

        self.invoke(width: width, height: height)
    }

    func loadExpressAd(_ ad: BUNativeExpressAdView?) {
        guard let expressAd: BUNativeExpressAdView = ad else {
            return
        }
        let size = expressAd.bounds.size
        let width = size.width
        let height = size.height
        let contentWidth = UIScreen.main.bounds.size.width
        let contentHeight = contentWidth * height / width
//        let leftPadding: CGFloat = 10
//        let expressWidth = contentWidth - 2 * leftPadding
//        let expressHeight = expressWidth * height / width

        self.removeAllView()

        let viewWidth: CGFloat
        let viewHeight: CGFloat
        if self.width != nil, self.height != nil {
            viewWidth = CGFloat(self.width!)
            viewHeight = CGFloat(self.height!)
        } else if self.width != nil {
            viewWidth = CGFloat(self.width!)
            viewHeight = viewWidth * height / width
        } else if self.height != nil {
            viewHeight = CGFloat(self.height!)
            viewWidth = viewHeight * width / height
        } else {
            viewWidth = contentWidth
            viewHeight = contentHeight
        }

        let frame = CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight)
        expressAd.frame = frame
        expressAd.center = CGPoint(x: viewWidth / 2, y: viewHeight / 2)
        let rootFrame = CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight)
        self.container.frame = rootFrame

        self.container.addSubview(expressAd)
        self.container.updateConstraints()
        self.invoke(width: viewWidth, height: viewHeight)

        expressAd.rootViewController = AppUtil.getVC()
        expressAd.didReceiveRenderSuccess = { _ in
        }
        expressAd.didReceiveRenderFail = { _, _ in
            PangleAdManager.shared.removeExpressAd(self.feedId)
            self.removeAllView()
        }
        expressAd.didReceiveDislike = { _, _ in
            self.disposeView()
        }
        expressAd.render()
    }
}

extension FLTFeedView: BUNativeAdDelegate {
    public func nativeAd(_ nativeAd: BUNativeAd, didFailWithError error: Error?) {
        self.disposeView()
    }

    public func nativeAd(_ nativeAd: BUNativeAd?, dislikeWithReason filterWords: [BUDislikeWords]?) {
        self.disposeView()
    }
}
