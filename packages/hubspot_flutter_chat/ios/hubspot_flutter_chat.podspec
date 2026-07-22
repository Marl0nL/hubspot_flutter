#
# hubspot_flutter chat plugin — iOS podspec.
#
# HubSpot ships its iOS mobile chat SDK via **Swift Package Manager only** (there
# is no CocoaPods pod), so the SDK dependency is declared in
# `hubspot_flutter_chat/Package.swift`, not here. iOS integration therefore requires
# Flutter's Swift Package Manager support (the default for new iOS projects).
# This podspec exists so the plugin is still discoverable in CocoaPods-based
# projects; add the HubSpot SDK via SPM in that case.
#
Pod::Spec.new do |s|
  s.name             = 'hubspot_flutter_chat'
  s.version          = '0.1.0'
  s.summary          = 'Flutter bridge for HubSpot native mobile chat SDKs.'
  s.description      = <<-DESC
Flutter plugin bridging HubSpot's native iOS & Android mobile chat SDKs via
type-safe Pigeon platform channels.
                       DESC
  s.homepage         = 'https://github.com/Marl0nL/hubspot_flutter'
  s.license          = { :file => '../LICENSE' }
  s.author           = 'Marl0nL'
  s.source           = { :path => '.' }
  s.source_files = 'hubspot_flutter_chat/Sources/hubspot_flutter_chat/**/*.swift'
  s.dependency 'Flutter'
  s.platform = :ios, '13.0'

  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
