//
//  FLTUIView.swift
//  pangle_flutter
//
//  Created by nullptrX on 2022/10/4.
//

import Foundation

class FLTView: UIView {
    
    private var touchableBounds: [CGRect] = []
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if !self.isUserInteractionEnabled || self.isHidden || self.alpha < 0.01 {
            // interaction disable
            // hidden
            // nearly invisble
            return nil
        }
        let windowPoint = self.convert(point, to: UIApplication.shared.delegate?.window!!)
        //找到点击落点所在的Overlay
        let targetView = UIUtil.findTargetView(self)
        let targetOverlayView = UIUtil.findTargetOverlayView(self, windowPoint)
        //判断Overlay符合与广告相交、重合，则返回nil实现事件拦截
        if UIUtil.isOverlay(targetView, targetOverlayView) {
            // 高级功能：自定义可点击区域（例如：虽然OverlayView覆盖了广告View, 但OverlayView该区域并没有可点击控件，此时可将事件传递下去）
            var touchable = false
            if touchableBounds.isEmpty {
                touchable = false
            }
            for bound in touchableBounds {
                if bound.contains(windowPoint) {
                    touchable = true
                    break
                }
            }
            if touchable {
                return super.hitTest(point, with: event)
            }
                    
            return nil
        } else {
              return super.hitTest(point, with: event)
        }
        
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
                if CGRectEqualToRect(touchableBound, targetBound) {
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
