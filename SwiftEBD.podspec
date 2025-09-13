
Pod::Spec.new do |s|
  s.name             = 'SwiftEBD'
  s.swift_versions   = ['5.0']
  s.version          = '1.1.1'
  s.summary          = 'Eye Blink Detector for Swift using ARKit'
  s.description      = <<-DESC
    SwiftEBD is a lightweight Swift library that lets you detect left, right, or both eye blinks using ARKit’s TrueDepth camera.
    It is useful for accessibility features, gesture-based controls, and AR interactions.
  DESC
  s.homepage         = 'https://github.com/minguking/SwiftEBD'
  s.license          = { :type => 'MIT', :file => 'LICENSE.md' }
  s.author           = { 'minguking' => 'minqu.kang@gmail.com' }
  s.source           = { :git => 'https://github.com/minguking/SwiftEBD.git', :tag => s.version.to_s }
  s.platform         = :ios, '13.0'
  s.source_files     = 'Sources/SwiftEBD/**/*.{swift}'
end
