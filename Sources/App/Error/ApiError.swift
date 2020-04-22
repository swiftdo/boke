//
//  File.swift
//  
//
//  Created by laijihua on 2020/4/18.
//

import Vapor

struct ApiError {
    var content: OutputStatus

    init(code: OutputStatus) {
        self.content = code
    }
}

extension ApiError: AbortError {
    
    var status: HTTPResponseStatus { .ok }

    var reason: String {
        return self.content.message
    }
}
