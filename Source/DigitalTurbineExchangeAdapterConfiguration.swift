// Copyright 2022-2024 Chartboost, Inc.
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file.

import Foundation
import IASDKCore
import os.log

/// A list of externally configurable properties pertaining to the partner SDK that can be retrieved and set by publishers.
@objc public class DigitalTurbineExchangeAdapterConfiguration: NSObject {

    private static let log = OSLog(subsystem: "com.chartboost.mediation.adapter.fyber", category: "Configuration")

    /// Flag that can optionally be set to change the log level of the Digital Turbine Exchange SDK.
    @objc public static var logLevel: DTXLogLevel = .info {
        didSet {
            DTXLogger.setLogLevel(logLevel)
            if #available(iOS 12.0, *) {
                os_log(.debug, log: log, "Digital Turbine Exchange SDK log level set to %{public}s", "\(logLevel)")
            }
        }
    }
}
