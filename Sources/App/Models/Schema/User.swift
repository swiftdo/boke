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

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    @Field(key: "email")
    var email: String

    @Field(key: "is_email_verified")
    var isEmailVerified: Bool // 用户状态, default false 未激活

    @Field(key: "avatar")
    var avatar: String?

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    @Children(for: \.$user)
    var userAuths: [UserAuth]

    @Children(for: \.$author)
    var topics: [Topic]



    init() { }

    init(id: UUID? = nil, name: String, email: String, isEmailVerified: Bool = false, avatar: String? = nil) {
        self.id = id
        self.name = name
        self.email = email
        self.isEmailVerified = isEmailVerified
        self.avatar = avatar
    }
}

extension User: Authenticatable {}
