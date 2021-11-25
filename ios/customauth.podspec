#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint torus_direct.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'customauth'
  s.version          = '0.0.2'
  s.summary          = 'A new flutter plugin project.'
  s.description      = <<-DESC
  Flutter plugin on torus-direct-swift-sdk
                       DESC
  s.homepage         = 'https://app.tor.us'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Torus Labs' => 'shubham@tor.us' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'Torus-directSDK', '~> 1.1.3'
  s.platform = :ios, '11.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
