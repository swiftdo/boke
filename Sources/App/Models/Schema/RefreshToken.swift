//
//  File.swift
//  
//
//  Created by laijihua on 2020/4/16.
//

import Fluent
import Vapor

final class RefreshToken: Model {

    static let schema = "refresh_tokens"

    typealias Token = String

    @ID(key: .id)var id: UUID?
    @Field(key: FieldKeys.token) var token: Token
    @Parent(key: FieldKeys.userId) var user: User
    @Field(key: FieldKeys.expiresAt)var expiresAt: Date

    init() { }

    init(id: UUID? = nil, userId: UUID, token: Token) {
        self.id = id
        self.$user.id = userId
        self.token = token
        self.expiresAt = Date().addingTimeInterval(Const.expirationInterval)
    }
}

extension RefreshToken {
    struct FieldKeys {
        static var token: FieldKey { "token" }
        static var userId: FieldKey { "user_id" }
        static var expiresAt: FieldKey { "expires_at" }
    }
}

extension RefreshToken {
    struct Const {
        static let expirationInterval: TimeInterval = 3600 * 24  * 360// a day
    }

}
