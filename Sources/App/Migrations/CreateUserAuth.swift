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
            .flatMap { autuType in
                return database.schema(UserAuth.schema)
                    .id()
                    .field("user_id", .uuid, .references(User.schema, "id"))
                    .field("identifier", .string, .required)
                    .field("credential", .string, .required)
                    .field("auth_type", autuType, .required)
                    .field("created_at", .datetime)
                    .field("updated_at", .datetime)
                    .create()
        }
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(UserAuth.schema).delete().flatMap {
            database.enum(UserAuth.AuthType.schema).delete()
        }
    }
}
