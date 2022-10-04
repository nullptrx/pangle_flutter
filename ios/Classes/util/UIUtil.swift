//
//  UIUtil.swift
//  pangle_flutter
//
//  Created by nullptrX on 2022/10/4.
//

import Foundation

// http://jackin.cn/2021/02/01/bytedance-ad-click-penetration-on-flutter.html
class UIUtil {
    
    static func isOverlay(_ view: UIView?, _ overlayView: UIView?) -> Bool {
        guard let v1 = view else {
            return false
        }
        guard let v2 = overlayView else {
            return false
        }
        
        if v1.frame.contains(v2.frame) || v2.frame.contains(v1.frame) {
            // the view contains overlay, or overlay view contains the view
            return true
        }
        if v1.frame.intersects(v2.frame) || v2.frame.intersects(v1.frame) {
            // the view is intersected with overaly
            return true
        }
        
        return false
    }
    
    static func findTargetView(_ view: UIView) -> UIView? {
        return view.superview?.superview
    }
    
    static func findTargetOverlayView(_ view: UIView, _ point: CGPoint) -> UIView? {
        
        guard let flutterView: UIView =  view.superview?.superview?.superview else {
            return nil
        }

        if String(describing: flutterView.classForCoder) == "FlutterView" {
            for v in flutterView.subviews {
                let contains = v.frame.contains(point)
                if String(describing: v.classForCoder) == "FlutterOverlayView" && contains {
                    return v
                }
            }
        }
        return nil
    }
    
    
    static func removeAllView(_ container: UIView) {
        container.subviews.forEach {
            $0.subviews.forEach {
                $0.removeFromSuperview()
            }
            $0.removeFromSuperview()
        }
        container.removeFromSuperview()
    }
    
}
