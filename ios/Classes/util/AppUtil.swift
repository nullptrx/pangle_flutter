//
//  AppUtil.swift
//  ttad
//
//  Created by Jerry on 2020/7/26.
//

import Foundation

class AppUtil {
    static func getVC() -> UIViewController {
        let viewController = UIApplication.shared.windows.filter { (w) -> Bool in
            w.isHidden == false
        }.first?.rootViewController
//        let viewController: UIViewController = (UIApplication.shared.delegate?.window??.rootViewController)!
        return viewController!
    }

    static func getCurrentVC() -> UIViewController? {
        let rootViewController = UIApplication.shared.keyWindow?.rootViewController
        let currentVC = self.getCurrentVC(from: rootViewController)
        return currentVC
    }

    static func getCurrentVC(from rootVC: UIViewController?) -> UIViewController? {
        var rootVC = rootVC
        var currentVC: UIViewController?
        if rootVC?.presentedViewController != nil {
            // 视图是被presented出来的
            rootVC = rootVC?.presentedViewController
        }
        if rootVC is UITabBarController {
            // 根视图为UITabBarController
            currentVC = self.getCurrentVC(from: (rootVC as? UITabBarController)?.selectedViewController)
        } else if rootVC is UINavigationController {
            // 根视图为UINavigationController
            currentVC = self.getCurrentVC(from: (rootVC as? UINavigationController)?.visibleViewController)
        } else {
            // 根视图为非导航类
            currentVC = rootVC
        }

        return currentVC
    }
}
