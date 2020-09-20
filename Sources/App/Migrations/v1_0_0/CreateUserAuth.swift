//
//  File.swift
//  
//
//  Created by laijihua on 2020/4/16.
//

import Fluent

struct CreateUserAuth: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.enum(UserAuth.AuthType.schema)
            .case("email")
            .case("wxapp")
            .create()
            .flatMap { authType in
                database.schema(UserAuth.schema)
                    .id()
                    .field(UserAuth.FieldKeys.userId, .uuid, .references(User.schema, .id))
                    .field(UserAuth.FieldKeys.authType, authType, .required)
                    .field(UserAuth.FieldKeys.identifier, .string, .required)
                    .field(UserAuth.FieldKeys.credential, .string, .required)
                    .field(UserAuth.FieldKeys.createdAt, .datetime)
                    .field(UserAuth.FieldKeys.updatedAt, .datetime)
                    .create()
        }
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(UserAuth.schema).delete().flatMap {
            database.enum(UserAuth.AuthType.schema).delete()
        }
    }
}
