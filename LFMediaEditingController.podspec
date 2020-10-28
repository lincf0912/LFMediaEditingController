Pod::Spec.new do |s|
s.name         = 'LFMediaEditingController'
s.version      = '1.4.6'
s.summary      = 'Media Editor (edit photo、edit video)'
s.homepage     = 'https://github.com/lincf0912/LFMediaEditingController'
s.license      = 'MIT'
s.author       = { 'lincf0912' => 'dayflyking@163.com' }
s.platform     = :ios
s.ios.deployment_target = '7.0'
s.source       = { :git => 'https://github.com/lincf0912/LFMediaEditingController.git', :tag => s.version, :submodules => true }
s.requires_arc = true
s.source_files = 'LFMediaEditingController/LFMediaEditingController/class/*.{h,m}'
s.public_header_files = 'LFMediaEditingController/LFMediaEditingController/class/*.h'

# LFPhotoEditingController模块
s.subspec 'LFPhotoEditingController' do |ss|
ss.resources    = 'LFMediaEditingController/LFMediaEditingController/class/common/*.bundle'
ss.source_files = 'LFMediaEditingController/LFMediaEditingController/class/*.{h,m}','LFMediaEditingController/LFMediaEditingController/class/LFPhotoEditingController/**/*.{h,m}','LFMediaEditingController/LFMediaEditingController/class/common/**/*.{h,m}'
ss.public_header_files = 'LFMediaEditingController/LFMediaEditingController/class/*.h','LFMediaEditingController/LFMediaEditingController/class/LFPhotoEditingController/controller/*.h','LFMediaEditingController/LFMediaEditingController/class/LFPhotoEditingController/model/*.h','LFMediaEditingController/LFMediaEditingController/class/common/view/model/LFStickerContent.h','LFMediaEditingController/LFMediaEditingController/class/common/view/model/LFExtraAspectRatio.h','LFMediaEditingController/LFMediaEditingController/class/common/define/LFExtraAspectRatioProtocol.h'
ss.dependency 'LFMediaEditingController/JRPickColorView'
ss.dependency 'LFMediaEditingController/JRFilterBar'
ss.dependency 'LFMediaEditingController/LFColorMatrix'
ss.dependency 'LFFilterSuite'
ss.dependency 'LFMediaEditingController/LFImageCoder'
ss.dependency 'LFMediaEditingController/LFPresentationCategory'
ss.dependency 'LFMediaEditingController/LFEasyNoticeBar'
ss.dependency 'LFMediaEditingController/SPDropMenu'
ss.dependency 'LFMediaEditingController/LFTipsGuideView'
ss.dependency 'LFMediaEditingController/LFDownloadManager'
ss.dependency 'LFMediaEditingController/LFDrawView'
end

# LFVideoEditingController模块
s.subspec 'LFVideoEditingController' do |ss|
ss.resources    = 'LFMediaEditingController/LFMediaEditingController/class/common/*.bundle'
ss.source_files = 'LFMediaEditingController/LFMediaEditingController/class/*.{h,m}','LFMediaEditingController/LFMediaEditingController/class/LFVideoEditingController/**/*.{h,m}','LFMediaEditingController/LFMediaEditingController/class/common/**/*.{h,m}'
ss.public_header_files = 'LFMediaEditingController/LFMediaEditingController/class/*.h','LFMediaEditingController/LFMediaEditingController/class/LFVideoEditingController/controller/*.h','LFMediaEditingController/LFMediaEditingController/class/LFVideoEditingController/model/*.h','LFMediaEditingController/LFMediaEditingController/class/common/view/model/LFStickerContent.h'
ss.dependency 'LFMediaEditingController/JRPickColorView'
ss.dependency 'LFMediaEditingController/JRFilterBar'
ss.dependency 'LFMediaEditingController/LFColorMatrix'
ss.dependency 'LFFilterSuite'
ss.dependency 'LFMediaEditingController/LFImageCoder'
ss.dependency 'LFMediaEditingController/LFPresentationCategory'
ss.dependency 'LFMediaEditingController/LFEasyNoticeBar'
ss.dependency 'LFMediaEditingController/SPDropMenu'
ss.dependency 'LFMediaEditingController/LFTipsGuideView'
ss.dependency 'LFMediaEditingController/LFDownloadManager'
ss.dependency 'LFMediaEditingController/LFDrawView'
end

# JRPickColorView模块
s.subspec 'JRPickColorView' do |ss|
ss.source_files = 'LFMediaEditingController/LFMediaEditingController/class/vendors/JRPickColorView/*.{h,m}'
ss.public_header_files = 'LFMediaEditingController/LFMediaEditingController/class/vendors/JRPickColorView/JRPickColorView.h'
end

# JRFilterBar模块
s.subspec 'JRFilterBar' do |ss|
ss.source_files = 'LFMediaEditingController/LFMediaEditingController/class/vendors/JRFilterBar/*.{h,m}','LFMediaEditingController/LFMediaEditingController/class/vendors/JRFilterBar/**/*.{h,m}'
ss.public_header_files = 'LFMediaEditingController/LFMediaEditingController/class/vendors/JRFilterBar/JRFilterBar.h'
end

# LFColorMatrix模块
s.subspec 'LFColorMatrix' do |ss|
ss.source_files = 'LFMediaEditingController/LFMediaEditingController/class/vendors/ColorMatrix/*.{h,m}'
ss.public_header_files = 'LFMediaEditingController/LFMediaEditingController/class/vendors/ColorMatrix/*.h'
end

# LFImageCoder模块
s.subspec 'LFImageCoder' do |ss|
ss.source_files = 'LFMediaEditingController/LFMediaEditingController/class/vendors/LFImageCoder/*.{h,m}','LFMediaEditingController/LFMediaEditingController/class/vendors/LFImageCoder/**/*.{h,m}'
ss.public_header_files = 'LFMediaEditingController/LFMediaEditingController/class/vendors/LFImageCoder/*.h'
end

# LFPresentationCategory模块
s.subspec 'LFPresentationCategory' do |ss|
ss.source_files = 'LFMediaEditingController/LFMediaEditingController/class/vendors/LFPresentationCategory/*.{h,m}','LFMediaEditingController/LFMediaEditingController/class/vendors/LFPresentationCategory/**/*.{h,m}'
ss.public_header_files = 'LFMediaEditingController/LFMediaEditingController/class/vendors/LFPresentationCategory/*.h'
end

# LFEasyNoticeBar模块
s.subspec 'LFEasyNoticeBar' do |ss|
ss.source_files = 'LFMediaEditingController/LFMediaEditingController/class/vendors/LFEasyNoticeBar/*.{h,m}','LFMediaEditingController/LFMediaEditingController/class/vendors/LFEasyNoticeBar/**/*.{h,m}'
ss.public_header_files = 'LFMediaEditingController/LFMediaEditingController/class/vendors/LFEasyNoticeBar/*.h'
ss.resources = 'LFMediaEditingController/LFMediaEditingController/class/vendors/LFEasyNoticeBar/*.bundle'
end

# SPDropMenu模块
s.subspec 'SPDropMenu' do |ss|
ss.source_files = 'LFMediaEditingController/LFMediaEditingController/class/vendors/SPDropMenu/*.{h,m}','LFMediaEditingController/LFMediaEditingController/class/vendors/SPDropMenu/**/*.{h,m}'
ss.public_header_files = 'LFMediaEditingController/LFMediaEditingController/class/vendors/SPDropMenu/*.h','LFMediaEditingController/LFMediaEditingController/class/vendors/SPDropMenu/Header/*.h','LFMediaEditingController/LFMediaEditingController/class/vendors/SPDropMenu/protocol/*.h','LFMediaEditingController/LFMediaEditingController/class/vendors/SPDropMenu/model/*.h'
end

# LFTipsGuideView模块
s.subspec 'LFTipsGuideView' do |ss|
ss.source_files = 'LFMediaEditingController/LFMediaEditingController/class/vendors/LFTipsGuideView/*.{h,m}','LFMediaEditingController/LFMediaEditingController/class/vendors/LFTipsGuideView/**/*.{h,m}'
ss.public_header_files = 'LFMediaEditingController/LFMediaEditingController/class/vendors/LFTipsGuideView/*.h'
ss.resources = 'LFMediaEditingController/LFMediaEditingController/class/vendors/LFTipsGuideView/*.bundle'
end

# LFDownloadManager模块
s.subspec 'LFDownloadManager' do |ss|
ss.source_files = 'LFMediaEditingController/LFMediaEditingController/class/vendors/LFDownloadManager/*.{h,m}'
ss.public_header_files = 'LFMediaEditingController/LFMediaEditingController/class/vendors/LFDownloadManager/*.h'
end

# LFDrawView模块
s.subspec 'LFDrawView' do |ss|
ss.source_files = 'LFMediaEditingController/LFMediaEditingController/class/vendors/LFDrawView/*.{h,m}','LFMediaEditingController/LFMediaEditingController/class/vendors/LFDrawView/**/*.{h,m}'
ss.public_header_files = 'LFMediaEditingController/LFMediaEditingController/class/vendors/LFDrawView/*.h','LFMediaEditingController/LFMediaEditingController/class/vendors/LFDrawView/**/*.h'
end

end
