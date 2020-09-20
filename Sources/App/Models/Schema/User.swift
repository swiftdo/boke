//
//  File.swift
//  
//
//  Created by laijihua on 2020/4/16.
//

import Fluent
import Vapor

final class User: Model, Content {

    static let schema = "users"

    @ID(key: .id) var id: UUID?
    @Field(key: FieldKeys.name) var name: String
    @Field(key: FieldKeys.email) var email: String
    @Field(key: FieldKeys.isEmailVerified) var isEmailVerified: Bool // 用户状态, default false 未激活
    @Field(key: FieldKeys.avatar) var avatar: String?
    @Timestamp(key: FieldKeys.createdAt, on: .create) var createdAt: Date?
    @Timestamp(key: FieldKeys.updatedAt, on: .update) var updatedAt: Date?
    @Children(for: \.$user) var userAuths: [UserAuth]
    @Children(for: \.$author) var topics: [Topic]

    init() { }

    init(id: UUID? = nil, name: String, email: String, isEmailVerified: Bool = false, avatar: String? = nil) {
        self.id = id
        self.name = name
        self.email = email
        self.isEmailVerified = isEmailVerified
        self.avatar = avatar
    }
}

extension User {
    struct FieldKeys {
        static var name: FieldKey { "name" }
        static var email: FieldKey {"email" }
        static var isEmailVerified: FieldKey { "is_email_verified" }
        static var avatar: FieldKey { "avatar" }
        static var createdAt: FieldKey { "created_at" }
        static var updatedAt: FieldKey { "updated_at" }
    }
}

extension User: Authenticatable {}
