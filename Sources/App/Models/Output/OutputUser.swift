//
//  File.swift
//  
//
//  Created by laijihua on 2020/4/19.
//

import Foundation

struct OutputUser: Output {
    let id: UUID?
    let name: String
    let email: String
    let avatar: String?

    init(id: UUID? = nil, name: String, email: String, avatar: String?) {
        self.id = id
        self.name = name
        self.email = email
        self.avatar = avatar
    }

    init(from user: User) {
        self.init(id: user.id, name: user.name, email: user.email, avatar: user.avatar)
    }
}
