//
//  PangleEventStreamHandler.swift
//  pangle_flutter
//
//  Created by nullptrX on 2021/11/11.
//

import Foundation

public final class PangleEventStreamHandler: NSObject, FlutterStreamHandler {
    private static var eventSinks: [PangleEventType: FlutterEventSink] = [:]

    public static func interstitial(_ event: String = "unknown") {
        guard let eventSink = eventSinks[.fullscreen]  else { return }
        eventSink(event)
    }

    public static func fullscreen(_ event: String = "unknown") {
        guard let eventSink = eventSinks[.fullscreen]  else { return }
        eventSink(event)
    }

    public static func rewardedVideo(_ event: String = "unknown") {
        guard let eventSink = eventSinks[.rewarded_video] else { return }
        eventSink(event)
    }

    public static func clear() {
        eventSinks.removeAll()
    }

    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        guard let args: Int = arguments as? Int else { return nil }
        for type in PangleEventType.allCases {
            if type.rawValue == args {
                PangleEventStreamHandler.eventSinks[type] = events
                break
            }
        }
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        guard let args: Int = arguments as? Int else { return nil }
        for type in PangleEventType.allCases {
            if type.rawValue == args {
                PangleEventStreamHandler.eventSinks.removeValue(forKey: type)
                break
            }
        }
        return nil
    }
}
