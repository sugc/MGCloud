#
# Be sure to run `pod lib lint MGCloud.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'MGCloud'
  s.version          = '0.1.0'
  s.summary          = 'A short description of MGCloud.'
  
  # This description is used to generate tags and improve search results.
  #   * Think: What does it do? Why did you write it? What is the focus?
  #   * Try to keep it short, snappy and to the point.
  #   * Write the description between the DESC delimiters below.
  #   * Finally, don't worry about the indent, CocoaPods strips it!
  
  s.description      = <<-DESC
  TODO: Add long description of the pod here.
  DESC
  
  s.homepage         = 'https://github.com/sugc/MGCloud'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'sugc' => '2528397406@qq.com' }
  s.source           = { :git => 'https://github.com/sugc/MGCloud.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
  s.module_name             = 'MGCloud'
  s.ios.deployment_target =
  '10.0'
  s.swift_version = '5.0'
  
  #  s.use_modular_headers = 'true'
  
  s.pod_target_xcconfig = { "OTHER_SWIFT_FLAGS[config=Release]" => "$(inherited) -suppress-warnings"}
  
  s.source_files = 'MGCloud/Base/Classes/**/*.swift'
  #  s.resource = ['MGCloud/Assets/**/*.xcassets']
  s.resource_bundles = {
    "MGCloudResources" => ['MGCloud/Resources/**/*.*']
  }
  
  s.subspec 'BaiduCloud' do |ss|
#    ss.frameworks = 'libc++', 'libsqlite3', 'WebKit'
#    ss.vendored_libraries = 'Verify-SwiftOC3rd/Vendors/thirdlibs/*.a'
    ss.vendored_frameworks = 'MGCloud/Baidu/Vendors/*.framework'
    
 
    ss.source_files = 'MGCloud/Baidu/Classes/**/*.swift'
#    ss.frameworks = 'OpenSSL'
    ss.dependency 'MGUIKit'
    ss.preserve_paths = 'MGCloud/Baidu/Vendors/*.framework'
    ss.pod_target_xcconfig = {
      'LD_RUNPATH_SEARCH_PATHS' => '$(PODS_ROOT)/MGCloud/Baidu/Vendors/' }
  end
  


s.subspec 'iCloud' do |ss|

  ss.source_files = 'MGCloud/Apple/Classes/**/*.swift'

end



#  s.subspec 'Resource' do |ss|
#    ss.resource_bundles = {
#        "MGCloudResources" => ['MGCloud/Assets/**/*']
#    }
#    ss.source_files = ''
#  end

s.default_subspecs  = 'BaiduCloud', 'iCloud'

s.dependency 'Alamofire'



end
