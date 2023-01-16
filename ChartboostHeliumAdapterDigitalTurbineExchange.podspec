Pod::Spec.new do |spec|
  spec.name        = 'ChartboostHeliumAdapterDigitalTurbineExchange'
  spec.version     = '4.8.1.7.0'
  spec.license     = { :type => 'MIT', :file => 'LICENSE.md' }
  spec.homepage    = 'https://github.com/ChartBoost/helium-ios-adapter-digital-turbine-exchange'
  spec.authors     = { 'Chartboost' => 'https://www.chartboost.com/' }
  spec.summary     = 'Helium iOS SDK Digital Turbine Exchange adapter.'
  spec.description = 'Digital Turbine Exchange Adapters for mediating through Helium. Supported ad formats: Banner, Interstitial, and Rewarded.'

  # Source
  spec.module_name  = 'HeliumAdapterDigitalTurbineExchange'
  spec.source       = { :git => 'https://github.com/ChartBoost/helium-ios-adapter-digital-turbine-exchange.git', :tag => '#{spec.version}' }
  spec.source_files = 'Source/**/*.{swift}'

  # Minimum supported versions
  spec.swift_version         = '5.0'
  spec.ios.deployment_target = '10.0'

  # System frameworks used
  spec.ios.frameworks = ['Foundation', 'SafariServices', 'UIKit', 'WebKit']
  
  # This adapter is compatible with all Helium 4.X versions of the SDK.
  spec.dependency 'ChartboostHelium', '~> 4.0'

  # Partner network SDK and version that this adapter is certified to work with.
  spec.dependency 'Fyber_Marketplace_SDK', '8.1.7'

  # The partner network SDK is a static framework which requires the static_framework option.
  spec.static_framework = true
end
