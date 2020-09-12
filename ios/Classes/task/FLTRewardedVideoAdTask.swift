//
//  FLTRewardedVideoAdTask.swift
//  pangle_flutter
//
//  Created by nullptrX on 2020/8/16.
//

import BUAdSDK

internal final class FLTRewardedVideoAdTask: FLTTaskProtocol {
    private var manager: BURewardedVideoAd
    private var delegate: BURewardedVideoAdDelegate?
    
    internal init(_ manager: BURewardedVideoAd) {
        self.manager = manager
    }
    
    convenience init(_ args: [String: Any?]) {
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
        let manager = BURewardedVideoAd(slotID: slotId, rewardedVideoModel: model)
        self.init(manager)
    }
    
    func execute(_ loadingType: LoadingType) -> (@escaping (FLTTaskProtocol, Any) -> Void) -> Void {
        return { result in
            let delegate = FLTRewardedVideoAd(loadingType, success: { [weak self] verify in
                guard let self = self else { return }
                result(self, ["code": 0, "verify": verify])
            }, fail: { [weak self] error in
                guard let self = self else { return }
                let e = error as NSError?
                result(self, ["code": e?.code ?? -1, "message": error?.localizedDescription ?? ""])
               })
            
            self.manager.delegate = delegate
            self.delegate = delegate
            
            self.manager.loadData()
        }
    }
}
