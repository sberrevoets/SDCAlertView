import Foundation

extension Bundle {
    #if SWIFT_PACKAGE
    static var resourceBundle: Bundle = .module
    #else
    static var resourceBundle: Bundle {
        let sourceBundle = Bundle(for: AlertController.self)
        let bundleURL = sourceBundle.url(forResource: "SDCAlertView", withExtension: "bundle")
        return bundleURL.flatMap(Bundle.init(url:)) ?? sourceBundle
    }
    #endif
}
