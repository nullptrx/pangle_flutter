//
//  FLTSplashAdTask.swift
//  pangle_flutter
//
//  Created by nullptrX on 2020/8/16.
//

import BUAdSDK

internal final class FLTSplashAdTask: FLTTaskProtocol {
    private var manager: BUSplashAd
    private var delegate: BUSplashAdDelegate?

    internal init(_ manager: BUSplashAd) {
        self.manager = manager
    }

    convenience init(_ args: [String: Any?]) {
        let slotId: String = args["slotId"] as! String
        let tolerateTimeout: Double? = args["tolerateTimeout"] as? Double
        let hideSkipButton: Bool? = args["hideSkipButton"] as? Bool
        let screenSize = UIScreen.main.bounds.size
        let adSize: CGSize
        if let sizeMap = args["expressSize"] as? [String: Any],
           let w = sizeMap["width"] as? Double, w > 0,
           let h = sizeMap["height"] as? Double, h > 0 {
            adSize = CGSize(width: w, height: h)
        } else {
            adSize = screenSize
        }
        let splashAd = BUSplashAd(slotID: slotId, adSize: adSize)
        if let tolerateTimeout = tolerateTimeout {
            splashAd.tolerateTimeout = tolerateTimeout
        }
        if let hideSkipButton = hideSkipButton {
            splashAd.hideSkipButton = hideSkipButton
        }

        self.init(splashAd)
    }

    func execute() -> (@escaping (FLTTaskProtocol, Any) -> Void) -> Void {
        return { result in
            let vc = AppUtil.getVC()
            let delegate = FLTSplashAd(success: { [weak self] msg, type in
                guard let self = self else { return }
                result(self, ["code": 0, "message": msg, "type": type] as [String:Any])
            }, fail: { [weak self] error in
                guard let self = self else { return }
                let e = error as NSError?
                result(self, ["code": e?.code ?? -1, "message": error?.localizedDescription ?? "", "type": 0] as [String:Any])
            }, rootViewController: vc)

            self.manager.delegate = delegate
            self.delegate = delegate

            // 只调用 loadAdData()，showSplashView 在 splashAdLoadSuccess 回调中执行
            self.manager.loadData()
        }
    }
}
