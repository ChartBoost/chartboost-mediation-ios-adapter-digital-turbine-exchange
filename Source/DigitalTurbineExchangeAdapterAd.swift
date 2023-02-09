// Copyright 2022-2023 Chartboost, Inc.
// 
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file.

import ChartboostMediationSDK
import Foundation
import IASDKCore
import UIKit

/// Base class for Chartboost Mediation Digital Turbine Exchange adapter ads.
class DigitalTurbineExchangeAdapterAd: NSObject, IAUnitDelegate {
    
    /// The partner adapter that created this ad.
    let adapter: PartnerAdapter
    
    /// The ad load request associated to the ad.
    /// It should be the one provided on `PartnerAdapter.makeAd(request:delegate:)`.
    let request: PartnerAdLoadRequest
    
    /// The ViewController for ad presentation purposes.
    weak var viewController: UIViewController?
    
    /// The partner ad delegate to send ad life-cycle events to.
    /// It should be the one provided on `PartnerAdapter.makeAd(request:delegate:)`.
    weak var delegate: PartnerAdDelegate?
    
    /// The completion handler to notify Chartboost Mediation of ad show completion result.
    var showCompletion: ((Result<PartnerEventDetails, Error>) -> Void)?
    
    /// Create a new instance of the adapter.
    /// - Parameters:
    ///   - adapter: The current adapter instance
    ///   - request: The current AdLoadRequest containing data relevant to the curent ad request
    ///   - partnerAdDelegate: The partner ad delegate to notify Chartboost Mediation of ad lifecycle events.
    init(adapter: PartnerAdapter, request: PartnerAdLoadRequest, delegate: PartnerAdDelegate) {
        self.adapter = adapter
        self.request = request
        self.delegate = delegate
    }
    
    func iaParentViewController(for unitController: IAUnitController?) -> UIViewController {
        if let viewController = self.viewController {
            return viewController
        } else {
            if var topController = UIApplication.shared.keyWindow?.rootViewController {
                while let presentedViewController = topController.presentedViewController {
                    topController = presentedViewController
                }
                
                return topController
            }
            
            return UIViewController()
        }
    }
}
