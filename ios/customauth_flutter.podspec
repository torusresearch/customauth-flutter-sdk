#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint torus_direct.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'customauth_flutter'
  s.version          = '1.0.0'
  s.summary          = 'CustomAuth plugin for flutter.'
  s.description      = <<-DESC
  Flutter plugin for CustomAuth.
                       DESC
  s.homepage         = 'https://tor.us'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Torus Labs' => 'shubham@tor.us' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'CustomAuth', '~> 6.0.0'
  s.platform = :ios, '14.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
