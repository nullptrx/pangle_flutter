//
//  FLTInterstitialAdTask.swift
//  pangle_flutter
//
//  Created by nullptrX on 2020/8/16.
//

import Foundation

internal final class FLTInterstitialAdTask: FLTTaskProtocol {
    private var manager: BUInterstitialAd
    private var delegate: BUInterstitialAdDelegate?
    
    internal init(_ manager: BUInterstitialAd) {
        self.manager = manager
    }
    
    convenience init(_ args: [String: Any?]) {
        let slotId: String = args["slotId"] as! String
        let imgSize: Int = args["imgSize"] as! Int
        let size = BUSize(by: BUProposalSize(rawValue: imgSize)!)!
        
//        let width = Double(UIScreen.main.bounds.width) * 0.9
//        let height = width / Double(size.width) * Double(size.height)
        let manager = BUInterstitialAd(slotID: slotId, size: size)
        self.init(manager)
    }
    
    func execute() -> (@escaping (FLTTaskProtocol, Any) -> Void) -> Void {
        return { result in
            let delegate = FLTInterstitialAd(success: { [weak self] () in
                guard let self = self else { return }
                result(self, ["code": 0])
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
