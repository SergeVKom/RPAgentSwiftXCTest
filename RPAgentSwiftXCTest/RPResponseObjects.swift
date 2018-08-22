//
//  RPResponseObjects.swift
//  com.oxagile.automation.RPAgentSwiftXCTest
//
//  Created by Sergey Komarov on 6/26/17.
//  Copyright © 2017 Oxagile. All rights reserved.
//

import Foundation

struct ItemData: Decodable {
  let id: String
  let message: String
}

enum FinishDataKeys: String, CodingKey {
  case msg = "msg"
  case message = "message"
}

struct FinishData: Decodable {
    let msg: String
    
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: FinishDataKeys.self) //?? decoder["message"]
    let msg = try? container.decode(String.self, forKey: .msg)
    self.msg = try msg ?? container.decode(String.self, forKey: .message)
  }
  
}
