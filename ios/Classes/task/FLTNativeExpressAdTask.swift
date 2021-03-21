//
//  FLTNativeExpressAdTask.swift
//  pangle_flutter
//
//  Created by nullptrX on 2020/8/16.
//

import BUAdSDK
import Foundation

internal final class FLTNativeExpressAdTask: FLTTaskProtocol {
    public let manager: BUNativeExpressAdManager
    private var delegate: FLTNativeExpressAdViewDelegate?
    private var count: Int
    
    internal init(manager: BUNativeExpressAdManager, count: Int) {
        self.manager = manager
        self.count = count
    }
    
    convenience init(_ args: [String: Any?]) {
        let slotId: String = args["slotId"] as! String
        let count = args["count"] as? Int ?? Constant.kDefaultFeedAdCount
        
        let expressArgs = args["expressSize"] as! [String: Double]
        let width = expressArgs["width"]!
        let height = expressArgs["height"]!

        let adSize = CGSize(width: width, height: height)
        
        let slot = BUAdSlot()
        slot.id = slotId
        slot.adType = .feed
        slot.position = .feed

        let nad = BUNativeExpressAdManager(slot: slot, adSize: adSize)
        nad.adSize = adSize
        
        self.init(manager: nad, count: count)
    }
    
    func execute() -> (@escaping (FLTTaskProtocol, Any) -> Void) -> Void {
        return { result in
            let delegate = FLTNativeExpressAdViewDelegate(success: { [weak self] data in
                guard let self = self else { return }
                result(self, ["code": 0, "count": data.count, "data": data])
            }, fail: { [weak self] error in
                guard let self = self else { return }
                let e = error as NSError?
                result(self, ["code": e?.code ?? -1, "message": error?.localizedDescription ?? "", "count": 0, "data": []])
            })
            
            self.manager.delegate = delegate
            self.delegate = delegate
            
            self.manager.loadAd(self.count)
        }
    }
    
}
