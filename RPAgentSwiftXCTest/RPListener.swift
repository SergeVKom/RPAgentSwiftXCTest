//
//  Listener.swift
//  com.oxagile.automation.RPAgentSwiftXCTest
//
//  Created by Sergey Komarov on 5/12/17.
//  Copyright © 2017 Oxagile. All rights reserved.
//

import Foundation
import XCTest

public class RPListener: NSObject, XCTestObservation {
    
    let serviceRP = RPService()
    let queue = DispatchQueue(label: "com.oxagile.report.portal", qos: .utility)
    var pushData = false
    var bundleProperties: [String: Any]!
    
    public override init() {
        super.init()
        XCTestObservationCenter.shared().addTestObserver(self)
    }
    
    public func testBundleWillStart(_ testBundle: Bundle) {
        if let path = testBundle.path(forResource: "Info", ofType: "plist") {
            bundleProperties = NSDictionary(contentsOfFile: path) as? [String: Any]
            pushData = bundleProperties?["PushTestDataToReportPortal"] as! Bool
        }
        if pushData {
            queue.async {
                self.serviceRP.startLaunch(self.bundleProperties)
            }
        }
    }

    public func testSuiteWillStart(_ testSuite: XCTestSuite) {
        if pushData, !testSuite.name!.contains("Selected tests"), !testSuite.name!.contains(".xctest") {
            queue.async {
                self.serviceRP.startTestCase(testSuite)
            }
        }
    }
    
    public func testSuite(_ testSuite: XCTestSuite, didFailWithDescription description: String, inFile filePath: String?, atLine lineNumber: UInt) {
        
    }
    
    public func testCaseWillStart(_ testCase: XCTestCase) {
        if pushData {
            queue.async {
                self.serviceRP.startTest(testCase)
            }
        }
    }
    
    public func testCase(_ testCase: XCTestCase, didFailWithDescription description: String, inFile filePath: String?, atLine lineNumber: UInt) {
        
    }
    
    public func testCaseDidFinish(_ testCase: XCTestCase) {
        if pushData {
            queue.async {
                self.serviceRP.finishTest(testCase)
            }
        }
    }
    
    public func testSuiteDidFinish(_ testSuite: XCTestSuite) {
        if pushData, !testSuite.name!.contains("Selected tests"), !testSuite.name!.contains(".xctest") {
            queue.async {
                self.serviceRP.finishTestCase()
            }
        }
    }
    
    public func testBundleDidFinish(_ testBundle: Bundle) {
        if pushData {
            queue.sync() {
                self.serviceRP.finishLaunch()
            }            
        }
    }    
}
