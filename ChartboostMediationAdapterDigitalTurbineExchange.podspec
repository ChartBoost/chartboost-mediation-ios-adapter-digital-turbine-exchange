Pod::Spec.new do |spec|
  spec.name        = 'ChartboostMediationAdapterDigitalTurbineExchange'
  spec.version     = '4.8.2.1.0'
  spec.license     = { :type => 'MIT', :file => 'LICENSE.md' }
  spec.homepage    = 'https://github.com/ChartBoost/chartboost-mediation-ios-adapter-digital-turbine-exchange'
  spec.authors     = { 'Chartboost' => 'https://www.chartboost.com/' }
  spec.summary     = 'Chartboost Mediation iOS SDK Digital Turbine Exchange adapter.'
  spec.description = 'Digital Turbine Exchange Adapters for mediating through Chartboost Mediation. Supported ad formats: Banner, Interstitial, and Rewarded.'

  # Source
  spec.module_name  = 'ChartboostMediationAdapterDigitalTurbineExchange'
  spec.source       = { :git => 'https://github.com/ChartBoost/chartboost-mediation-ios-adapter-digital-turbine-exchange.git', :tag => spec.version }
  spec.source_files = 'Source/**/*.{swift}'

  # Minimum supported versions
  spec.swift_version         = '5.0'
  spec.ios.deployment_target = '11.0'

  # System frameworks used
  spec.ios.frameworks = ['Foundation', 'SafariServices', 'UIKit', 'WebKit']
  
  # This adapter is compatible with all Chartboost Mediation 4.X versions of the SDK.
  spec.dependency 'ChartboostMediationSDK', '~> 4.0'

  # Partner network SDK and version that this adapter is certified to work with.
  spec.dependency 'Fyber_Marketplace_SDK', '~> 8.2.1'

  # The partner network SDK is a static framework which requires the static_framework option.
  spec.static_framework = true
end
