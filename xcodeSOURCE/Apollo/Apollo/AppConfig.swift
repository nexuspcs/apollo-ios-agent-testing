import Foundation

/// A simple configuration layer used across the app.
/// 
/// To set the Stripe publishable key, add a key named "StripePublishableKey"
/// in your Info.plist file with the appropriate value.
/// 
/// To configure Firebase, include the "GoogleService-Info.plist" file in your app bundle.
/// 
/// The `isMockMode` flag is true by default. It can be set to false when both Firebase
/// and Stripe configurations are detected, indicating the app is ready for production.
public struct AppConfig {
    
    /// Indicates whether the app is running in mock mode.
    /// This is `true` by default and can be switched to `false`
    /// when both Firebase and Stripe keys are present.
    public static var isMockMode: Bool {
        !(firebaseConfigured && (stripePublishableKey?.isEmpty == false))
    }
    
    /// The Stripe publishable key read from Info.plist key "StripePublishableKey".
    public static let stripePublishableKey: String? = {
        Bundle.main.object(forInfoDictionaryKey: "StripePublishableKey") as? String
    }()
    
    /// Indicates if Firebase is configured by checking for the presence of the "GoogleService-Info.plist" file in the main bundle.
    public static let firebaseConfigured: Bool = {
        Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil
    }()
    
    /// Indicates if the app is ready for production.
    /// This is true when Firebase is configured and the Stripe publishable key is present and non-empty.
    public static var readyForProduction: Bool {
        firebaseConfigured && (stripePublishableKey?.isEmpty == false)
    }
    
    /// Loads and logs the current configuration readiness.
    public static func load() {
        print("AppConfig - Firebase configured: \(firebaseConfigured)")
        print("AppConfig - Stripe publishable key present: \((stripePublishableKey?.isEmpty == false))")
        print("AppConfig - Ready for production: \(readyForProduction)")
        print("AppConfig - Mock mode is \(isMockMode ? "enabled" : "disabled")")
    }
}
