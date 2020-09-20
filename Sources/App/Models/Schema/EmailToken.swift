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

    @ID(key: .id) var id: UUID?
    @Parent(key: FieldKeys.userId) var user: User
    @Field(key: FieldKeys.token) var token: String
    @Field(key: FieldKeys.expiresAt) var expiresAt: Date

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
    struct FieldKeys {
        static var userId: FieldKey { "user_id" }
        static var token: FieldKey { "token" }
        static var expiresAt: FieldKey { "expires_at" }
    }
}

extension EmailToken {
    struct Const {
        static let expirationInterval: TimeInterval = 3600  // a house
    }
}
