// Copyright 2022-2023 Chartboost, Inc.
// 
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file.

//
//  DigitalTurbineExchangeAdapterFullscreenAd.swift
//  ChartboostHeliumAdapterDigitalTurbineExchange
//
//  Created by Vu Chau on 9/13/22.
//

import Foundation
import IASDKCore
import HeliumSdk
import UIKit

/// The Helium Digital Turbine Exchange adapter interstitial ad.
final class DigitalTurbineExchangeAdapterFullscreenAd: DigitalTurbineExchangeAdapterAd, PartnerAd, IAVideoContentDelegate, IAMRAIDContentDelegate {
    /// The partner ad view to display inline. E.g. a banner view.
    /// Should be nil for full-screen ads.
    internal var inlineView: UIView? { nil }
    
    /// The Digital Turbine Exchange fullscreen ad instance.
    private var fullscreenUnitController: IAFullscreenUnitController?
    
    /// The Digital Turbine Exchange MRAID content controller.
    private var mraidContentController: IAMRAIDContentController?
    
    /// The Digital Turbine Exchange video content controller.
    private var videoContentController: IAVideoContentController?
    
    /// The Digital Turbine Exchange view unit controller.
    private var viewUnitController: IAViewUnitController?
    
    /// The Digital Turbine Exchange ad spot on which to request ads
    private var adSpot: IAAdSpot?
    
    /// Loads an ad.
    /// - parameter viewController: The view controller on which the ad will be presented on. Needed on load for some banners.
    /// - parameter completion: Closure to be performed once the ad has been loaded.
    func load(with viewController: UIViewController?, completion: @escaping (Result<PartnerEventDetails, Error>) -> Void) {
        log(.loadStarted)
        
        videoContentController = IAVideoContentController.build({ builder in
            builder.videoContentDelegate = self
        })
        
        mraidContentController = IAMRAIDContentController.build({ builder in
            builder.mraidContentDelegate = self
        })
        
        viewUnitController = IAViewUnitController.build({ builder in
            builder.unitDelegate = self
            builder.addSupportedContentController(self.mraidContentController!)
        })
        
        fullscreenUnitController = IAFullscreenUnitController.build({ builder in
            builder.unitDelegate = self
            builder.addSupportedContentController(self.mraidContentController!)
            builder.addSupportedContentController(self.videoContentController!)
        })
        
        guard let adRequest = self.buildAdRequest(placement: self.request.partnerPlacement) else {
            let error = self.error(.loadFailureInvalidAdRequest, description: "Ad request is nil.")
            
            self.log(.loadFailed(error))
            completion(.failure(error))
            
            return
        }

        adSpot = IAAdSpot.build({ (builder:IAAdSpotBuilder) in
            builder.adRequest = adRequest
            builder.addSupportedUnitController(self.fullscreenUnitController!)
            builder.addSupportedUnitController(self.viewUnitController!)
        })
        
        adSpot?.fetchAd(completion: { (adSpot:IAAdSpot?, adModel:IAAdModel?, error:Error?) in
            if let error = error {
                self.log(.loadFailed(error))
                completion(.failure(error))
            }
            else {
                self.log(.loadSucceeded)
                completion(.success([:]))
            }
        })
    }
    
    /// Shows a loaded ad.
    /// It will never get called for banner ads. You may leave the implementation blank for that ad format.
    /// - parameter viewController: The view controller on which the ad will be presented on.
    /// - parameter completion: Closure to be performed once the ad has been shown.
    func show(with viewController: UIViewController, completion: @escaping (Result<PartnerEventDetails, Error>) -> Void) {
        log(.showStarted)
        
        self.viewController = viewController
        showCompletion = completion
        
        if let ad = fullscreenUnitController {
            ad.showAd(animated: true)
        } else {
            let error = error(.showFailureAdNotReady)
            
            log(.showFailed(error))
            completion(.failure(error))
        }
    }
    
    /// Build a partner ad request.
    /// - Parameter placement: The placement ID for the ad request.
    /// - Returns: A partner ad request for the current Helium ad load.
    private func buildAdRequest(placement: String) -> IAAdRequest? {
        IAAdRequest.build { builder in
            builder.useSecureConnections = false
            builder.spotID = placement
            builder.timeout = 30
        }
    }
    
    // MARK: - IAUnitDelegate
    
    func iaAdDidReceiveClick(_ unitController: IAUnitController?) {
        log(.didClick(error: nil))
        delegate?.didClick(self, details: [:]) ?? log(.delegateUnavailable)
    }
    
    func iaAdWillLogImpression(_ unitController: IAUnitController?) {
        log(.didTrackImpression)
        delegate?.didTrackImpression(self, details: [:]) ?? log(.delegateUnavailable)
    }
    
    func iaAdDidReward(_ unitController: IAUnitController?) {
        if (request.format == .rewarded) {
            log(.didReward)
            delegate?.didReward(self, details: [:]) ?? log(.delegateUnavailable)
        }
    }
    
    func iaUnitControllerWillPresentFullscreen(_ unitController: IAUnitController?) {
        log(.delegateCallIgnored)
    }
    
    func iaUnitControllerDidPresentFullscreen(_ unitController: IAUnitController?) {
        log(.showSucceeded)
        showCompletion?(.success([:])) ?? log(.showResultIgnored)
        showCompletion = nil
    }
    
    func iaUnitControllerWillDismissFullscreen(_ unitController: IAUnitController?) {
        log(.delegateCallIgnored)
    }
    
    func iaUnitControllerDidDismissFullscreen(_ unitController: IAUnitController?) {
        log(.didDismiss(error: nil))
        delegate?.didDismiss(self, details: [:], error: nil) ?? log(.delegateUnavailable)
    }
    
    func iaUnitControllerWillOpenExternalApp(_ unitController: IAUnitController?) {
        log(.delegateCallIgnored)
    }
    
    func iaAdDidExpire(_ unitController: IAUnitController?) {
        log(.didExpire)
        delegate?.didExpire(self, details: [:]) ?? log(.delegateUnavailable)
    }
}
