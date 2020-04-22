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
            .field("user_id", .uuid, .references(User.schema, "id"))
            .field("token", .string, .required)
            .field("expires_at", .datetime, .required)
            .unique(on:"user_id")
            .unique(on:"token")
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(AccessToken.schema).delete()
    }
}
