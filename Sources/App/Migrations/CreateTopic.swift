//
//  File.swift
//  
//
//  Created by laijihua on 2020/4/22.
//

import Fluent

struct CreateTopic: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.enum(Topic.ContentType.schema)
            .case("markdown")
            .case("html")
            .create()
            .flatMap { contentType in
                 return database.schema(Topic.schema)
                    .id()
                    .field("title", .string, .required)
                    .field("cover", .string)
                    .field("remarks", .string)
                    .field("subject_id", .uuid, .required, .references(Subject.schema, "id"))
                    .field("author_id", .uuid, .required, .references(User.schema, "id"))
                    .field("content", .string, .required)
                    .field("weight", .int, .required)
                    .field("content_type", contentType, .required)
                    .field("created_at", .datetime)
                    .field("updated_at", .datetime)
                    .field("deleted_at", .datetime)
                    .create()
            }
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(Topic.schema).delete().flatMap {
             database.enum(Topic.ContentType.schema).delete()
        }
    }
}

