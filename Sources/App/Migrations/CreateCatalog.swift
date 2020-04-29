//
//  File.swift
//  
//
//  Created by laijihua on 2020/4/22.
//

import Fluent

struct CreateCatalog: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(Catalog.schema)
            .id()
            .field("pid", .uuid)
            .field("title", .string, .required)
            .field("path", .string)
            .field("cover", .string)
            .field("remarks", .string)
            .field("level", .int, .required)
            .field("order", .int, .required)
            .field("topic_id", .uuid)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .field("deleted_at", .datetime)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(Catalog.schema).delete()
    }
}
