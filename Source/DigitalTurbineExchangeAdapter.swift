// Copyright 2022-2024 Chartboost, Inc.
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file.

import ChartboostMediationSDK
import Foundation
import IASDKCore
import UIKit

/// The Chartboost Mediation Digital Turbine Exchange adapter
final class DigitalTurbineExchangeAdapter: PartnerAdapter {
    /// The version of the partner SDK.
    var partnerSDKVersion: String {
        DigitalTurbineExchangeAdapterConfiguration.partnerSDKVersion
    }

    /// The version of the adapter.
    /// It should have either 5 or 6 digits separated by periods, where the first digit is Chartboost Mediation SDK's major version, the last digit is the adapter's build version, and intermediate digits are the partner SDK's version.
    /// Format: `<Chartboost Mediation major version>.<Partner major version>.<Partner minor version>.<Partner patch version>.<Partner build version>.<Adapter build version>` where `.<Partner build version>` is optional.
    var adapterVersion: String {
        DigitalTurbineExchangeAdapterConfiguration.adapterVersion
    }

    /// The partner's unique identifier.
    var partnerID: String {
        DigitalTurbineExchangeAdapterConfiguration.partnerID
    }

    /// The human-friendly partner name.
    var partnerDisplayName: String {
        DigitalTurbineExchangeAdapterConfiguration.partnerDisplayName
    }

    /// The designated initializer for the adapter.
    /// Chartboost Mediation SDK will use this constructor to create instances of conforming types.
    /// - parameter storage: An object that exposes storage managed by the Chartboost Mediation SDK to the adapter.
    /// It includes a list of created `PartnerAd` instances. You may ignore this parameter if you don't need it.
    init(storage: PartnerAdapterStorage) {}
    
    /// Does any setup needed before beginning to load ads.
    /// - parameter configuration: Configuration data for the adapter to set up.
    /// - parameter completion: Closure to be performed by the adapter when it's done setting up. It should include an error indicating the cause for failure or `nil` if the operation finished successfully.
    func setUp(with configuration: PartnerConfiguration, completion: @escaping (Result<PartnerDetails, Error>) -> Void) {
        log(.setUpStarted)
        
        guard let appId = configuration.credentials[String.appIdKey] as? String, !appId.isEmpty else {
            let error = self.error(.initializationFailureInvalidCredentials, description: "Missing \(String.appIdKey)")
            self.log(.setUpFailed(error))
            
            completion(.failure(error))
            return
        }
        
        // Apply initial consents
        setConsents(configuration.consents, modifiedKeys: Set(configuration.consents.keys))
        setIsUserUnderage(configuration.isUserUnderage)

        /// Digital Turbine Exchange's initialization needs to be done on the main thread
        DispatchQueue.main.async {
            IASDKCore.sharedInstance().initWithAppID(appId, completionBlock: { succeeded, error in
                if let error = error {
                    self.log(.setUpFailed(error))
                    completion(.failure(error))
                }
                else if !succeeded {
                    let error = self.error(.initializationFailureUnknown)
                    self.log(.setUpFailed(error))
                    completion(.failure(error))
                }
                else {
                    self.log(.setUpSucceded)
                    completion(.success([:]))
                }
            }, completionQueue: nil)
        }
    }
    
    /// Fetches bidding tokens needed for the partner to participate in an auction.
    /// - parameter request: Information about the ad load request.
    /// - parameter completion: Closure to be performed with the fetched info.
    func fetchBidderInformation(request: PartnerAdPreBidRequest, completion: @escaping (Result<[String : String], Error>) -> Void) {
        log(.fetchBidderInfoNotSupported)
        completion(.success([:]))
    }
    
    /// Indicates that the user consent has changed.
    /// - parameter consents: The new consents value, including both modified and unmodified consents.
    /// - parameter modifiedKeys: A set containing all the keys that changed.
    func setConsents(_ consents: [ConsentKey: ConsentValue], modifiedKeys: Set<ConsentKey>) {
        // See https://developer.digitalturbine.com/hc/en-us/articles/360009940077-GDPR
        if modifiedKeys.contains(partnerID) || modifiedKeys.contains(ConsentKeys.gdprConsentGiven) {
            let consent = consents[partnerID] ?? consents[ConsentKeys.gdprConsentGiven]
            let gdprConsent: IAGDPRConsentType
            switch consent {
            case ConsentValues.granted: gdprConsent = .given
            case ConsentValues.denied: gdprConsent = .denied
            default: gdprConsent = .unknown

            }
            IASDKCore.sharedInstance().gdprConsent = gdprConsent
            log(.privacyUpdated(setting: "gdprConsent", value: gdprConsent.rawValue))
        }

        if modifiedKeys.contains(ConsentKeys.tcf) {
            let tcfString = consents[ConsentKeys.tcf]
            IASDKCore.sharedInstance().gdprConsentString = tcfString
            log(.privacyUpdated(setting: "gdprConsentString", value: tcfString))
        }

        // See https://developer.digitalturbine.com/hc/en-us/articles/360010026018-CCPA-Privacy-String
        if modifiedKeys.contains(ConsentKeys.usp) {
            let privacyString = consents[ConsentKeys.usp]
            IASDKCore.sharedInstance().ccpaString = privacyString
            log(.privacyUpdated(setting: "ccpaString", value: privacyString))
        }
    }

    /// Indicates that the user is underage signal has changed.
    /// - parameter isUserUnderage: `true` if the user is underage as determined by the publisher, `false` otherwise.
    func setIsUserUnderage(_ isUserUnderage: Bool) {
        // NO-OP
    }

    
    /// Creates a new banner ad object in charge of communicating with a single partner SDK ad instance.
    /// Chartboost Mediation SDK calls this method to create a new ad for each new load request. Ad instances are never reused.
    /// Chartboost Mediation SDK takes care of storing and disposing of ad instances so you don't need to.
    /// ``PartnerAd/invalidate()`` is called on ads before disposing of them in case partners need to perform any custom logic before the
    /// object gets destroyed.
    /// If, for some reason, a new ad cannot be provided, an error should be thrown.
    /// Chartboost Mediation SDK will always call this method from the main thread.
    /// - parameter request: Information about the ad load request.
    /// - parameter delegate: The delegate that will receive ad life-cycle notifications.
    func makeBannerAd(request: PartnerAdLoadRequest, delegate: PartnerAdDelegate) throws -> PartnerBannerAd {
        // This partner supports multiple loads for the same partner placement.
        DigitalTurbineExchangeAdapterBannerAd(adapter: self, request: request, delegate: delegate)
    }

    /// Creates a new ad object in charge of communicating with a single partner SDK ad instance.
    /// Chartboost Mediation SDK calls this method to create a new ad for each new load request. Ad instances are never reused.
    /// Chartboost Mediation SDK takes care of storing and disposing of ad instances so you don't need to.
    /// ``PartnerAd/invalidate()`` is called on ads before disposing of them in case partners need to perform any custom logic before the
    /// object gets destroyed.
    /// If, for some reason, a new ad cannot be provided, an error should be thrown.
    /// - parameter request: Information about the ad load request.
    /// - parameter delegate: The delegate that will receive ad life-cycle notifications.
    func makeFullscreenAd(request: PartnerAdLoadRequest, delegate: PartnerAdDelegate) throws -> PartnerFullscreenAd {
        // This partner supports multiple loads for the same partner placement.
        switch request.format {
        case PartnerAdFormats.interstitial, PartnerAdFormats.rewarded:
            return DigitalTurbineExchangeAdapterFullscreenAd(adapter: self, request: request, delegate: delegate)
        default:
            throw error(.loadFailureUnsupportedAdFormat)
        }
    }
    
    /// Maps a partner setup error to a Chartboost Mediation error code.
    /// Chartboost Mediation SDK calls this method when a setup completion is called with a partner error.
    ///
    /// A default implementation is provided that returns `nil`.
    /// Only implement if the partner SDK provides its own list of error codes that can be mapped to Chartboost Mediation's.
    /// If some case cannot be mapped return `nil` to let Chartboost Mediation choose a default error code.
    func mapSetUpError(_ error: Error) -> ChartboostMediationError.Code? {
        guard let code = IASDKCoreInitErrorType(rawValue: (error as NSError).code) else {
            return nil
        }
        switch code {
        case .unknown:
            return .initializationFailureUnknown
        case .failedToDownloadMandatoryData:
            return .initializationFailureNetworkingError
        case .missingModules:
            return .initializationFailurePartnerNotIntegrated
        case .invalidAppID:
            return .initializationFailureInvalidCredentials
        case .cancelled:
            return .initializationFailureAborted
        @unknown default:
            return nil
        }
    }
}

private extension String {
    /// The key name for parsing the Fyber app ID.
    static let appIdKey = "fyber_app_id"
}
