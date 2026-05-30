#if canImport(BUAdTestMeasurement)
  import BUAdTestMeasurement
#endif
import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private var testToolsChannel: FlutterMethodChannel?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    #if canImport(BUAdTestMeasurement)
      BUAdTestMeasurementConfiguration().debugMode = true
    #endif
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    guard let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "PangleTestTools") else {
      return
    }
    testToolsChannel = FlutterMethodChannel(name: "pangle_test_tools", binaryMessenger: registrar.messenger())
    testToolsChannel?.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
      guard call.method == "showTestSuite" else {
        result(FlutterMethodNotImplemented)
        return
      }

      let window = UIApplication.shared.connectedScenes
        .compactMap { $0 as? UIWindowScene }
        .flatMap { $0.windows }
        .first(where: { !$0.isHidden })
      guard let rootVC = window?.rootViewController else {
        result(FlutterError(code: "NO_VC", message: "No root view controller", details: nil))
        return
      }

      var topVC = rootVC
      while let presented = topVC.presentedViewController {
        topVC = presented
      }
      #if canImport(BUAdTestMeasurement)
        let placeholderVC = UIViewController()
        let nav = UINavigationController(rootViewController: placeholderVC)
        nav.modalPresentationStyle = .fullScreen
        let darkBG = UIColor(red: 73/255, green: 15/255, blue: 15/255, alpha: 1)
        nav.navigationBar.barStyle = .black
        if #available(iOS 13.0, *) {
          let appearance = UINavigationBarAppearance()
          appearance.configureWithOpaqueBackground()
          appearance.backgroundColor = darkBG
          appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
          nav.navigationBar.standardAppearance = appearance
          nav.navigationBar.scrollEdgeAppearance = appearance
          nav.navigationBar.compactAppearance = appearance
        } else {
          nav.navigationBar.barTintColor = darkBG
          nav.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        }
        topVC.present(nav, animated: true) {
          BUAdTestMeasurementManager.showTestMeasurement(with: placeholderVC)
        }
        result(nil)
      #else
        result(FlutterError(code: "UNAVAILABLE", message: "BUAdTestMeasurement not linked", details: nil))
      #endif
    }
  }
}
