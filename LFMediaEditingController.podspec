Pod::Spec.new do |s|
s.name         = 'LFMediaEditingController'
s.version      = '1.0.5'
s.summary      = 'Media Editor (edit photo、edit video)'
s.homepage     = 'https://github.com/lincf0912/LFMediaEditingController'
s.license      = 'MIT'
s.author       = { 'lincf0912' => 'dayflyking@163.com' }
s.platform     = :ios
s.ios.deployment_target = '7.0'
s.source       = { :git => 'https://github.com/lincf0912/LFMediaEditingController.git', :tag => s.version, :submodules => true }
s.requires_arc = true
s.source_files = 'LFMediaEditingController/class/*.{h,m}'
s.public_header_files = 'LFMediaEditingController/class/*.h'

# LFPhotoEditingController模块
s.subspec 'LFPhotoEditingController' do |ss|
ss.resources    = 'LFMediaEditingController/class/LFPhotoEditingController/*.bundle'
ss.source_files = 'LFMediaEditingController/class/*.{h,m}','LFMediaEditingController/class/LFPhotoEditingController/**/*.{h,m}'
ss.public_header_files = 'LFMediaEditingController/class/*.h','LFMediaEditingController/class/LFPhotoEditingController/controller/*.h','LFMediaEditingController/class/LFPhotoEditingController/model/*.h'
ss.dependency 'LFMediaEditingController/JRPickColorView'
end

# JRPickColorView模块
s.subspec 'JRPickColorView' do |ss|
ss.source_files = 'LFMediaEditingController/class/vendors/JRPickColorView/*.{h,m}'
ss.public_header_files = 'LFMediaEditingController/class/vendors/JRPickColorView/JRPickColorView.h'
end

end
