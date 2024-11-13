#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint live_flutter_plugin.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'live_flutter_plugin'
  s.version          = '1.0.0'
  s.summary          = '腾讯云实时音视频插件'
  s.description      = <<-DESC
  腾讯云实时音视频插件
                       DESC
  s.homepage         = 'https://cloud.tencent.com/product/mlvb'
  s.license          = { :file => '../LICENSE' }
  s.author           = 'tencent video cloud'
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  
  s.platform = :ios, '9.0'
  
  s.static_framework = true

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
  
  # live
  s.vendored_frameworks = '**/*.framework'
  s.dependency 'TXLiteAVSDK_Professional', '11.9.15963'
  s.dependency 'TXCustomBeautyProcesserPlugin'
  
end

