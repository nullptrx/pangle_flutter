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
    private var adCell: BUDFeedAdBaseTableViewCell?
    private var feedId: String?

    init(_ frame: CGRect, id: Int64, params: [String: Any], messenger: FlutterBinaryMessenger) {
        self.container = UIView(frame: frame)

        let channelName = String(format: "nullptrx.github.io/pangle_feedview_%ld", id)
        self.methodChannel = FlutterMethodChannel(name: channelName, binaryMessenger: messenger)

        super.init()

        self.methodChannel.setMethodCallHandler(self.handle(_:result:))

        let feedId = params["feedId"] as? String
        self.feedId = feedId
        if feedId != nil {
            let nad = PangleAdManager.shared.getFeedAd(feedId!)
            self.loadAd(nad)
        }
    }

    public func view() -> UIView {
        return self.container
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "update":
            guard let cell: BUDFeedAdBaseTableViewCell = self.adCell else {
                result(nil)
                return
            }

            let width = UIScreen.main.bounds.width
            //        let width = self.container.bounds.width
            //        let width: CGFloat = 340
            var height: CGFloat = 0.0
            let nad = cell.nativeAd
            if cell is BUDFeedAdLeftTableViewCell {
                height = BUDFeedAdLeftTableViewCell.cellHeight(withModel: nad, width: width)
            } else if cell is BUDFeedAdLargeTableViewCell {
                height = BUDFeedAdLargeTableViewCell.cellHeight(withModel: nad, width: width)
            } else if cell is BUDFeedAdGroupTableViewCell {
                height = BUDFeedAdGroupTableViewCell.cellHeight(withModel: nad, width: width)
            } else if cell is BUDFeedVideoAdTableViewCell {
                height = BUDFeedVideoAdTableViewCell.cellHeight(withModel: nad, width: width)
            }
            let frame = CGRect(x: 0, y: 0, width: width, height: height)
            cell.contentView.frame = frame
            cell.frame = frame
            cell.refreshUI(withModel: cell.nativeAd)
            self.container.frame = frame
            self.container.updateConstraints()
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    func loadAd(_ ad: BUNativeAd?) {
        guard let nativeAd: BUNativeAd = ad else {
            return
        }
        
        // TODO 使用AppUtil.getCurrentVC()，界面刷新时获取时，得到的VC会是UIViewController, 不是FlutterViewController
//        guard let vc = AppUtil.getCurrentVC() else {
//            return
//        }
        
        // 1. 判断nativeAd.rootViewController是否nil, nil赋值vc, 非nil不赋值
        // 2. 使用(UIApplication.shared.delegate?.window??.rootViewController)!获取rootVC，目前没发现问题。但据说可能跳转后无法回到当前页面，有待考证
        
        
        let viewController: UIViewController = (UIApplication.shared.delegate?.window??.rootViewController)!
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
            videoCell!.nativeAdRelatedView.videoAdView?.delegate = self
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

        self.adCell = cell
        let frame = CGRect(x: 0, y: 0, width: width, height: height)
        cell.contentView.frame = frame
        cell.frame = frame
        cell.refreshUI(withModel: nativeAd)
        self.container.frame = frame
        self.container.addSubview(cell)
        self.container.updateConstraints()

        self.invoke(width: width, height: height)
    }

    private func invoke(width: CGFloat, height: CGFloat) {
        var params = [String: Any]()
        params["width"] = width
        params["height"] = height
        self.methodChannel.invokeMethod("update", arguments: params)
    }
}

extension FLTFeedView: BUVideoAdViewDelegate {
    public func videoAdViewDidClick(_ videoAdView: BUVideoAdView) {}

    public func videoAdViewFinishViewDidClick(_ videoAdView: BUVideoAdView) {}

    public func videoAdView(_ videoAdView: BUVideoAdView, didLoadFailWithError error: Error?) {}

    public func videoAdView(_ videoAdView: BUVideoAdView, stateDidChanged playerState: BUPlayerPlayState) {}

    public func videoAdViewDidCloseOtherController(_ videoAdView: BUVideoAdView, interactionType: BUInteractionType) {}
}

extension FLTFeedView: BUNativeAdDelegate {
    public func nativeAdDidLoad(_ nativeAd: BUNativeAd) {}

    public func nativeAdDidBecomeVisible(_ nativeAd: BUNativeAd) {}

    public func nativeAdDidClick(_ nativeAd: BUNativeAd, with view: UIView?) {}

    public func nativeAd(_ nativeAd: BUNativeAd, didFailWithError error: Error?) {}

    public func nativeAd(_ nativeAd: BUNativeAd?, dislikeWithReason filterWords: [BUDislikeWords]?) {
        self.methodChannel.invokeMethod("remove", arguments: nil)

        if self.feedId != nil {
            PangleAdManager.shared.removeFeedAd(self.feedId!)
        }
//        self.removeView()
    }

    public func nativeAdDidCloseOtherController(_ nativeAd: BUNativeAd, interactionType: BUInteractionType) {}

    public func removeView() {
        self.adCell?.removeFromSuperview()
        self.adCell = nil
    }
}
