#
# Be sure to run `pod lib lint GlobalPayments-iOS-SDK.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'GlobalPayments-iOS-SDK'
  s.version          = '3.1.3'
  s.summary          = 'The official Global Payments iOS SDK for GP-API.'
  s.swift_version    = '5.0'

  s.homepage         = 'https://github.com/globalpayments/ios-sdk'
  s.license          = { :type => 'GNU', :file => 'LICENSE.md' }
  s.author           = { 'Global Payments' => 'api.integrations@globalpay.com' }
  s.source           = { :git => 'https://github.com/globalpayments/ios-sdk.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'
  s.source_files 		= 'GlobalPayments-iOS-SDK/Classes/**/*'
end
