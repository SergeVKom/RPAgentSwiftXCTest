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
    var bundleProperties: [String: Any]!
    
    public override init() {
        super.init()
        XCTestObservationCenter.shared.addTestObserver(self)
    }
    
    public func testBundleWillStart(_ testBundle: Bundle) {
        guard let path = testBundle.path(forResource: "Info", ofType: "plist") else { return }
        bundleProperties = NSDictionary(contentsOfFile: path) as? [String: Any]
        guard bundleProperties?["PushTestDataToReportPortal"] as! Bool else {
            XCTestObservationCenter.shared.removeTestObserver(self)
            return
        }
        queue.async {
            self.serviceRP.startLaunch(self.bundleProperties)
        }
    }
    
    public func testSuiteWillStart(_ testSuite: XCTestSuite) {
        if !testSuite.name.contains("Selected tests"), !testSuite.name.contains(".xctest") {
            queue.async {
                self.serviceRP.startTestCase(testSuite)
            }
        }
    }
    
    public func testSuite(_ testSuite: XCTestSuite, didFailWithDescription description: String, inFile filePath: String?, atLine lineNumber: Int) {
        
    }
    
    public func testCaseWillStart(_ testCase: XCTestCase) {
        queue.async {
            self.serviceRP.startTest(testCase)
        }
    }
    
    public func testCase(_ testCase: XCTestCase, didFailWithDescription description: String, inFile filePath: String?, atLine lineNumber: Int) {
        queue.async {
            self.serviceRP.reportError(message: "Test '\(String(describing: testCase.name)))' failed on line \(lineNumber), \(description)")
        }
    }
    
    public func testCaseDidFinish(_ testCase: XCTestCase) {
        queue.async {
            self.serviceRP.finishTest(testCase)
        }
    }
    
    public func testSuiteDidFinish(_ testSuite: XCTestSuite) {
        if !testSuite.name.contains("Selected tests"), !testSuite.name.contains(".xctest") {
            queue.async {
                self.serviceRP.finishTestCase()
            }
        }
    }
    
    public func testBundleDidFinish(_ testBundle: Bundle) {
        queue.sync() {
            self.serviceRP.finishLaunch()
        }
    }
}
