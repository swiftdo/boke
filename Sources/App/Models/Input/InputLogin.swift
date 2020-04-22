//
//  File.swift
//  
//
//  Created by laijihua on 2020/4/19.
//

import Vapor

struct InputLogin: Input {
    let email: String
    let password: String
}

extension InputLogin: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("email", as: String.self, is: .email)
        validations.add("password", as: String.self, is: .count(8...))
    }
}
