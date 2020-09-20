//
//  File.swift
//  
//
//  Created by laijihua on 2020/4/19.
//

import Fluent

struct CreateEmailToken: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(EmailToken.schema)
            .id()
            .field(EmailToken.FieldKeys.userId, .uuid, .references(User.schema, .id))
            .field(EmailToken.FieldKeys.token, .string, .required)
            .field(EmailToken.FieldKeys.expiresAt, .datetime, .required)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(EmailToken.schema).delete()
    }
}
