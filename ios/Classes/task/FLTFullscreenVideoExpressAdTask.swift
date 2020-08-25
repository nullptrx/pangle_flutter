//
//  FLTFullscreenVideoExpressAdTask.swift
//  pangle_flutter
//
//  Created by nullptrX on 2020/8/25.
//

import BUAdSDK

internal final class FLTFullscreenVideoExpressAdTask: FLTTaskProtocol {
    private var manager: BUNativeExpressFullscreenVideoAd
    private var delegate: BUNativeExpressFullscreenVideoAdDelegate?
    
    internal init(_ manager: BUNativeExpressFullscreenVideoAd) {
        self.manager = manager
    }
    
    convenience init(_ args: [String: Any?]) {
        let slotId: String = args["slotId"] as! String
        let manager = BUNativeExpressFullscreenVideoAd(slotID: slotId)
        self.init(manager)
    }
    
    func execute(_ loadingType: LoadingType) -> (@escaping (FLTTaskProtocol, Any, BUNativeExpressFullscreenVideoAd?) -> Void) -> Void {
        let preload = loadingType == .preload || loadingType == .preload_only
        
        return { result in
            let delegate = FLTFullscreenVideoExpressAd(preload, success: { [weak self] ad in
                guard let self = self else { return }
                result(self, ["code": 0], ad)
            }, fail: { [weak self] _, error in
                guard let self = self else { return }
                let e = error as NSError?
                result(self, ["code": e?.code ?? -1, "message": error?.localizedDescription ?? ""], nil)
               })
            
            self.manager.delegate = delegate
            self.delegate = delegate
            
            self.manager.loadData()
        }
    }
}
