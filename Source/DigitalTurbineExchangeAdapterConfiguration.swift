//
//  DigitalTurbineExchangeAdapterConfiguration.swift
//  ChartboostHeliumAdapterDigitalTurbineExchange
//
//  Created by Vu Chau on 9/13/22.
//

import Foundation
import IASDKCore

/// A list of externally configurable properties pertaining to the partner SDK that can be retrieved and set by publishers.
@objc public class DigitalTurbineExchangeAdapterConfiguration: NSObject {
    
    /// Flag that can optionally be set to change the log level of the Digital Turbine Exchange SDK.
    @objc public static var logLevel: IALogLevel = .info {
        didSet {
            IALogger.setLogLevel(logLevel)
            print("Digital Turbine Exchange SDK log level set to \(logLevel)")
        }
    }
}
