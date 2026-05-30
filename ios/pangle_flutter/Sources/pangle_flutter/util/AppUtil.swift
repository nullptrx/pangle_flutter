//
//  AppUtil.swift
//  ttad
//
//  Created by Jerry on 2020/7/26.
//

import Foundation
import UIKit

class AppUtil {
    /// 返回当前可见的根视图控制器，使用 Scene-based API（iOS 13+）
    static func getVC() -> UIViewController {
        let window = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first(where: { !$0.isHidden })
        guard let rootVC = window?.rootViewController else {
            // 降级兜底：直接返回空 VC，避免崩溃
            return UIViewController()
        }
        return rootVC
    }

    static func getCurrentVC() -> UIViewController? {
        let rootViewController = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first(where: { $0.isKeyWindow })?.rootViewController
        return self.getCurrentVC(from: rootViewController)
    }

    static func getCurrentVC(from rootVC: UIViewController?) -> UIViewController? {
        var rootVC = rootVC
        var currentVC: UIViewController?
        if rootVC?.presentedViewController != nil {
            rootVC = rootVC?.presentedViewController
        }
        if rootVC is UITabBarController {
            currentVC = self.getCurrentVC(from: (rootVC as? UITabBarController)?.selectedViewController)
        } else if rootVC is UINavigationController {
            currentVC = self.getCurrentVC(from: (rootVC as? UINavigationController)?.visibleViewController)
        } else {
            currentVC = rootVC
        }
        return currentVC
    }
}
