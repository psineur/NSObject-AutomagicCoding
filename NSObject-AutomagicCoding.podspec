Pod::Spec.new do |s|
  s.name     = 'NSObject-AutomagicCoding'
  s.version  = '1.1'
  s.license  = 'MIT'
  s.summary  = 'Very easy to use NSCoding replacement for Mac and iOS Projects'
  s.homepage = 'https://github.com/psineur/NSObject-AutomagicCoding'
  s.source   = { :git => 'https://github.com/psineur/NSObject-AutomagicCoding.git', :tag => 'v1.1' }
  s.platform = :ios
  s.source_files = 'NSObject+AutoMagicCoding.{h,m}'
end
