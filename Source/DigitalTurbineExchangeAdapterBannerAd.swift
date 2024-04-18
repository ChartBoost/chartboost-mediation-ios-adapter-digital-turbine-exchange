// Copyright 2022-2024 Chartboost, Inc.
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file.

import ChartboostMediationSDK
import Foundation
import IASDKCore

/// The Chartboost Mediation Digital Turbine Exchange adapter banner ad.
final class DigitalTurbineExchangeAdapterBannerAd: DigitalTurbineExchangeAdapterAd, PartnerBannerAd, IAMRAIDContentDelegate {
    /// The partner banner ad view to display.
    var view: UIView? { viewUnitController?.adView }

    /// The loaded partner ad banner size.
    var size: PartnerBannerSize?

    /// The Digital Turbine Exchange MRAID content controller.
    private var mraidContentController: IAMRAIDContentController?
    
    /// The Digital Turbine Exchange view unit controller.
    private var viewUnitController: IAViewUnitController?
    
    /// The Digital Turbine Exchange ad spot on which to request ads
    private var adSpot: IAAdSpot?
    
    /// Loads an ad.
    /// - parameter viewController: The view controller on which the ad will be presented on. Needed on load for some banners.
    /// - parameter completion: Closure to be performed once the ad has been loaded.
    func load(with viewController: UIViewController?, completion: @escaping (Result<PartnerDetails, Error>) -> Void) {
        log(.loadStarted)
        
        self.viewController = viewController
        
        mraidContentController = IAMRAIDContentController.build { builder in
            builder.mraidContentDelegate = self
        }
        
        viewUnitController = IAViewUnitController.build { builder in
            builder.unitDelegate = self
            builder.addSupportedContentController(self.mraidContentController!)
        }
        
        guard let adRequest = self.buildAdRequest(placement: self.request.partnerPlacement) else {
            let error = self.error(.loadFailureInvalidAdRequest, description: "Ad request is nil.")
            
            self.log(.loadFailed(error))
            completion(.failure(error))
            
            return
        }
        
        adSpot = IAAdSpot.build { builder in
            builder.adRequest = adRequest
            builder.addSupportedUnitController(self.viewUnitController!)
        }
        
        adSpot?.fetchAd { [weak self] adSpot, adModel, error in
            if let error = error {
                self?.log(.loadFailed(error))
                completion(.failure(error))
            } else {
                self?.log(.loadSucceeded)

                // The size of the loaded view appears to be available in the adView's
                // intrinsicContentSize.
                if let loadedSize = self?.viewUnitController?.adView?.intrinsicContentSize {
                    self?.size = PartnerBannerSize(size: loadedSize, type: .fixed)
                }
                completion(.success([:]))
            }
        }
    }

    /// Build a partner ad request.
    /// - Parameter placement: The placement ID for the ad request.
    /// - Returns: A partner ad request for the current Chartboost Mediation ad load.
    func buildAdRequest(placement: String) -> IAAdRequest? {
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
        
    func iaUnitControllerWillPresentFullscreen(_ unitController: IAUnitController?) {
        log(.delegateCallIgnored)
    }
    
    func iaUnitControllerDidPresentFullscreen(_ unitController: IAUnitController?) {
        log(.delegateCallIgnored)
    }
    
    func iaUnitControllerWillDismissFullscreen(_ unitController: IAUnitController?) {
        log(.delegateCallIgnored)
    }
    
    func iaUnitControllerDidDismissFullscreen(_ unitController: IAUnitController?) {
        log(.delegateCallIgnored)
    }
    
    func iaUnitControllerWillOpenExternalApp(_ unitController: IAUnitController?) {
        log(.delegateCallIgnored)
    }
    
    func iaAdDidExpire(_ unitController: IAUnitController?) {
        log(.didExpire)
        delegate?.didExpire(self, details: [:]) ?? log(.delegateUnavailable)
    }
    
    // MARK: - IAMRAIDContentDelegate
    
    func iamraidContentController(_ contentController: IAMRAIDContentController?, mraidAdDidResizeToFrame frame: CGRect) {
        log(.custom("mraidAdDidResizeToFrame to (\(frame.width),\(frame.height))"))
    }
    
    func iamraidContentController(_ contentController: IAMRAIDContentController?, mraidAdWillResizeToFrame frame: CGRect) {
        log(.custom("mraidAdWillResizeToFrame to (\(frame.width),\(frame.height))"))
    }
    
    func iamraidContentController(_ contentController: IAMRAIDContentController?, mraidAdWillExpandToFrame frame: CGRect) {
        log(.custom("IMRAIDAdWillExpandToFrame to (\(frame.width),\(frame.height))"))
    }
    
    func iamraidContentController(_ contentController: IAMRAIDContentController?, mraidAdDidExpandToFrame frame: CGRect) {
        log(.custom("IMRAIDAdDidExpandToFrame to (\(frame.width),\(frame.height))"))
    }
    
    func iamraidContentControllerMRAIDAdWillCollapse(_ contentController: IAMRAIDContentController?) {
        log(.delegateCallIgnored)
    }
    
    func iamraidContentControllerMRAIDAdDidCollapse(_ contentController: IAMRAIDContentController?) {
        log(.delegateCallIgnored)
    }
    
    func iamraidContentController(_ contentController: IAMRAIDContentController?, videoInterruptedWithError error: Error) {
        log(.custom("videoInterruptedWithError: \(error)"))
    }
}
