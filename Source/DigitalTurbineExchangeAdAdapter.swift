//
//  DigitalTurbineExchangeAdAdapter.swift
//  ChartboostHeliumAdapterDigitalTurbineExchange
//
//  Created by Vu Chau on 9/13/22.
//

import Foundation
import HeliumSdk
import IASDKCore
import UIKit

final class DigitalTurbineExchangeAdAdapter: NSObject, PartnerLogger, PartnerErrorFactory, IAVideoContentDelegate, IAUnitDelegate, IAMRAIDContentDelegate {
    /// The current adapter instance
    let adapter: PartnerAdapter
    
    /// The current PartnerAdLoadRequest containing data relevant to the curent ad request
    let request: PartnerAdLoadRequest
    
    /// A PartnerAd object with a placeholder (nil) ad object.
    lazy var partnerAd = PartnerAd(ad: nil, details: [:], request: request)
    
    /// The partner ad delegate to send ad life-cycle events to.
    weak var partnerAdDelegate: PartnerAdDelegate?
    
    /// The current ViewController for ad presentation purposes.
    weak var viewController: UIViewController?
    
    /// The completion handler to notify Helium of ad show completion result.
    var showCompletion: ((Result<PartnerAd, Error>) -> Void)?
    
    /// The current IAVideoContentController instance.
    var videoContentController: IAVideoContentController
    
    /// The current IAMRAIDContentController instance.
    var mraidContentController: IAMRAIDContentController
    
    /// The current IAViewUnitController instance.
    var viewUnitController: IAViewUnitController
    
    /// The current IAFullscreenUnitController instance.
    var fullscreenUnitController: IAFullscreenUnitController
    
    /// Create a new instance of the adapter.
    /// - Parameters:
    ///   - adapter: The current adapter instance
    ///   - request: The current AdLoadRequest containing data relevant to the curent ad request
    ///   - partnerAdDelegate: The partner ad delegate to notify Helium of ad lifecycle events.
    init(adapter: PartnerAdapter, request: PartnerAdLoadRequest, partnerAdDelegate: PartnerAdDelegate) {
        self.adapter = adapter
        self.request = request
        self.partnerAdDelegate = partnerAdDelegate
        
        super.init()
    }
    
    /// Attempt to load an ad.
    /// - Parameters:
    ///   - completion: The completion handler to notify Helium of ad load completion result.
    func load(completion: @escaping (Result<PartnerAd, Error>) -> Void) {
        guard let adSpot = request.format == .banner
                ? createBannerAdSpot(placement: request.partnerPlacement)
                : createFullscreenAdSpot(placement: request.partnerPlacement) else {
                    let error = self.error(.loadFailure(request), description: "Ad spot is nil.")
                    
                    log(.loadFailed(request, error: error))
                    completion(.failure(error))
                    
                    return
                }
                
        let ad = request.format == .banner ? viewUnitController : fullscreenUnitController
        partnerAd = PartnerAd(ad: ad, details: [:], request: request)
        
        adSpot.fetchAd(completion: { adSpot, adModel, error in
            let succeeded = error == nil
            let error = self.error(.loadFailure(self.request), error: error)
            
            self.log(succeeded ? .loadSucceeded(self.partnerAd) : .loadFailed(self.request, error: error))
            completion(succeeded ? .success(self.partnerAd) : .failure(error))
        })
    }
    
    /// Attempt to show the currently loaded ad.
    /// - Parameters:
    ///   - viewController: The ViewController for ad presentation purposes.
    ///   - completion: The completion handler to notify Helium of ad show completion result.
    func show(viewController: UIViewController, completion: @escaping (Result<PartnerAd, Error>) -> Void) {
        self.viewController = viewController
        
        showCompletion = { [weak self] result in
            if let self = self {
                do {
                    self.log(.showSucceeded(try result.get()))
                } catch {
                    self.log(.showFailed(self.partnerAd, error: error))
                }
            }
            
            self?.showCompletion = nil
            completion(result)
        }
        
        switch request.format {
        case .banner:
            /// Banner does not have a separate show mechanism
            log(.showSucceeded(partnerAd))
            completion(.success(partnerAd))
        case .interstitial, .rewarded:
            showFullscreenAd()
        }
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
    
    /// Build an MRAID content controller.
    /// - Returns: An MRAID content controller for the current Helium ad load.
    func buildMraidContentController() -> IAMRAIDContentController? {
        IAMRAIDContentController.build { builder in
            builder.mraidContentDelegate = self
        }
    }
    
    /// Build a video unit controller.
    /// - Returns: A video unit controller for the current Helium ad load.
    func buildViewUnitController() -> IAViewUnitController? {
        IAViewUnitController.build { builder in
            builder.unitDelegate = self
            builder.addSupportedContentController(self.mraidContentController)
        }
    }
    
    /// Build a video content controller.
    /// - Returns: A video content controller for the current Helium ad load.
    func buildVideoContentController() -> IAVideoContentController? {
        IAVideoContentController.build { builder in
            builder.videoContentDelegate = self
        }
    }
    
    /// Build a fullscreen unit controller.
    /// - Returns: A fullscreen unit controller for the current Helium ad load.
    func buildFullscreenUnitController() -> IAFullscreenUnitController? {
        IAFullscreenUnitController.build { builder in
            builder.unitDelegate = self
            builder.addSupportedContentController(self.videoContentController)
            builder.addSupportedContentController(self.mraidContentController)
        }
    }
    
    // MARK: - IAUnitDelegate
    
    func iaParentViewController(for unitController: IAUnitController?) -> UIViewController {
        if let viewController = viewController {
            return viewController
        }
    }
    
    private func IAAdDidReceiveClick(unitController: IAUnitController) {
        log(.didClick(partnerAd, error: nil))
        partnerAdDelegate?.didClick(partnerAd) ?? log(.delegateUnavailable)
    }
    
    private func IAAdWillLogImpression(unitController: IAUnitController) {
        log(.didTrackImpression(partnerAd))
        partnerAdDelegate?.didTrackImpression(partnerAd) ?? log(.delegateUnavailable)
    }
    
    private func IAAdDidReward(unitController: IAUnitController) {
        if (request.format == .rewarded) {
            let reward = Reward(amount: 1, label: "")
            
            log(.didReward(partnerAd, reward: reward))
            partnerAdDelegate?.didReward(partnerAd, reward: reward) ?? log(.delegateUnavailable)
        }
    }
    
    private func IAUnitControllerWillPresentFullscreen(unitController: IAUnitController) {
        log("IAUnitControllerWillPresentFullscreen")
    }
    
    private func IAUnitControllerDidPresentFullscreen(unitController: IAUnitController) {
        showCompletion?(.success(partnerAd)) ?? log(.showResultIgnored)
        showCompletion = nil
    }
    
    private func IAUnitControllerWillDismissFullscreen(unitController: IAUnitController) {
        log("IAUnitControllerWillDismissFullscreen")
    }
    
    private func IAUnitControllerDidDismissFullscreen(unitController: IAUnitController) {
        log(.didDismiss(partnerAd, error: nil))
        partnerAdDelegate?.didDismiss(partnerAd, error: nil) ?? log(.delegateUnavailable)
    }
    
    private func IAUnitControllerWillOpenExternalApp(unitController: IAUnitController) {
        log("IAUnitControllerWillOpenExternalApp")
    }
    
    private func IAAdDidExpire(unitController: IAUnitController) {
        log(.didExpire(partnerAd))
        partnerAdDelegate?.didExpire(partnerAd) ?? log(.delegateUnavailable)
    }
}
