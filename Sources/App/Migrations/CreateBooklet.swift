//
//  File.swift
//  
//
//  Created by laijihua on 2020/5/6.
//

import Fluent
struct CreateBooklet: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(Booklet.schema)
            .id()
            .field("name", .string, .required)
            .field("cover", .string)
            .field("remarks", .string)
            .field("author_id", .uuid, .references(User.schema, "id"), .required)
            .field("catalog_id", .uuid, .required)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .field("deleted_at", .datetime)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(Booklet.schema).delete()
    }
}
