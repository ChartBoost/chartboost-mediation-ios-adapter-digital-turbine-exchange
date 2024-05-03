// Copyright 2022-2024 Chartboost, Inc.
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file.

import ChartboostMediationSDK
import Foundation
import IASDKCore

/// A list of externally configurable properties pertaining to the partner SDK that can be retrieved and set by publishers.
@objc public class DigitalTurbineExchangeAdapterConfiguration: NSObject, PartnerAdapterConfiguration {

    /// The version of the partner SDK.
    @objc public static var partnerSDKVersion: String {
        IASDKCore.sharedInstance().version() ?? ""
    }

    /// The version of the adapter.
    /// It should have either 5 or 6 digits separated by periods, where the first digit is Chartboost Mediation SDK's major version, the last digit is the adapter's build version, and intermediate digits are the partner SDK's version.
    /// Format: `<Chartboost Mediation major version>.<Partner major version>.<Partner minor version>.<Partner patch version>.<Partner build version>.<Adapter build version>` where `.<Partner build version>` is optional.
    @objc public static let adapterVersion = "4.8.2.1.1"

    /// The partner's unique identifier.
    @objc public static let partnerID = "fyber"

    /// The human-friendly partner name.
    @objc public static let partnerDisplayName = "Digital Turbine Exchange"

    /// Flag that can optionally be set to disable audio for the Digital Turbine Exchange SDK.
    @objc public static var muteAudio: Bool {
        get {
            IASDKCore.sharedInstance().muteAudio
        }
        set {
            IASDKCore.sharedInstance().muteAudio = newValue
            log("Mute audio set to \(newValue)")
        }
    }

    /// Flag that can optionally be set to change the log level of the Digital Turbine Exchange SDK.
    @objc public static var logLevel: DTXLogLevel = .info {
        didSet {
            DTXLogger.setLogLevel(logLevel)
            log("Log level set to \(logLevel)")
        }
    }
}
