//
//  EndPoint.swift
//  com.oxagile.automation.RPAgentSwiftXCTest
//
//  Created by Sergey Komarov on 8/29/17.
//  Copyright © 2017 Oxagile. All rights reserved.
//

enum ParameterEncoding {
  case url
  case json
}

enum HTTPMethod: String {
  case get = "GET"
  case post = "POST"
  case put = "PUT"
  case delete = "DELETE"
}

struct EndPoint {
  
  var headers = [String: String]()
  var encoding: ParameterEncoding = .url
  var method = HTTPMethod.get
  var url = ""
  var keyPath = ""
  var parameters = [String: Any]()
  var returnedObject: Any
  
  init(headers: [String: String], encoding: ParameterEncoding, method: HTTPMethod, url:String, keyPath:String, parameters: [String: Any], returnedObject: Any) {
    self.headers = headers
    self.encoding = encoding
    self.method = method
    self.url = url
    self.keyPath = keyPath
    self.parameters = parameters
    self.returnedObject = returnedObject
  }
}
