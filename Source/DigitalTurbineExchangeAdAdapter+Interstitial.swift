//
//  DigitalTurbineExchangeAdAdapter+Interstitial.swift
//  ChartboostHeliumAdapterDigitalTurbineExchange
//
//  Created by Vu Chau on 9/13/22.
//

import Foundation
import HeliumSdk
import IASDKCore

/// Collection of interstitial-sepcific API implementations
extension DigitalTurbineExchangeAdAdapter {
    /// Create an ad spot for the current interstitial ad request.
    /// - Parameter placementId: The current interstitial placement ID.
    /// - Returns: An ad spot for the current interstitial ad request.
    func createFullscreenAdSpot(placementId: String) -> IAAdSpot? {
        guard let adRequest = buildAdRequest(placementId: placementId) else {
            log("Ad request is nil.")
            return nil
        }
        
        guard let videoContentController = buildVideoContentController() else {
            log("Video content controller is nil.")
            return nil
        }
        
        self.videoContentController = videoContentController
        
        guard let mraidContentController = buildMraidContentController() else {
            log("MRAID content controller is nil.")
            return nil
        }
        
        self.mraidContentController = mraidContentController
        
        guard let fullscreenUnitController = buildFullscreenUnitController() else {
            log("Fullscreen unit controller is nil.")
            return nil
        }
        
        self.fullscreenUnitController = fullscreenUnitController
        
        return IAAdSpot.build { builder in
            builder.adRequest = adRequest
            builder.addSupportedUnitController(self.fullscreenUnitController)
        }
    }
    
    /// Attempt to show the currently loaded fullscreen ad.
    func showFullscreenAd() {
        if let ad = partnerAd.ad as? IAFullscreenUnitController {
            ad.showAd(animated: true) {
                self.showCompletion?(.success(self.partnerAd))
            }
        } else {
            showCompletion?(.failure(error(.showFailure(partnerAd), description: "Ad instance is nil/not an IAFullscreenUnitController.")))
        }
        
        showCompletion = nil
    }
}
