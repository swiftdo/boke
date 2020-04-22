//
//  File.swift
//  
//
//  Created by laijihua on 2020/4/16.
//

import Fluent
import Vapor

final class RefreshToken: Model, Content {
    static let schema = "refresh_tokens"
    typealias Token = String

    @ID(key: .id)
    var id: UUID?

    @Field(key: "token")
    var token: Token

    @Parent(key: "user_id")
    var user: User

    @Field(key: "expires_at")
    var expiresAt: Date


    init() { }

    init(id: UUID? = nil, userId: UUID, token: Token) {
        self.id = id
        self.$user.id = userId
        self.token = token
        self.expiresAt = Date().addingTimeInterval(Const.expirationInterval)
    }
}

extension RefreshToken {
    struct Const {
        static let expirationInterval: TimeInterval = 3600 * 24  * 360// a day
    }

}
