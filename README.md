# RPAgentSwiftXCTest


[![Version](https://img.shields.io/cocoapods/v/RPAgentSwiftXCTest.svg?style=flat)](http://cocoapods.org/pods/RPAgentSwiftXCTest)
[![License](https://img.shields.io/cocoapods/l/RPAgentSwiftXCTest.svg?style=flat)](http://cocoapods.org/pods/RPAgentSwiftXCTest)
[![Platform](https://img.shields.io/cocoapods/p/RPAgentSwiftXCTest.svg?style=flat)](http://cocoapods.org/pods/RPAgentSwiftXCTest)

## Installation

RPAgentSwiftXCTest is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'RPAgentSwiftXCTest'
```
and install it:
```bash
cd <project>
pod install
```

## Report Portal properties

Use info.plist file of your test target to specify properties of Report Portal:

* ReportPortalURL - URL to API of report portal (exaple https://report-portal.company.com/api/v1/project).
* ReportPortalToken - token for authentication which can be get from RP account settings.
* ReportPortalLaunchName - name of launch.
* Principal class - use RPAgentSwiftXCTest.RPListener from RPAgentSwiftXCTest lib. Also you can specify your own Observer which should conform [XCTestObservation](https://developer.apple.com/documentation/xctest/xctestobservation) protocol.
* PushTestDataToReportPortal - can be used for switch off/on reporting
* ReportPortalTags(optinal) - can be used to specify tags, separeted by comma.

Example:
![Alt text](https://github.com/SergeVKom/RPAgentSwiftXCTest/blob/master/Screen%20Shot.png)

## Author

SergeVKom, sergvkom@gmail.com

## License

RPAgentSwiftXCTest is available under the MIT license. See the LICENSE file for more info.
