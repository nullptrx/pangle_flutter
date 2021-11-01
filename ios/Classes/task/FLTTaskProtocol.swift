//
//  FLTTaskProtocol.swift
//  pangle_flutter
//
//  Created by nullptrX on 2020/8/16.
//

import Foundation

protocol FLTTaskProtocol: AnyObject {
    func execute() -> (@escaping (FLTTaskProtocol, Any) -> Void) -> Void

    func execute(_ loadingType: LoadingType) -> (@escaping (FLTTaskProtocol, Any) -> Void) -> Void
}

extension FLTTaskProtocol {
    func execute() -> (@escaping (FLTTaskProtocol, Any) -> Void) -> Void {
        { _ in
        }
    }

    func execute(_ loadingType: LoadingType) -> (@escaping (FLTTaskProtocol, Any) -> Void) -> Void {
        { _ in
        }
    }
}
