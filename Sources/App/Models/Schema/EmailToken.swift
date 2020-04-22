//
//  File.swift
//  
//
//  Created by laijihua on 2020/4/19.
//

import Vapor
import Fluent

final class EmailToken: Model {
    static let schema = "email_tokens"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "user_id")
    var user: User

    @Field(key: "token")
    var token: String

    @Field(key: "expires_at")
    var expiresAt: Date

    init() {}

    init(
        id: UUID? = nil,
        userID: UUID,
        token: String
    ) {
        self.id = id
        self.$user.id = userID
        self.token = token
        self.expiresAt = Date().addingTimeInterval(Const.expirationInterval)
    }
}

extension EmailToken {
    struct Const {
        static let expirationInterval: TimeInterval = 3600  // a house
    }
}
