//
//  File.swift
//  
//
//  Created by laijihua on 2020/4/19.
//

import Vapor

struct InputRegister: Input {
    var name: String
    var email: String
    var password: String
}

extension InputRegister: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("name", as: String.self, is: !.empty)
        validations.add("email", as: String.self, is: .email)
        validations.add("password", as: String.self, is: .count(8...))
    }
}
