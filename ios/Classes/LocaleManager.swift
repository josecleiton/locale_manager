import Flutter
import UIKit
import Foundation

extension Notification.Name {
    static let languageChanged = Notification.Name("languageChanged")
}

private var bundleKey = 0

public extension Bundle {
    class func setLanguage(_ language: String) {
        defer {
            object_setClass(Bundle.main, Bundle.self)
        }
        objc_setAssociatedObject(Bundle.main, &bundleKey, Bundle.main, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        guard let newBundle = fetchBundleByLang(for: language) else {
            return
        }
        
        objc_setAssociatedObject(Bundle.main, &bundleKey, newBundle, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    class func fetchBundleByLang(for language: String) -> Bundle? {
            guard let path = Bundle.main.path(forResource: language, ofType: "lproj") else {
                return nil
            }
            return Bundle(path: path)
        }
    
    @objc func myLocalizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        let bundle = objc_getAssociatedObject(self, &bundleKey) as? Bundle
        return bundle?.localizedString(forKey: key, value: value, table: tableName) ?? self.myLocalizedString(forKey: key, value: value, table: tableName)
    }
    
    static let once: Void = {
        print("Attempting to swizzle")
        let originalSelector = #selector(Bundle.localizedString(forKey:value:table:))
        let swizzledSelector = #selector(Bundle.myLocalizedString(forKey:value:table:))
        
        guard let originalMethod = class_getInstanceMethod(Bundle.self, originalSelector),
              let swizzledMethod = class_getInstanceMethod(Bundle.self, swizzledSelector) else {
            print("Swizzling failed: Methods not found")
            return
        }
        
        method_exchangeImplementations(originalMethod, swizzledMethod)
        print("Swizzling done")
    }()
}

public class LocaleManagerPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "locale_manager", binaryMessenger: registrar.messenger())
        
        _ = Bundle.once
        
        let instance = LocaleManagerPlugin()
        instance.listenNotification()
        
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func listenNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateUI), name: .languageChanged, object: nil)
    }
    
    @objc private func updateUI() {
        if let view = UIApplication.shared.delegate?.window??.rootViewController?.view {
            view.setNeedsLayout()
            view.layoutIfNeeded()
        }
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "setLocale":
            guard let arguments = getArguments(call, result) else {
                return
            }
            setLocale(arguments["locale"] as! String)
            result(true)
        case "getLocalized":
            guard let arguments = getArguments(call, result) else {
                return
            }
            result(getLocalized(arguments["key"] as! String))
        case "getLocale":
            result(getLocale())
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func getArguments(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) -> Dictionary<String, Any>? {
        guard let arguments = call.arguments as? Dictionary<String, Any> else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return nil
        }
        return arguments
    }
    
    private func setLocale(_ locale: String) {
        let localeIdentifier = locale.replacingOccurrences(of: "_", with: "-")
        UserDefaults.standard.set([localeIdentifier], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
        
        guard let _ = Bundle.fetchBundleByLang(for: localeIdentifier) else {
                 print("Invalid locale code or localization bundle does not exist. Native will update after restarting the app for: \(localeIdentifier)")
                 return
             }
             
        Bundle.setLanguage(localeIdentifier)
        NotificationCenter.default.post(name: .languageChanged, object: nil)
    }
    
    private func getLocale() -> String {
        return Locale.preferredLanguages[0]
    }
    
    private func getLocalized(_ key: String) -> String {
        return Bundle.main.localizedString(forKey: key, value: nil, table: nil)
    }
}
