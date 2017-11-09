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
    
    var serviceRP: RPService?
    let queue = DispatchQueue(label: "com.oxagile.report.portal", qos: .utility)
    var bundleProperties: [String: Any]!
    
    public override init() {
        super.init()
        XCTestObservationCenter.shared.addTestObserver(self)
    }
    
    public func testBundleWillStart(_ testBundle: Bundle) {
        guard let path = testBundle.path(forResource: "Info", ofType: "plist") else {return }
        bundleProperties = NSDictionary(contentsOfFile: path) as? [String: Any]
        guard let pushData = bundleProperties["PushTestDataToReportPortal"] as? Bool else {
            print("Configure properties for report portal in the Info.plist")
            return
        }
        guard pushData else {
            print("Set 'YES' for 'PushTestDataToReportPortal' property in Info.plist if you want to put data to report portal")
            return
        }
        serviceRP = RPService()
        queue.async {
            self.serviceRP!.startLaunch(self.bundleProperties)
        }
    }
    
    public func testSuiteWillStart(_ testSuite: XCTestSuite) {
        guard let service = serviceRP else { return }
        if !testSuite.name.contains("Selected tests"), !testSuite.name.contains(".xctest") {
            queue.async {
                service.startTestCase(testSuite)
            }
        }
    }
    
    public func testSuite(_ testSuite: XCTestSuite, didFailWithDescription description: String, inFile filePath: String?, atLine lineNumber: Int) {
        
    }
    
    public func testCaseWillStart(_ testCase: XCTestCase) {
        guard let service = serviceRP else { return }
        queue.async {
            service.startTest(testCase)
        }
    }
    
    public func testCase(_ testCase: XCTestCase, didFailWithDescription description: String, inFile filePath: String?, atLine lineNumber: Int) {
        guard let service = serviceRP else { return }
        queue.async {
            service.reportError(message: "Test '\(String(describing: testCase.name)))' failed on line \(lineNumber), \(description)")
        }
    }
    
    public func testCaseDidFinish(_ testCase: XCTestCase) {
        guard let service = serviceRP else { return }
        queue.async {
            service.finishTest(testCase)
        }
    }
    
    public func testSuiteDidFinish(_ testSuite: XCTestSuite) {
        guard let service = serviceRP else { return }
        if !testSuite.name.contains("Selected tests"), !testSuite.name.contains(".xctest") {
            queue.async {
                service.finishTestCase()
            }
        }
    }
    
    public func testBundleDidFinish(_ testBundle: Bundle) {
        guard let service = serviceRP else { return }
        queue.sync() {
            service.finishLaunch()
        }
    }
}
