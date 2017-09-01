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
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }
    var currentTime: String {
        return dateFormatter.string(from: Date())
    }
    let semaphore = DispatchSemaphore(value: 0)
    let timeOutForRequestExpectation = 10.0
    var currentDevice = UIDevice.current
    
    
    func startLaunch(_ bundleProperties: [String: Any]) {
        endPoints = RPEndPoints (
            url: bundleProperties["ReportPortalURL"] as! String,
            token: bundleProperties["ReportPortalToken"] as! String
        )
        var requestData = endPoints.startLaunch
        requestData.parameters["name"] = bundleProperties["ReportPortalLaunchName"]
        requestData.parameters["start_time"] = currentTime
        let customTags = (bundleProperties["ReportPortalTags"] as! String).replacingOccurrences(of: ", ", with: ",").components(separatedBy: ",")
        requestData.parameters["tags"] = [currentDevice.systemName, currentDevice.systemVersion, currentDevice.modelName, currentDevice.model] + customTags
        
        httpClient.doRequest(data: requestData) { (result: ItemData) in
            self.launchID = result.id
            self.semaphore.signal()
        }
        _ = semaphore.wait(timeout: .now() + timeOutForRequestExpectation)
    }
    
    func startTestCase(_ testCase: XCTestSuite) {
        var requestData = endPoints.startTestCase
        var testCaseName: String {
            var sentence = ""
            for eachCharacter in testCase.name!.characters {
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
        httpClient.doRequest(data: requestData) { (result: ItemData) in
            self.testCaseID = result.id
            self.semaphore.signal()
        }
        _ = semaphore.wait(timeout: .now() + timeOutForRequestExpectation)
    }
    
    func startTest(_ test: XCTestCase) {
        var requestData = endPoints.startTest
        var testName: String {
            let camelStyleName = String(test.name!.components(separatedBy: " ")[1].characters.dropLast())
            var sentence = ""
            for eachCharacter in camelStyleName.characters {
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
        httpClient.doRequest(data: requestData) { (result: ItemData) in
            self.testID = result.id
            self.semaphore.signal()
        }
        _ = semaphore.wait(timeout: .now() + timeOutForRequestExpectation)
    }
    
    func finishTest(_ test: XCTestCase) {
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
        httpClient.doRequest(data: requestData) { (result: FinishData) in
            self.semaphore.signal()
        }
        _ = semaphore.wait(timeout: .now() + timeOutForRequestExpectation)
    }
    
    func finishTestCase() {
        var requestData = endPoints.finishItem
        requestData.url = requestData.url.replacingOccurrences(of: "{itemId}", with: testCaseID)
        requestData.parameters["end_time"] = currentTime
        requestData.parameters["status"] = launchStatus
        httpClient.doRequest(data: requestData) { (result: FinishData) in
            self.semaphore.signal()
        }
        _ = semaphore.wait(timeout: .now() + timeOutForRequestExpectation)
    }
    
    func finishLaunch() {
        var requestData = endPoints.finishLaunch
        requestData.url = requestData.url.replacingOccurrences(of: "{launchId}", with: launchID)
        requestData.parameters = [
            "end_time": currentTime,
            "status": launchStatus
        ]
        httpClient.doRequest(data: requestData) { (result: FinishData) in
            self.semaphore.signal()
        }
        _ = semaphore.wait(timeout: .now() + timeOutForRequestExpectation)
    }
}
