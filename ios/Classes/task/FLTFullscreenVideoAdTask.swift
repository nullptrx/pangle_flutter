//
//  FLTFullscreenVideoAdTask.swift
//  pangle_flutter
//
//  Created by nullptrX on 2020/8/25.
//

import BUAdSDK

internal final class FLTFullscreenVideoAdTask: FLTTaskProtocol {
    private var manager: BUFullscreenVideoAd
    private var delegate: BUFullscreenVideoAdDelegate?
    
    internal init(_ manager: BUFullscreenVideoAd) {
        self.manager = manager
    }
    
    convenience init(_ args: [String: Any?]) {
        let slotId: String = args["slotId"] as! String
        let manager = BUFullscreenVideoAd(slotID: slotId)
        self.init(manager)
    }
    
    func execute(_ loadingType: LoadingType) -> (@escaping (FLTTaskProtocol, Any, BUFullscreenVideoAd?) -> Void) -> Void {
        let preload = loadingType == .preload || loadingType == .preload_only
        
        return { result in
            let delegate = FLTFullscreenVideoAd(preload, success: { [weak self] ad in
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
