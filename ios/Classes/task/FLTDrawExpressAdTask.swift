//
//  FLTDrawExpressAdTask.swift
//  pangle_flutter
//

import BUAdSDK
import Foundation

internal final class FLTDrawExpressAdTask: FLTTaskProtocol {
    public let manager: BUNativeExpressAdManager
    private var delegate: FLTNativeExpressAdViewDelegate?
    private var count: Int

    internal init(manager: BUNativeExpressAdManager, count: Int) {
        self.manager = manager
        self.count = count
    }

    convenience init(_ args: [String: Any?]) {
        let slotId = args["slotId"] as? String ?? ""
        let count = args["adCount"] as? Int ?? 2

        let screenSize = UIScreen.main.bounds.size
        let expressSize: CGSize
        if let expressArgs = args["expressSize"] as? [String: Double],
           let w = expressArgs["width"], let h = expressArgs["height"], w > 0, h > 0
        {
            expressSize = CGSize(width: w, height: h)
        } else {
            expressSize = screenSize
        }

        let slot = BUAdSlot()
        slot.id = slotId
        slot.AdType = .drawVideo
        slot.position = .feed

        let nad = BUNativeExpressAdManager(slot: slot, adSize: expressSize)
        nad.adSize = expressSize
        self.init(manager: nad, count: count)
    }

    func execute() -> (@escaping (FLTTaskProtocol, Any) -> Void) -> Void {
        return { result in
            let delegate = FLTNativeExpressAdViewDelegate(success: { [weak self] data in
                guard let self = self else { return }
                result(self, ["code": 0, "count": data.count, "data": data] as [String: Any])
            }, fail: { [weak self] error in
                guard let self = self else { return }
                let e = error as NSError?
                result(self, ["code": e?.code ?? -1, "message": error?.localizedDescription ?? "", "count": 0, "data": [] as [Any]] as [String: Any])
            })

            self.manager.delegate = delegate
            self.delegate = delegate

            self.manager.loadAdData(withCount: self.count)
        }
    }
}
