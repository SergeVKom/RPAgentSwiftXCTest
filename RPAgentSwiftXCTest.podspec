Pod::Spec.new do |s|
    s.name             = 'RPAgentSwiftXCTest'
    s.version          = '1.9'
    s.summary          = 'Agent to push test results on Report Portal'

    s.description      = <<-DESC
        This agent allows to see test results on the Report Portal - http://reportportal.io
    DESC

    s.homepage         = 'https://github.com/SergeVKom/RPAgentSwiftXCTest'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'SergeVKom' => 'sergvkom@gmail.com' }
    s.source           = { :git => 'https://github.com/SergeVKom/RPAgentSwiftXCTest.git', :tag => s.version.to_s }

    s.ios.deployment_target = '8.0'
    s.tvos.deployment_target = '9.0'
    s.source_files = 'RPAgentSwiftXCTest/**/*'

    s.dependency 'Alamofire', '~> 4.5.0'
    s.dependency 'AlamofireObjectMapper', '~> 4.1.0'

    s.weak_framework = "XCTest"
    s.pod_target_xcconfig = {
        'FRAMEWORK_SEARCH_PATHS' => '$(inherited) "$(PLATFORM_DIR)/Developer/Library/Frameworks"',
    }
end
