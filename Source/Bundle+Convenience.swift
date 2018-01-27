import Foundation

extension Bundle {
    class var resources: Bundle {
        let frameworkBundle = Bundle(for: AlertController.self)

        if let bundleURL = frameworkBundle.url(forResource: "SDCAlertView", withExtension: "bundle"),
            let bundle = Bundle(url: bundleURL) {
            return bundle
        }

        return frameworkBundle
    }
}
