//
//  File.swift
//  
//
//  Created by laijihua on 2020/4/19.
//

import Fluent

struct CreateAccessToken: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(AccessToken.schema)
            .id()
            .field(AccessToken.FieldKeys.userId, .uuid, .references(User.schema, .id))
            .field(AccessToken.FieldKeys.token, .string, .required)
            .field(AccessToken.FieldKeys.expiresAt, .datetime, .required)
            .unique(on: AccessToken.FieldKeys.userId)
            .unique(on: AccessToken.FieldKeys.token)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(AccessToken.schema).delete()
    }
}
