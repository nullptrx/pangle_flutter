//
//  UIUtil.swift
//  pangle_flutter
//
//  Created by nullptrX on 2022/10/4.
//

import Foundation
import UIKit

class UIUtil {

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
