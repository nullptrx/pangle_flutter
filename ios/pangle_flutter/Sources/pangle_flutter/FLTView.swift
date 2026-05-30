//
//  FLTUIView.swift
//  pangle_flutter
//
//  Created by nullptrX on 2022/10/4.
//

import Foundation
import UIKit
import Flutter

class FLTView: UIView {
    
    private var touchableBounds: [CGRect] = []
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard isUserInteractionEnabled, !isHidden, alpha >= 0.01 else {
            return nil
        }
        // touchableBounds: 限制广告 View 的可点击区域。
        // 若设置了该列表，仅列表内的区域可接收点击事件，其余区域点击穿透给 Flutter 层。
        // 注：FlutterOverlayView 检测方案已在 Flutter 3+ TLHC 渲染模式下失效，已移除。
        if !touchableBounds.isEmpty {
            let keyWindow = UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first(where: { $0.isKeyWindow })
            let windowPoint = self.convert(point, to: keyWindow)
            let isTouchable = touchableBounds.contains { $0.contains(windowPoint) }
            return isTouchable ? super.hitTest(point, with: event) : nil
        }
        return super.hitTest(point, with: event)
    }
    
    
    func addTouchableBounds(bounds: [[String: Double?]]) {
        
        for bound in bounds {
            let w = bound["w"] ?? 0
            let h = bound["h"] ?? 0
            if w == nil || h == nil {
                continue
            }
            let x = bound["x"] ?? 0
            let y = bound["y"] ?? 0

            let targetBound = CGRect(x: x!, y: y!, width: w!, height: h!)
            var contains = false
            for touchableBound in touchableBounds {
                if touchableBound.equalTo(targetBound) {
                    contains = true
                    break
                }
            }
            if contains {
                continue
            }
         
            touchableBounds.append(targetBound)
           
        }
    }
    
    func clearTouchableBounds() {
        touchableBounds.removeAll()
    }
}
