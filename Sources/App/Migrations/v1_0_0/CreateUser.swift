//
//  File.swift
//  
//
//  Created by laijihua on 2020/4/16.
//

import Fluent

struct CreateUser: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(User.schema)
            .id()
            .field(User.FieldKeys.name, .string, .required)
            .field(User.FieldKeys.email, .string, .required)
            .field(User.FieldKeys.avatar, .string)
            .field(User.FieldKeys.isEmailVerified, .bool, .required, .custom("DEFAULT FALSE"))
            .field(User.FieldKeys.createdAt, .datetime)
            .field(User.FieldKeys.updatedAt, .datetime)
            .unique(on: User.FieldKeys.email)
        .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(User.schema).delete()
    }
}
