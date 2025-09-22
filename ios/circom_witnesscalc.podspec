#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint circom_witnesscalc.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'circom_witnesscalc'
  s.version          = '0.0.1'
  s.summary          = 'circom_witnesscalc plugin for Flutter.'
  s.description      = <<-DESC
circom_witnesscalc plugin for Flutter. This plugin is used to calculate the witness for a given circuit and input.
                       DESC
  s.homepage         = 'https://github.com/iden3/circom-witnesscalc-flutter'
  s.license          = { :file => '../LICENSE-MIT' }
  s.author           = { 'Iden3' => 'hello@iden3.io' }

  s.source           = { :path => '.' }
  s.source_files = 'circom_witnesscalc/Sources/circom_witnesscalc/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

  s.dependency 'CircomWitnesscalc', '0.0.1-alpha.3'
end
