//
//  HTTPClient.swift
//  com.oxagile.automation.RPAgentSwiftXCTest
//
//  Created by Sergey Komarov on 6/5/17.
//  Copyright © 2017 Oxagile. All rights reserved.
//

import Alamofire
import AlamofireObjectMapper
import ObjectMapper

public class HTTPClient: NSObject {
    
    let requestTimeout: TimeInterval = 120
    let utilityQueue = DispatchQueue(label: "com.oxagile.httpclient", qos: .utility)
    
    public func doRequest<T: Mappable>(data: EndPoint, completion: @escaping (_ result: T) -> Void) {
        let manager = Alamofire.SessionManager.default
        var responseCode = 000
        manager.session.configuration.timeoutIntervalForRequest = requestTimeout
        let request = manager.request(
            data.url,
            method: data.type,
            parameters: data.parameters,
            encoding: data.encoding,
            headers: data.headers
        )
        print(request.description)
        request.responseObject(queue: utilityQueue, keyPath: data.keyPath) { (response: DataResponse<T>) in
            switch response.result {
            case .success:
                completion(response.result.value!)
                responseCode = response.response?.statusCode ?? 000
                print("response: \(responseCode), \(response.result.value!))")
            case .failure(let error):
                print("Can not do request: \(String(describing: error))")
            }
        }        
    }
}
