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
                .field(Topic.FieldKeys.title, .string, .required)
                .field(Topic.FieldKeys.cover, .string)
                .field(Topic.FieldKeys.content, .string, .required)
                .field(Topic.FieldKeys.remarks, .string)
                .field(Topic.FieldKeys.weight, .int, .required)
                .field(Topic.FieldKeys.url, .string)
                .field(Topic.FieldKeys.source, .string)
                .field(Topic.FieldKeys.contentType, contentType, .required)
                .field(Topic.FieldKeys.subjectId, .uuid, .required, .references(Subject.schema, .id))
                .field(Topic.FieldKeys.authorId, .uuid, .required, .references(User.schema, .id))
                .field(Topic.FieldKeys.createdAt, .datetime)
                .field(Topic.FieldKeys.updatedAt, .datetime)
                .field(Topic.FieldKeys.deletedAt, .datetime)
                .create()
        }
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(Topic.schema).delete().flatMap {
             database.enum(Topic.ContentType.schema).delete()
        }
    }
}

