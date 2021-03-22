//
//  FLTRewardedVideoExpressAdTask.swift
//  pangle_flutter
//
//  Created by nullptrX on 2020/8/16.
//

import BUAdSDK

internal final class FLTRewardedVideoExpressAdTask: FLTTaskProtocol {
    private var manager: BUNativeExpressRewardedVideoAd
    private var delegate: BUNativeExpressRewardedVideoAdDelegate?
    private var slotId: String = ""

    internal init(_ manager: BUNativeExpressRewardedVideoAd) {
        self.manager = manager
    }

    init(_ args: [String: Any?]) {
        slotId = args["slotId"] as! String
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
        let manager = BUNativeExpressRewardedVideoAd(slotID: slotId, rewardedVideoModel: model)
        self.manager = manager
    }

    func execute(_ loadingType: LoadingType) -> (@escaping (FLTTaskProtocol, Any) -> Void) -> Void {
        { [unowned self]result in
            let delegate = FLTRewardedVideoExpressAd(slotId, loadingType, success: { [weak self] verify in
                guard let self = self else {
                    return
                }
                result(self, ["code": 0, "verify": verify])
            }, fail: { [weak self] error in
                guard let self = self else {
                    return
                }
                let e = error as NSError?
                result(self, ["code": e?.code ?? -1, "message": error?.localizedDescription ?? ""])
            })

            manager.delegate = delegate
            self.delegate = delegate

            manager.loadData()
        }
    }
}
