#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint pangle_flutter.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'pangle_flutter'
  s.version          = '0.3.6'
  s.summary          = 'Flutter plugin for Pangle Ad SDK.'
  s.description      = <<-DESC
Flutter plugin for Pangle Ad SDK.
                       DESC
  s.homepage         = 'https://github.com/nullptrX/pangle_flutter'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'nullptrX' => 'nullptrxxx@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '9.0'

  s.static_framework = true
  s.ios.dependency 'Bytedance-UnionAD', '~> 3.2.0.1'

  # Flutter.framework does not contain a i386 slice. Only x86_64 simulators are supported.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }
  s.swift_version = '5.0'
end
