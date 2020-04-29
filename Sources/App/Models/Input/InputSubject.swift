//
//  File.swift
//  
//
//  Created by laijihua on 2020/4/28.
//

import Vapor

struct InputSubject: Input {
    var name: String // 必传
    var cover: String?
    var remarks: String?
}

extension InputSubject: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("name", as: String.self, is: !.empty)
    }
}
