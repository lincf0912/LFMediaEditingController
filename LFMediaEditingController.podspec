Pod::Spec.new do |s|
s.name         = 'LFMediaEditingController'
s.version      = '1.4.0.2'
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
ss.resources    = 'LFMediaEditingController/class/common/*.bundle'
ss.source_files = 'LFMediaEditingController/class/*.{h,m}','LFMediaEditingController/class/LFPhotoEditingController/**/*.{h,m}','LFMediaEditingController/class/common/**/*.{h,m}','LFMediaEditingController/class/LFVideoEditingController/view/subView/LFDataFilterVideoView.{h,m}'
ss.public_header_files = 'LFMediaEditingController/class/*.h','LFMediaEditingController/class/LFPhotoEditingController/controller/*.h','LFMediaEditingController/class/LFPhotoEditingController/model/*.h','LFMediaEditingController/class/LFPhotoEditingController/view/subView/LFDataFilterImageView.h','LFMediaEditingController/class/LFVideoEditingController/view/subView/LFDataFilterVideoView.h','LFMediaEditingController/class/common/utils/FilterSuiteUtils/*.h'
ss.dependency 'LFMediaEditingController/JRPickColorView'
ss.dependency 'LFMediaEditingController/JRFilterBar'
ss.dependency 'LFMediaEditingController/LFColorMatrix'
ss.dependency 'LFMediaEditingController/LFFilterSuite'
ss.dependency 'LFMediaEditingController/LFMediaDisplayView'
ss.dependency 'LFMediaEditingController/LFImageCoder'
ss.dependency 'LFMediaEditingController/LFPresentationCategory'
ss.dependency 'LFMediaEditingController/LFEasyNoticeBar'
ss.dependency 'LFMediaEditingController/DropDownMenu'
end

# LFVideoEditingController模块
s.subspec 'LFVideoEditingController' do |ss|
ss.resources    = 'LFMediaEditingController/class/common/*.bundle'
ss.source_files = 'LFMediaEditingController/class/*.{h,m}','LFMediaEditingController/class/LFVideoEditingController/**/*.{h,m}','LFMediaEditingController/class/common/**/*.{h,m}','LFMediaEditingController/class/LFPhotoEditingController/view/model/*.{h,m}','LFMediaEditingController/class/LFPhotoEditingController/view/other/**/*.{h,m}','LFMediaEditingController/class/LFPhotoEditingController/view/subView/*.{h,m}','LFMediaEditingController/class/LFPhotoEditingController/view/toolBar/*.{h,m}'
ss.public_header_files = 'LFMediaEditingController/class/*.h','LFMediaEditingController/class/LFVideoEditingController/controller/*.h','LFMediaEditingController/class/LFVideoEditingController/model/*.h','LFMediaEditingController/class/LFPhotoEditingController/view/subView/LFDataFilterImageView.h','LFMediaEditingController/class/LFVideoEditingController/view/subView/LFDataFilterVideoView.h','LFMediaEditingController/class/common/utils/FilterSuiteUtils/*.h'
ss.dependency 'LFMediaEditingController/JRPickColorView'
ss.dependency 'LFMediaEditingController/JRFilterBar'
ss.dependency 'LFMediaEditingController/LFColorMatrix'
ss.dependency 'LFMediaEditingController/LFFilterSuite'
ss.dependency 'LFMediaEditingController/LFMediaDisplayView'
ss.dependency 'LFMediaEditingController/LFPresentationCategory'
ss.dependency 'LFMediaEditingController/LFEasyNoticeBar'
ss.dependency 'LFMediaEditingController/DropDownMenu'
end

# JRPickColorView模块
s.subspec 'JRPickColorView' do |ss|
ss.source_files = 'LFMediaEditingController/class/vendors/JRPickColorView/*.{h,m}'
ss.public_header_files = 'LFMediaEditingController/class/vendors/JRPickColorView/JRPickColorView.h'
end

# JRFilterBar模块
s.subspec 'JRFilterBar' do |ss|
ss.source_files = 'LFMediaEditingController/class/vendors/JRFilterBar/*.{h,m}','LFMediaEditingController/class/vendors/JRFilterBar/**/*.{h,m}'
ss.public_header_files = 'LFMediaEditingController/class/vendors/JRFilterBar/JRFilterBar.h'
end

# LFColorMatrix模块
s.subspec 'LFColorMatrix' do |ss|
ss.source_files = 'LFMediaEditingController/class/vendors/ColorMatrix/*.{h,m}'
ss.public_header_files = 'LFMediaEditingController/class/vendors/ColorMatrix/*.h'
end

# LFFilterSuite模块
s.subspec 'LFFilterSuite' do |ss|
ss.source_files = 'LFMediaEditingController/class/vendors/LFFilterSuite/*.{h,m}','LFMediaEditingController/class/vendors/LFFilterSuite/**/*.{h,m}'
ss.public_header_files = 'LFMediaEditingController/class/vendors/LFFilterSuite/*.h','LFMediaEditingController/class/vendors/LFFilterSuite/**/*.h'
end

# LFMediaDisplayView模块
s.subspec 'LFMediaDisplayView' do |ss|
ss.source_files = 'LFMediaEditingController/class/vendors/LFMediaDisplayView/*.{h,m}','LFMediaEditingController/class/vendors/LFMediaDisplayView/**/*.{h,m}'
ss.public_header_files = 'LFMediaEditingController/class/vendors/LFMediaDisplayView/*.h'
ss.resources = 'LFMediaEditingController/class/vendors/LFMediaDisplayView/resource/*.bundle'
end

# LFImageCoder模块
s.subspec 'LFImageCoder' do |ss|
ss.source_files = 'LFMediaEditingController/class/vendors/LFImageCoder/*.{h,m}','LFMediaEditingController/class/vendors/LFImageCoder/**/*.{h,m}'
ss.public_header_files = 'LFMediaEditingController/class/vendors/LFImageCoder/*.h'
end

# LFPresentationCategory模块
s.subspec 'LFPresentationCategory' do |ss|
ss.source_files = 'LFMediaEditingController/class/vendors/LFPresentationCategory/*.{h,m}','LFMediaEditingController/class/vendors/LFPresentationCategory/**/*.{h,m}'
ss.public_header_files = 'LFMediaEditingController/class/vendors/LFPresentationCategory/*.h'
end

# LFEasyNoticeBar模块
s.subspec 'LFEasyNoticeBar' do |ss|
ss.source_files = 'LFMediaEditingController/class/vendors/LFEasyNoticeBar/*.{h,m}','LFMediaEditingController/class/vendors/LFEasyNoticeBar/**/*.{h,m}'
ss.public_header_files = 'LFMediaEditingController/class/vendors/LFEasyNoticeBar/*.h'
ss.resources = 'LFMediaEditingController/class/vendors/LFEasyNoticeBar/*.bundle'
end

# DropDownMenu模块
s.subspec 'DropDownMenu' do |ss|
ss.source_files = 'LFMediaEditingController/class/vendors/DropDownMenu/*.{h,m}','LFMediaEditingController/class/vendors/DropDownMenu/**/*.{h,m}'
ss.public_header_files = 'LFMediaEditingController/class/vendors/DropDownMenu/*.h','LFMediaEditingController/class/vendors/DropDownMenu/Header/*.h','LFMediaEditingController/class/vendors/DropDownMenu/protocol/*.h','LFMediaEditingController/class/vendors/DropDownMenu/model/*.h'
end

end
