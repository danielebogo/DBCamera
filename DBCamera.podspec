Pod::Spec.new do |s|
  s.name = 'DBCamera'
  s.version = '2.2.1'
  s.license = 'MIT'
  s.summary = 'DBCamera is a simple custom camera with AVFoundation'
  s.homepage = 'https://github.com/danielebogo/DBCamera'
  s.author = { 'Daniele Bogo' => 'daniele@paperstreetsoapdesign.com' }
  s.source = { :git => 'https://github.com/danielebogo/DBCamera.git', :tag => '2.2.1' }
  s.platform = :ios, '6.0'
  s.requires_arc = true

  s.source_files = 'DBCamera/Categories/*.{h,m}', 'DBCamera/Controllers/*.{h,m}', 'DBCamera/Headers/*.{h,m}', 'DBCamera/Managers/*.{h,m}', 'DBCamera/Objects/*.{h,m}', 'DBCamera/Views/*.{h,m}', 'DBCamera/Filters/*.{h,m}'
  s.resource = ['DBCamera/Resources/*.{xib,xcassets}', 'DBCamera/Localizations/**', 'DBCamera/Filters/*.{acv}']
  s.framework = 'AVFoundation', 'CoreMedia', 'OpenGLES', 'AVFoundation', 'QuartzCore'
  s.dependency 'GPUImage', '~> 0.1'
end
