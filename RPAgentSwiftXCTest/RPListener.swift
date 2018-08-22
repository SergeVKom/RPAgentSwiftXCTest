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
      do {
        try self.serviceRP!.startLaunch(self.bundleProperties)
      } catch let error {
        print(error)
      }
    }
  }
  
  public func testSuiteWillStart(_ testSuite: XCTestSuite) {
    guard let service = serviceRP else { return }
    if !testSuite.name.contains("Selected tests"), !testSuite.name.contains(".xctest") {
      queue.async {
        do {
          try service.startTestCase(testSuite)
        } catch let error {
          print(error)
        }
      }
    }
  }
  
  public func testSuite(_ testSuite: XCTestSuite, didFailWithDescription description: String, inFile filePath: String?, atLine lineNumber: Int) {
    
  }
  
  public func testCaseWillStart(_ testCase: XCTestCase) {
    guard let service = serviceRP else { return }
    queue.async {
      do {
        try service.startTest(testCase)
      } catch let error {
        print(error)
      }
    }
  }
  
  public func testCase(_ testCase: XCTestCase, didFailWithDescription description: String, inFile filePath: String?, atLine lineNumber: Int) {
    guard let service = serviceRP else { return }
    queue.async {
      do {
        try service.reportError(message: "Test '\(String(describing: testCase.name)))' failed on line \(lineNumber), \(description)")
      } catch let error {
        print(error)
      }
    }
  }
  
  public func testCaseDidFinish(_ testCase: XCTestCase) {
    guard let service = serviceRP else { return }
    
    queue.async {
      do {
        try service.finishTest(testCase)
      } catch let error {
        print(error)
      }
    }
  }
  
  public func testSuiteDidFinish(_ testSuite: XCTestSuite) {
    guard let service = serviceRP else { return }
    if !testSuite.name.contains("Selected tests"), !testSuite.name.contains(".xctest") {
      queue.async {
        do {
          try  service.finishTestCase()
        } catch let error {
          print(error)
        }
      }
    }
  }
  
  public func testBundleDidFinish(_ testBundle: Bundle) {
    guard let service = serviceRP else { return }
    queue.sync() {
      do {
        try service.finishLaunch()
      } catch let error {
        print(error)
      }
    }
  }
}
