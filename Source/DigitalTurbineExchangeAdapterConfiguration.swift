//
//  DigitalTurbineExchangeAdapterConfiguration.swift
//  ChartboostHeliumAdapterDigitalTurbineExchange
//
//  Created by Vu Chau on 9/13/22.
//

import Foundation
import IASDKCore

/// A list of externally configurable properties pertaining to the partner SDK that can be retrieved and set by publishers.
public class DigitalTurbineExchangeAdapterConfiguration {
    /// Flag that can optionally be set to to change the log level of the Digital Turbine Exchange SDK.
    public static var logLevel: IALogLevel = .info {
        didSet {
            IALogger.setLogLevel(logLevel)
            print("The Digital Turbine Exchange SDK's log level has been set to \(logLevel).")
        }
    }
}
