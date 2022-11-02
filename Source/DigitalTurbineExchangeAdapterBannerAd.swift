//
//  DigitalTurbineExchangeAdapterBannerAd.swift
//  ChartboostHeliumAdapterDigitalTurbineExchange
//
//  Created by Vu Chau on 9/13/22.
//

import Foundation
import IASDKCore
import HeliumSdk

final class DigitalTurbineExchangeAdapterBannerAd: DigitalTurbineExchangeAdapterAd, PartnerAd, IAMRAIDContentDelegate, IAUnitDelegate {
    /// The partner ad view to display inline. E.g. a banner view.
    /// Should be nil for full-screen ads.
    var inlineView: UIView? { viewUnitController?.adView }
    
    /// The Digital Turbine Exchange MRAID content controller.
    private var mraidContentController: IAMRAIDContentController?
    
    /// The Digital Turbine Exchange view unit controller.
    private var viewUnitController: IAViewUnitController?
    
    /// The Digital Turbine Exchange ad spot on which to request ads
    private var adSpot: IAAdSpot?
    
    /// Loads an ad.
    /// - parameter viewController: The view controller on which the ad will be presented on. Needed on load for some banners.
    /// - parameter completion: Closure to be performed once the ad has been loaded.
    func load(with viewController: UIViewController?, completion: @escaping (Result<PartnerEventDetails, Error>) -> Void) {
        log(.loadStarted)
        
        self.viewController = viewController
        
        mraidContentController = IAMRAIDContentController.build({ builder in
            builder.mraidContentDelegate = self
        })
        
        viewUnitController = IAViewUnitController.build({ builder in
            builder.unitDelegate = self
            builder.addSupportedContentController(self.mraidContentController!)
        })
        
        adSpot = IAAdSpot.build({ (builder:IAAdSpotBuilder) in
            guard let adRequest = self.buildAdRequest(placement: self.request.partnerPlacement) else {
                let error = self.error(.loadFailure, description: "Ad request is nil.")
                
                self.log(.loadFailed(error))
                completion(.failure(error))
                
                return
            }
            
            builder.adRequest = adRequest
            builder.addSupportedUnitController(self.viewUnitController!)
        })
        
        adSpot?.fetchAd(completion: { (adSpot:IAAdSpot?, adModel:IAAdModel?, error:Error?) in
            let succeeded = error == nil
            let error = self.error(.loadFailure, error: error)
            
            self.log(succeeded ? .loadSucceeded : .loadFailed(error))
            completion(succeeded ? .success([:]) : .failure(error))
        })
    }
    
    /// Shows a loaded ad.
    /// It will never get called for banner ads. You may leave the implementation blank for that ad format.
    /// - parameter viewController: The view controller on which the ad will be presented on.
    /// - parameter completion: Closure to be performed once the ad has been shown.
    func show(with viewController: UIViewController, completion: @escaping (Result<PartnerEventDetails, Error>) -> Void) {
        /// NO-OP
    }
    
    /// Build a partner ad request.
    /// - Parameter placement: The placement ID for the ad request.
    /// - Returns: A partner ad request for the current Helium ad load.
    func buildAdRequest(placement: String) -> IAAdRequest? {
        IAAdRequest.build { builder in
            builder.useSecureConnections = false
            builder.spotID = placement
            builder.timeout = 30
        }
    }
    
    // MARK: - IAUnitDelegate
    
    internal func iaParentViewController(for unitController: IAUnitController?) -> UIViewController {
        if let viewController = self.viewController {
            return viewController
        } else {
            if var topController = UIApplication.shared.keyWindow?.rootViewController {
                while let presentedViewController = topController.presentedViewController {
                    topController = presentedViewController
                }
                
                return topController
            }
            
            /// A valid ViewController should already be obtained when load is attempted.
            /// We should never get here—and if we do, something is seriously wrong that should result in a crash.
            fatalError()
        }
    }
    
    func iaAdDidReceiveClick(_ unitController: IAUnitController?) {
        log(.didClick(error: nil))
        delegate?.didClick(self, details: [:]) ?? log(.delegateUnavailable)
    }
    
    func iaAdWillLogImpression(_ unitController: IAUnitController?) {
        log(.didTrackImpression)
        delegate?.didTrackImpression(self, details: [:]) ?? log(.delegateUnavailable)
    }
    
    func iaAdDidReward(_ unitController: IAUnitController?) {
        /// NO-OP
    }
    
    func iaUnitControllerWillPresentFullscreen(_ unitController: IAUnitController?) {
        log(.custom("IAUnitControllerWillPresentFullscreen"))
    }
    
    func iaUnitControllerDidPresentFullscreen(_ unitController: IAUnitController?) {
        log(.custom("iaUnitControllerDidPresentFullscreen"))
    }
    
    func iaUnitControllerWillDismissFullscreen(_ unitController: IAUnitController?) {
        log(.custom("IAUnitControllerWillDismissFullscreen"))
    }
    
    func iaUnitControllerDidDismissFullscreen(_ unitController: IAUnitController?) {
        log(.custom("iaUnitControllerDidDismissFullscreen"))
    }
    
    func iaUnitControllerWillOpenExternalApp(_ unitController: IAUnitController?) {
        log(.custom("IAUnitControllerWillOpenExternalApp"))
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
        log(.custom("IAMRAIDContentControllerMRAIDAdWillCollapse"))
    }
    
    func iamraidContentControllerMRAIDAdDidCollapse(_ contentController: IAMRAIDContentController?) {
        log(.custom("IAMRAIDContentControllerMRAIDAdDidCollapse"))
    }
    
    func iamraidContentController(_ contentController: IAMRAIDContentController?, videoInterruptedWithError error: Error) {
        log(.custom("videoInterruptedWithError: \(error)"))
    }
}
