// Copyright 2022-2024 Chartboost, Inc.
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file.

import ChartboostMediationSDK
import Foundation
import IASDKCore
import UIKit

/// The Chartboost Mediation Digital Turbine Exchange adapter interstitial ad.
final class DigitalTurbineExchangeAdapterFullscreenAd:
    DigitalTurbineExchangeAdapterAd,
    PartnerFullscreenAd,
    IAVideoContentDelegate,
    IAMRAIDContentDelegate
{
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
    func load(with viewController: UIViewController?, completion: @escaping (Error?) -> Void) {
        log(.loadStarted)

        videoContentController = IAVideoContentController.build { builder in
            builder.videoContentDelegate = self
        }
        guard let videoContentController else {
            let error = self.error(.loadFailureUnknown, description: "Video content controller is nil.")
            self.log(.loadFailed(error))
            completion(error)
            return
        }

        mraidContentController = IAMRAIDContentController.build { builder in
            builder.mraidContentDelegate = self
        }
        guard let mraidContentController else {
            let error = self.error(.loadFailureUnknown, description: "MRAID content controller is nil.")
            self.log(.loadFailed(error))
            completion(error)
            return
        }

        viewUnitController = IAViewUnitController.build { builder in
            builder.unitDelegate = self
            builder.addSupportedContentController(mraidContentController)
        }
        guard let viewUnitController else {
            let error = self.error(.loadFailureUnknown, description: "View unit controller is nil.")
            self.log(.loadFailed(error))
            completion(error)
            return
        }

        fullscreenUnitController = IAFullscreenUnitController.build { builder in
            builder.unitDelegate = self
            builder.addSupportedContentController(mraidContentController)
            builder.addSupportedContentController(videoContentController)
        }
        guard let fullscreenUnitController else {
            let error = self.error(.loadFailureUnknown, description: "Fullscreen unit controller is nil.")
            self.log(.loadFailed(error))
            completion(error)
            return
        }

        guard let adRequest = self.buildAdRequest(placement: self.request.partnerPlacement) else {
            let error = self.error(.loadFailureInvalidAdRequest, description: "Ad request is nil.")

            self.log(.loadFailed(error))
            completion(error)

            return
        }

        adSpot = IAAdSpot.build { builder in
            builder.adRequest = adRequest
            builder.addSupportedUnitController(fullscreenUnitController)
            builder.addSupportedUnitController(viewUnitController)
        }

        adSpot?.fetchAd { [weak self] _, _, error in
            if let error {
                self?.log(.loadFailed(error))
                completion(error)
            } else {
                self?.log(.loadSucceeded)
                completion(nil)
            }
        }
    }

    /// Shows a loaded ad.
    /// Chartboost Mediation SDK will always call this method from the main thread.
    /// - parameter viewController: The view controller on which the ad will be presented on.
    /// - parameter completion: Closure to be performed once the ad has been shown.
    func show(with viewController: UIViewController, completion: @escaping (Error?) -> Void) {
        log(.showStarted)

        self.viewController = viewController
        showCompletion = completion

        if let ad = fullscreenUnitController {
            ad.showAd(animated: true)
        } else {
            let error = error(.showFailureAdNotReady)

            log(.showFailed(error))
            completion(error)
        }
    }

    /// Build a partner ad request.
    /// - Parameter placement: The placement ID for the ad request.
    /// - Returns: A partner ad request for the current Chartboost Mediation ad load.
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
        delegate?.didClick(self) ?? log(.delegateUnavailable)
    }

    func iaAdWillLogImpression(_ unitController: IAUnitController?) {
        log(.didTrackImpression)
        delegate?.didTrackImpression(self) ?? log(.delegateUnavailable)
    }

    func iaAdDidReward(_ unitController: IAUnitController?) {
        if request.format == PartnerAdFormats.rewarded {
            log(.didReward)
            delegate?.didReward(self) ?? log(.delegateUnavailable)
        }
    }

    func iaUnitControllerWillPresentFullscreen(_ unitController: IAUnitController?) {
        log(.delegateCallIgnored)
    }

    func iaUnitControllerDidPresentFullscreen(_ unitController: IAUnitController?) {
        log(.showSucceeded)
        showCompletion?(nil) ?? log(.showResultIgnored)
        showCompletion = nil
    }

    func iaUnitControllerWillDismissFullscreen(_ unitController: IAUnitController?) {
        log(.delegateCallIgnored)
    }

    func iaUnitControllerDidDismissFullscreen(_ unitController: IAUnitController?) {
        log(.didDismiss(error: nil))
        delegate?.didDismiss(self, error: nil) ?? log(.delegateUnavailable)
    }

    func iaUnitControllerWillOpenExternalApp(_ unitController: IAUnitController?) {
        log(.delegateCallIgnored)
    }

    func iaAdDidExpire(_ unitController: IAUnitController?) {
        log(.didExpire)
        delegate?.didExpire(self) ?? log(.delegateUnavailable)
    }
}
