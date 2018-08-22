//
//  HTTPClient.swift
//  com.oxagile.automation.RPAgentSwiftXCTest
//
//  Created by Sergey Komarov on 6/5/17.
//  Copyright © 2017 Oxagile. All rights reserved.
//

import Foundation

enum HTTPClientError: Error {
  case invalidURL
  case noResponse
}

 class HTTPClient: NSObject {
  
  let requestTimeout: TimeInterval = 120
  let utilityQueue = DispatchQueue(label: "com.oxagile.httpclient", qos: .utility)
  
   override init() {
    URLSession.shared.configuration.timeoutIntervalForRequest = requestTimeout
  }
  
  func doRequest<T: Decodable>(endPoint: EndPoint, completion: @escaping (_ result: T) -> Void) throws {
    guard var url = URL(string: endPoint.url) else {
      throw HTTPClientError.invalidURL
    }
    if endPoint.encoding == .url {
      var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)!
      let queryItems = endPoint.parameters.map {
        return URLQueryItem(name: "\($0)", value: "\($1)")
      }
      
      urlComponents.queryItems = queryItems
      url = urlComponents.url!
    }
    let request = NSMutableURLRequest(url: url)
    request.httpMethod = endPoint.method.rawValue
    request.cachePolicy = .reloadIgnoringCacheData
    request.allHTTPHeaderFields = endPoint.headers
    if endPoint.encoding == .json {
      let data = try JSONSerialization.data(withJSONObject: endPoint.parameters, options: .prettyPrinted)
      request.httpBody = data
    }
    print(request.description)
    utilityQueue.async {
      let task = URLSession.shared.dataTask(with: request as URLRequest) { (data: Data?, response: URLResponse?, error: Error?) in
        if let error = error {
           print(error)
          return
        }
        
        guard let data = data else {
          print("no data")
          return
        }
        
        guard let result = try? JSONDecoder().decode(T.self, from: data) else
        {
          print("cannot deserialize data")
          return
        }
        
        completion(result)
      }
      task.resume()
    }
//    var responseCode = 000
//    request.responseObject(queue: utilityQueue, keyPath: data.keyPath) { (response: DataResponse<T>) in
//      switch response.result {
//      case .success:
//        completion(response.result.value!)
//        responseCode = response.response?.statusCode ?? responseCode
//        print("response: \(responseCode), \(response.result.value!))")
//      case .failure(let error):
//        print("Can not do request: \(String(describing: error))")
//      }
//    }
  }
}
