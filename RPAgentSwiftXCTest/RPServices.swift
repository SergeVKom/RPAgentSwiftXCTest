//
//  RPServices.swift
//  com.oxagile.automation.RPAgentSwiftXCTest
//
//  Created by Sergey Komarov on 6/26/17.
//  Copyright © 2017 Oxagile. All rights reserved.
//

import Foundation
import XCTest


class RPService: NSObject {
  
  var httpClient = HTTPClient()
  var endPoints: RPEndPoints!
  var launchID = ""
  var launchStatus = TestStatus.passed.rawValue
  var testCaseID = ""
  var testID = ""
  var currentTime: String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    formatter.locale = Locale(identifier: "en_US_POSIX")
    return formatter.string(from: Date())
  }
  let semaphore = DispatchSemaphore(value: 0)
  let timeOutForRequestExpectation = 10.0
  var currentDevice = UIDevice.current
  
  
  func startLaunch(_ bundleProperties: [String: Any]) throws {
    endPoints = RPEndPoints (
      url: bundleProperties["ReportPortalURL"] as! String,
      token: bundleProperties["ReportPortalToken"] as! String
    )
    var requestData = endPoints.startLaunch
    requestData.parameters["name"] = bundleProperties["ReportPortalLaunchName"]
    requestData.parameters["start_time"] = currentTime
    var customTags: [String] {
      var tags = [String]()
      if (bundleProperties["ReportPortalTags"] != nil) {
        tags = (bundleProperties["ReportPortalTags"] as! String).replacingOccurrences(of: ", ", with: ",").components(separatedBy: ",")
      }
      return tags
    }
    requestData.parameters["tags"] = [currentDevice.systemName, currentDevice.systemVersion, currentDevice.modelName, currentDevice.model] + customTags
    
    try httpClient.doRequest(endPoint: requestData) { (result: ItemData) in
      self.launchID = result.id
      self.semaphore.signal()
    }
    _ = semaphore.wait(timeout: .now() + timeOutForRequestExpectation)
  }
  
  func startTestCase(_ testCase: XCTestSuite) throws {
    var requestData = endPoints.startTestCase
    var testCaseName: String {
      var sentence = ""
      for eachCharacter in Array(testCase.name) {
        if (eachCharacter >= "A" && eachCharacter <= "Z") == true {
          sentence.append(" ")
        }
        sentence.append(eachCharacter)
      }
      return sentence.trimmingCharacters(in: .whitespaces)
    }
    requestData.parameters["launch_id"] = launchID
    requestData.parameters["name"] = testCaseName
    requestData.parameters["start_time"] = currentTime
    try httpClient.doRequest(endPoint: requestData) { (result: ItemData) in
      self.testCaseID = result.id
      self.semaphore.signal()
    }
    _ = semaphore.wait(timeout: .now() + timeOutForRequestExpectation)
  }
  
  func startTest(_ test: XCTestCase) throws {
    var requestData = endPoints.startTest
    var testName: String {
      let camelStyleName = Array(String(test.name.components(separatedBy: " ")[1]).dropLast())
      var sentence = ""
      for eachCharacter in camelStyleName {
        if (eachCharacter >= "A" && eachCharacter <= "Z") == true {
          sentence.append(" ")
        }
        sentence.append(eachCharacter)
      }
      var worlds = sentence.trimmingCharacters(in: .whitespaces).lowercased().components(separatedBy: " ")
      if worlds.count > 1 {
        worlds.remove(at: 0)
      }
      worlds[0] = worlds[0].capitalized
      return worlds.joined(separator: " ")
    }
    requestData.url = requestData.url.replacingOccurrences(of: "{parentId}", with: testCaseID)
    requestData.parameters["launch_id"] = launchID
    requestData.parameters["name"] = testName
    requestData.parameters["start_time"] = currentTime
    try httpClient.doRequest(endPoint: requestData) { (result: ItemData) in
      self.testID = result.id
      self.semaphore.signal()
    }
    _ = semaphore.wait(timeout: .now() + timeOutForRequestExpectation)
  }
  
  func reportError(message: String) throws {
    var requestData = endPoints.postLog
    requestData.parameters["item_id"] = self.testID
    requestData.parameters["level"] = "error"
    requestData.parameters["message"] = message
    requestData.parameters["time"] = currentTime
    try httpClient.doRequest(endPoint: requestData) { (result: ItemData) in
      self.semaphore.signal()
    }
    _ = semaphore.wait(timeout: .now() + timeOutForRequestExpectation)
  }
  
  func finishTest(_ test: XCTestCase) throws {
    var requestData = endPoints.finishItem
    requestData.url = requestData.url.replacingOccurrences(of: "{itemId}", with: testID)
    var issueType = ""
    let status = test.testRun!.hasSucceeded ? TestStatus.passed.rawValue : TestStatus.failed.rawValue
    if status == TestStatus.failed.rawValue {
      issueType = "TO_INVESTIGATE"
      launchStatus = TestStatus.failed.rawValue
    }
    requestData.parameters = [
      "end_time": currentTime,
      "issue": [
        "comment": "",
        "issue_type": issueType
      ],
      "status": status
    ]
    try httpClient.doRequest(endPoint: requestData) { (result: FinishData) in
      self.semaphore.signal()
    }
    _ = semaphore.wait(timeout: .now() + timeOutForRequestExpectation)
  }
  
  func finishTestCase() throws {
    var requestData = endPoints.finishItem
    requestData.url = requestData.url.replacingOccurrences(of: "{itemId}", with: testCaseID)
    requestData.parameters["end_time"] = currentTime
    requestData.parameters["status"] = launchStatus
    try httpClient.doRequest(endPoint: requestData) { (result: FinishData) in
      self.semaphore.signal()
    }
    _ = semaphore.wait(timeout: .now() + timeOutForRequestExpectation)
  }
  
  func finishLaunch() throws {
    var requestData = endPoints.finishLaunch
    requestData.url = requestData.url.replacingOccurrences(of: "{launchId}", with: launchID)
    requestData.parameters = [
      "end_time": currentTime,
      "status": launchStatus
    ]
    try httpClient.doRequest(endPoint: requestData) { (result: FinishData) in
      self.semaphore.signal()
    }
    _ = semaphore.wait(timeout: .now() + timeOutForRequestExpectation)
  }
}
