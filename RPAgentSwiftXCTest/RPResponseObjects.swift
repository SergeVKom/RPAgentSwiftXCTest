//
//  RPResponseObjects.swift
//  com.oxagile.automation.RPAgentSwiftXCTest
//
//  Created by Sergey Komarov on 6/26/17.
//  Copyright © 2017 Oxagile. All rights reserved.
//

import Foundation
import ObjectMapper


struct ItemData: Mappable {
    var id = ""
    var message = ""
    
    init(map: Map) { }
    init() { }
    
    mutating func mapping(map: Map) {
        id          <- map["id"]
        message     <- map["message"]
    }
}

struct FinishData: Mappable {
    var msg: String = ""
    
    init(map: Map) { }
    init() { }
    
    mutating func mapping(map: Map) {
        msg         <- map["msg"]
        msg         <- map["message"]
    }
}
