//
//  File.swift
//  
//
//  Created by laijihua on 2020/4/29.
//

import Vapor

struct InputTag: Input {
    var name: String // 必传
    var remarks: String?
}

extension InputTag: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("name", as: String.self, is: !.empty)
    }
}
