Pod::Spec.new do |spec|
  spec.name        = 'ChartboostMediationAdapterDigitalTurbineExchange'
  spec.version     = '5.8.5.0.0'
  spec.license     = { :type => 'MIT', :file => 'LICENSE.md' }
  spec.homepage    = 'https://github.com/ChartBoost/chartboost-mediation-ios-adapter-digital-turbine-exchange'
  spec.authors     = { 'Chartboost' => 'https://www.chartboost.com/' }
  spec.summary     = 'Chartboost Mediation iOS SDK Digital Turbine Exchange adapter.'
  spec.description = 'Digital Turbine Exchange Adapters for mediating through Chartboost Mediation. Supported ad formats: Banner, Interstitial, and Rewarded.'

  # Source
  spec.module_name  = 'ChartboostMediationAdapterDigitalTurbineExchange'
  spec.source       = { :git => 'https://github.com/ChartBoost/chartboost-mediation-ios-adapter-digital-turbine-exchange.git', :tag => spec.version }
  spec.source_files = 'Source/**/*.{swift}'
  spec.resource_bundles = { 'ChartboostMediationAdapterDigitalTurbineExchange' => ['PrivacyInfo.xcprivacy'] }

  # Minimum supported versions
  spec.swift_version         = '5.0'
  spec.ios.deployment_target = '15.0'

  # System frameworks used
  spec.ios.frameworks = ['Foundation', 'SafariServices', 'UIKit', 'WebKit']

  # Dependencies
  spec.dependency 'ChartboostMediationSDK', '~> 5.0'
  spec.dependency 'Fyber_Marketplace_SDK', '~> 8.5.0'

  spec.static_framework = true
end
