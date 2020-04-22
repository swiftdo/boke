//
//  File.swift
//  
//
//  Created by laijihua on 2020/4/18.
//

import Foundation

struct OutputJson<T: Output>: Output, OutputCodeMsg {
    var code: Int
    var message: String
    let data: T?

    init(code: OutputStatus, data: T?) {
        self.code = code.code
        self.message = code.message
        self.data = data
    }

    init(success data: T) {
        self.init(code: .ok, data: data)
    }

    init(error code: OutputStatus) {
        self.init(code: code, data: nil)
    }
}

extension String: Output {
    
}
