Pod::Spec.new do |s|
  s.name = 'HamsterUIKit'
  s.module_name = 'HamsterUIKit'
  s.version = '1.0'
  s.license = 'Apache'
  s.summary = 'A simple and elegant UIKit(Charts) for iOS'
  s.homepage = 'https://github.com/Howardw3/HamsterUIKit'
  s.authors = { 'Howard Wang' => 'https://github.com/Howardw3' }
  s.source = { :git => 'https://github.com/Howardw3/HamsterUIKit.git', :tag => "v#{s.version}" }
  s.ios.deployment_target = '10.0'
  s.source_files = 'HamsterUIKit/*.swift'
end
