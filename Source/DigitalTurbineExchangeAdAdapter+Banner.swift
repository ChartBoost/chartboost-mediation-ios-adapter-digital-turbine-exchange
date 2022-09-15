//
//  DigitalTurbineExchangeAdAdapter+Banner.swift
//  ChartboostHeliumAdapterDigitalTurbineExchange
//
//  Created by Vu Chau on 9/13/22.
//

import Foundation
import HeliumSdk
import IASDKCore

/// Collection of banner-sepcific API implementations
extension DigitalTurbineExchangeAdAdapter {
    /// Create an ad spot for the current banner ad request.
    /// - Parameter placementId: The current banner placement ID.
    /// - Returns: An ad spot for the current banner ad request. 
    func createBannerAdSpot(placementId: String) -> IAAdSpot? {
        guard let adRequest = buildAdRequest(placementId: placementId) else {
            log("Ad request is nil.")
            return nil
        }
        
        guard let mraidContentController = buildMraidContentController() else {
            log("MRAID content controller is nil.")
            return nil
        }
        
        self.mraidContentController = mraidContentController
        
        guard let viewUnitController = buildViewUnitController() else {
            log("View unit controller is nil.")
            return nil
        }
        
        self.viewUnitController = viewUnitController
        
        return IAAdSpot.build { builder in
            builder.adRequest = adRequest
            builder.addSupportedUnitController(self.viewUnitController)
        }
    }
}
