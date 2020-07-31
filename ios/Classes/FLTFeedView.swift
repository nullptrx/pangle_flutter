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
    private var methodResult: FlutterResult?
    private let container: UIView
    private var adCell: BUDFeedAdBaseTableViewCell?

    init(_ frame: CGRect, id: Int64, params: [String: Any?], messenger: FlutterBinaryMessenger) {
        self.container = UIView(frame: frame)
//        let width = params["width"] as? Double ?? 0
//        let height = params["height"] as? Double ?? 0

        let channelName = String(format: "nullptrx.github.io/pangle_feedview_%ld", id)
        self.methodChannel = FlutterMethodChannel(name: channelName, binaryMessenger: messenger)
        super.init()
        self.methodChannel.setMethodCallHandler(self.handle(_:result:))
    }

    public func view() -> UIView {
        return self.container
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "load", "reload":
            self.methodResult = result
            let args = call.arguments as? [String: Any?] ?? [:]
            let tag = args["tag"] as? String ?? SwiftPangleFlutterPlugin.kDefaultFeedTag

            let nad = PangleAdManager.shared.getFeedAd(tag)
            self.loadAd(nad)
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
        guard let vc = AppUtil.getCurrentVC() else {
            self.invoke()
            return
        }
        guard let nativeAd: BUNativeAd = ad else {
            self.invoke()
            return
        }

        nativeAd.rootViewController = vc
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
            self.invoke()
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

    private func invoke(message: String? = "") {
        guard let result = self.methodResult else {
            return
        }

        let params = NSMutableDictionary()
        params["success"] = false
        params["message"] = message
        result(params)
        self.methodResult = nil
    }

    private func invoke(width: CGFloat, height: CGFloat) {
        guard let result: FlutterResult = self.methodResult else {
            return
        }
        var params = [String: Any?]()
        params["success"] = true
        params["width"] = width
        params["height"] = height
        result(params)
        self.methodResult = nil
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
        self.adCell?.removeFromSuperview()
        self.adCell = nil
        self.methodChannel.invokeMethod("remove", arguments: nil)
    }

    public func nativeAdDidCloseOtherController(_ nativeAd: BUNativeAd, interactionType: BUInteractionType) {}
}
