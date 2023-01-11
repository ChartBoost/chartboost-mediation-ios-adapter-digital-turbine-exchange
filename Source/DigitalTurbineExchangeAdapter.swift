//
//  DigitalTurbineExchangeAdapter.swift
//  ChartboostHeliumAdapterDigitalTurbineExchange
//
//  Created by Vu Chau on 9/13/22.
//

import Foundation
import HeliumSdk
import IASDKCore
import UIKit

/// The Helium Digital Turbine Exchange adapter
final class DigitalTurbineExchangeAdapter: PartnerAdapter {
    /// The version of the partner SDK.
    let partnerSDKVersion = IASDKCore.sharedInstance().version() ?? ""
    
    /// The version of the adapter.
    /// It should have either 5 or 6 digits separated by periods, where the first digit is Helium SDK's major version, the last digit is the adapter's build version, and intermediate digits are the partner SDK's version.
    /// Format: `<Helium major version>.<Partner major version>.<Partner minor version>.<Partner patch version>.<Partner build version>.<Adapter build version>` where `.<Partner build version>` is optional.
    let adapterVersion = "4.8.1.5.0"
    
    /// The partner's unique identifier.
    let partnerIdentifier = "fyber"
    
    /// The human-friendly partner name.
    let partnerDisplayName = "Digital Turbine Exchange"
    
    /// The designated initializer for the adapter.
    /// Helium SDK will use this constructor to create instances of conforming types.
    /// - parameter storage: An object that exposes storage managed by the Helium SDK to the adapter.
    /// It includes a list of created `PartnerAd` instances. You may ignore this parameter if you don't need it.
    init(storage: PartnerAdapterStorage) {}
    
    /// Does any setup needed before beginning to load ads.
    /// - parameter configuration: Configuration data for the adapter to set up.
    /// - parameter completion: Closure to be performed by the adapter when it's done setting up. It should include an error indicating the cause for failure or `nil` if the operation finished successfully.
    func setUp(with configuration: PartnerConfiguration, completion: @escaping (Error?) -> Void) {
        log(.setUpStarted)
        
        guard let appId = configuration.credentials[String.appIdKey] as? String, !appId.isEmpty else {
            let error = self.error(.initializationFailureInvalidCredentials, description: "Missing \(String.appIdKey)")
            self.log(.setUpFailed(error))
            
            completion(error)
            return
        }
        
        /// Digital Turbine Exchange's initialization needs to be done on the main thread
        DispatchQueue.main.async {
            IASDKCore.sharedInstance().initWithAppID(appId, completionBlock: { succeeded, error in
                if let error = error {
                    self.log(.setUpFailed(error))
                    completion(error)
                }
                else if !succeeded {
                    let error = self.error(.initializationFailureUnknown)
                    self.log(.setUpFailed(error))
                    completion(error)
                }
                else {
                    self.log(.setUpSucceded)
                    completion(nil)
                }
            }, completionQueue: nil)
        }
    }
    
    /// Fetches bidding tokens needed for the partner to participate in an auction.
    /// - parameter request: Information about the ad load request.
    /// - parameter completion: Closure to be performed with the fetched info.
    func fetchBidderInformation(request: PreBidRequest, completion: @escaping ([String : String]?) -> Void) {
        log(.fetchBidderInfoStarted(request))
        log(.fetchBidderInfoSucceeded(request))
        
        completion(nil)
    }
    
    /// Indicates if GDPR applies or not and the user's GDPR consent status.
    /// - parameter applies: `true` if GDPR applies, `false` if not, `nil` if the publisher has not provided this information.
    /// - parameter status: One of the `GDPRConsentStatus` values depending on the user's preference.
    func setGDPR(applies: Bool?, status: GDPRConsentStatus) {
        if (applies == true) {
            let gdprConsent: IAGDPRConsentType = status == GDPRConsentStatus.granted ? .given : .denied
            
            IASDKCore.sharedInstance().gdprConsent = gdprConsent
            log(.privacyUpdated(setting: "gdprConsent", value: gdprConsent))
        }
    }
    
    /// Indicates if the user is subject to COPPA or not.
    /// - parameter isChildDirected: `true` if the user is subject to COPPA, `false` otherwise.
    func setCOPPA(isChildDirected: Bool) {
        /// NO-OP
    }
    
    /// Indicates the CCPA status both as a boolean and as an IAB US privacy string.
    /// - parameter hasGivenConsent: A boolean indicating if the user has given consent.
    /// - parameter privacyString: An IAB-compliant string indicating the CCPA status.
    func setCCPA(hasGivenConsent: Bool, privacyString: String) {
        IASDKCore.sharedInstance().ccpaString = privacyString
        log(.privacyUpdated(setting: "ccpaString", value: privacyString))
    }
    
    /// Creates a new ad object in charge of communicating with a single partner SDK ad instance.
    /// Helium SDK calls this method to create a new ad for each new load request. Ad instances are never reused.
    /// Helium SDK takes care of storing and disposing of ad instances so you don't need to.
    /// `invalidate()` is called on ads before disposing of them in case partners need to perform any custom logic before the object gets destroyed.
    /// If, for some reason, a new ad cannot be provided, an error should be thrown.
    /// - parameter request: Information about the ad load request.
    /// - parameter delegate: The delegate that will receive ad life-cycle notifications.
    func makeAd(request: PartnerAdLoadRequest, delegate: PartnerAdDelegate) throws -> PartnerAd {
        switch request.format {
        case .interstitial, .rewarded:
            return DigitalTurbineExchangeAdapterFullscreenAd(adapter: self, request: request, delegate: delegate)
        case .banner:
            return DigitalTurbineExchangeAdapterBannerAd(adapter: self, request: request, delegate: delegate)
        @unknown default:
            throw error(.loadFailureUnsupportedAdFormat)
        }
    }
}

private extension String {
    /// The key name for parsing the Fyber app ID.
    static let appIdKey = "fyber_app_id"
}
