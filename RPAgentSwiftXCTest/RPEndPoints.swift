//
//  RPEndPoints.swift
//  com.oxagile.automation.RPAgentSwiftXCTest
//
//  Created by Sergey Komarov on 6/26/17.
//  Copyright © 2017 Oxagile. All rights reserved.
//

import Alamofire

struct RPEndPoints {
    
    private var baseURL: String?
    private var token: String?
    private var defaultHeader: [String: String] {
        return [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(token!)",
        ]
    }
    
    init(url: String, token: String) {
        self.baseURL = url
        self.token = token
    }
    
    var startLaunch:EndPoint {
        return EndPoint(
            headers: defaultHeader,
            encoding: JSONEncoding.default,
            type: HTTPMethod.post,
            url: "\(baseURL!)/gaia/launch",
            keyPath:"",
            parameters: [
                "description": "",
                "mode": "DEFAULT",
                "name": "",
                "start_time": "",
                "tags": []
            ],
            returnedObject: ItemData.self
        )
    }
    
    var finishLaunch:EndPoint {
        return EndPoint(
            headers: defaultHeader,
            encoding: JSONEncoding.default,
            type: HTTPMethod.put,
            url: "\(baseURL!)/gaia/launch/{launchId}/finish",
            keyPath: "",
            parameters: [:],
            returnedObject: FinishData.self
        )
    }
    
    var startTestCase:EndPoint {
        return EndPoint(
            headers: defaultHeader,
            encoding: JSONEncoding.default,
            type: HTTPMethod.post,
            url: "\(baseURL!)/gaia/item",
            keyPath:"",
            parameters: [
                "description": "",
                "launch_id": "",
                "name": "",
                "start_time": "",
                "tags": [],
                "type": "TEST"
            ],
            returnedObject: ItemData.self
        )
    }
    
    var finishItem:EndPoint {
        return EndPoint(
            headers: defaultHeader,
            encoding: JSONEncoding.default,
            type: HTTPMethod.put,
            url: "\(baseURL!)/gaia/item/{itemId}",
            keyPath: "",
            parameters: [
                "end_time": "",
                "issue": [
                    "comment": "",
                    "issue_type": ""
                ],
                "status": ""
            ],
            returnedObject: FinishData.self
        )
    }
    
    var startTest:EndPoint {
        return EndPoint(
            headers: defaultHeader,
            encoding: JSONEncoding.default,
            type: HTTPMethod.post,
            url: "\(baseURL!)/gaia/item/{parentId}",
            keyPath:"",
            parameters: [
                "description": "",
                "launch_id": "",
                "name": "",
                "start_time": "",
                "tags": [],
                "type": "STEP"
            ],
            returnedObject: ItemData.self
        )
    }
}
