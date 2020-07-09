#
# Be sure to run `pod lib lint DashdevsNetworking.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'DashdevsNetworking'
  s.version          = '0.0.7'
  s.summary          = 'Library for organising network layer in iOS apps'

  s.homepage         = 'https://dashdevs.com'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'dashdevs llc' => 'hello@dashdevs.com' }
  s.source           = { :git => 'https://github.com/itomych/dashdevsnetworking', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'

  s.swift_version = '4.0'

  s.source_files = 'DashdevsNetworking/Classes/**/*'
end
