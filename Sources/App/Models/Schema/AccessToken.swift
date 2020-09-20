//
//  File.swift
//  
//
//  Created by laijihua on 2020/4/16.
//

import Fluent
import Vapor

final class AccessToken: Model {

    static let schema = "access_tokens"

    typealias Token = String

    @ID(key: .id) var id: UUID?
    @Field(key: FieldKeys.token) var token: Token
    @Parent(key: FieldKeys.userId) var user: User
    @Field(key: FieldKeys.expiresAt) var expiresAt: Date

    init() { }

    init(id: UUID? = nil, userId: UUID, token: Token) {
        self.id = id
        self.$user.id = userId
        self.token = token
        self.expiresAt = Date().addingTimeInterval(Const.expirationInterval)
    }
}

extension AccessToken {
    struct FieldKeys {
        static var token: FieldKey { "token" }
        static var userId: FieldKey {"user_id" }
        static var expiresAt: FieldKey { "expires_at" }
    }
}

extension AccessToken {
    struct Const {
        static let expirationInterval: TimeInterval = 3600 * 24 // a day
    }
}

extension AccessToken: ModelTokenAuthenticatable {
    static let valueKey = \AccessToken.$token
    static let userKey = \AccessToken.$user

    var isValid: Bool {
        return self.expiresAt > Date()
    }
}
