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
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

  # If your plugin requires a privacy manifest, for example if it uses any
  # required reason APIs, update the PrivacyInfo.xcprivacy file to describe your
  # plugin's privacy impact, and then uncomment this line. For more information,
  # see https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
  # s.resource_bundles = {'circom_witnesscalc_privacy' => ['Resources/PrivacyInfo.xcprivacy']}

  s.dependency 'CircomWitnesscalc', '0.0.1-alpha.2'
end
