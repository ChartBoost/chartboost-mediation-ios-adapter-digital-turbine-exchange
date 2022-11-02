
//
//  DigitalTurbineExchangeAdapterAd.swift
//  ChartboostHeliumAdapterDigitalTurbineExchange
//
//  Created by Vu Chau on 9/13/22.
//

import Foundation
import HeliumSdk
import UIKit
import IASDKCore

/// Base class for Helium Digital Turbine Exchange adapter ads.
class DigitalTurbineExchangeAdapterAd: NSObject {
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
    
    /// The completion handler to notify Helium of ad load completion result.
    var loadCompletion: ((Result<PartnerEventDetails, Error>) -> Void)?
    
    /// The completion handler to notify Helium of ad show completion result.
    var showCompletion: ((Result<PartnerEventDetails, Error>) -> Void)?
    
    /// Create a new instance of the adapter.
    /// - Parameters:
    ///   - adapter: The current adapter instance
    ///   - request: The current AdLoadRequest containing data relevant to the curent ad request
    ///   - partnerAdDelegate: The partner ad delegate to notify Helium of ad lifecycle events.
    init(adapter: PartnerAdapter, request: PartnerAdLoadRequest, delegate: PartnerAdDelegate) {
        self.adapter = adapter
        self.request = request
        self.delegate = delegate
    }
}
