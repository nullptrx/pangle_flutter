#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint pangle_flutter.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'pangle_flutter'
  s.version          = '3.0.2'
  s.summary          = 'Flutter plugin for Pangle Ad SDK.'
  s.description      = <<-DESC
Flutter plugin for Pangle Ad SDK.
                       DESC
  s.homepage         = 'https://github.com/nullptrx/pangle_flutter'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'nullptrX' => '19757745+nullptrx@users.noreply.github.com' }
  s.source           = { :path => '.' }
  s.source_files = 'pangle_flutter/Sources/pangle_flutter/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '13.0'

  s.static_framework = true

  # https://cocoapods.org/
  s.ios.dependency 'Ads-CN-Beta/BUAdSDK', '~> 7.0'
  s.ios.dependency 'Ads-CN-Beta/CSJMediation', '~> 7.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.9'
  s.resource_bundles = {'pangle_flutter_privacy' => ['pangle_flutter/Sources/pangle_flutter/PrivacyInfo.xcprivacy']}
end
