Pod::Spec.new do |s|
  s.name             = 'ffmpeg_kit_flutter'
  s.version          = '6.0.0'
  s.summary          = 'FFmpeg Kit for Flutter'
  s.description      = 'FFmpeg Kit Flutter plugin using local build'
  s.homepage         = 'https://github.com/anonfaded/ffmpeg-kit'
  s.license          = { :type => 'LGPL-3.0' }
  s.author           = { 'Your Name' => 'your.email@example.com' }
  s.source           = { :path => '.' }
  s.platform         = :ios, '12.1'

  # Point to the locally built framework - ADJUST THIS PATH
  s.vendored_frameworks = '/Users/macbookpro2018/Desktop/Desktop_SadafMacBookPro/Development/ffmpeg_builds/ffmpeg-kit/prebuilt/bundle-apple-framework-ios/*.framework'

  s.dependency 'Flutter'

  s.ios.frameworks = 'Foundation', 'AVFoundation', 'AudioToolbox', 'CoreMedia', 'VideoToolbox'
  s.ios.libraries = 'z', 'c++'

  s.static_framework = true
  s.requires_arc = true
end