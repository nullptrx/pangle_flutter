//
//  FLTNativeAdTask.swift
//  pangle_flutter
//
//  Created by nullptrX on 2020/8/16.
//

import BUAdSDK

internal final class FLTNativeAdTask: FLTTaskProtocol {
    private var manager: BUNativeAdsManager
    private var delegate: BUNativeAdsManagerDelegate?
    private var count: Int
    
    internal init(_ manager: BUNativeAdsManager, count: Int) {
        self.manager = manager
        self.count = count
    }
    
    convenience init(_ args: [String: Any?]) {
        let slotId: String = args["slotId"] as! String
        let imgSize: Int = args["imgSize"] as! Int
        let count = args["count"] as? Int ?? Constant.kDefaultFeedAdCount
        let isSupportDeepLink: Bool = args["isSupportDeepLink"] as? Bool ?? true
        
        let manager = BUNativeAdsManager()
        let slot = BUAdSlot()
        slot.id = slotId
        slot.adType = .feed
        slot.position = .feed
        slot.isSupportDeepLink = isSupportDeepLink
        slot.imgSize = BUSize(by: BUProposalSize(rawValue: imgSize)!)
        manager.adslot = slot
        
        self.init(manager, count: count)
    }
    
    func execute() -> (@escaping (FLTTaskProtocol, Any) -> Void) -> Void {
        return { result in
            let delegate = FLTNativeAd(success: { [weak self] data in
                guard let self = self else { return }
                result(self, ["code": 0, "count": data?.count ?? 0, "data": data?.map { String($0.hash) } ?? []])
            }, fail: { [weak self] error in
                guard let self = self else { return }
                let e = error as NSError?
                result(self, ["code": e?.code ?? -1, "message": error?.localizedDescription ?? "", "count": 0, "data": []])
               })
            
            self.manager.delegate = delegate
            self.delegate = delegate
            self.manager.loadAdData(withCount: self.count)
        }
    }
}
