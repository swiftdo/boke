//
//  File.swift
//  
//
//  Created by laijihua on 2020/4/19.
//

import Fluent

struct CreateRefreshToken: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(RefreshToken.schema)
            .id()
            .field(RefreshToken.FieldKeys.userId, .uuid, .references(User.schema, .id))
            .field(RefreshToken.FieldKeys.token, .string, .required)
            .field(RefreshToken.FieldKeys.expiresAt, .datetime, .required)
            .unique(on:RefreshToken.FieldKeys.userId)
            .unique(on:RefreshToken.FieldKeys.token)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(RefreshToken.schema).delete()
    }
}
