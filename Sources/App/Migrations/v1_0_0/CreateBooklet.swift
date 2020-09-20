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
            .field(Booklet.FieldKeys.name, .string, .required)
            .field(Booklet.FieldKeys.cover, .string)
            .field(Booklet.FieldKeys.remarks, .string)
            .field(Booklet.FieldKeys.authorId, .uuid, .references(User.schema, .id), .required)
            .field(Booklet.FieldKeys.catalogId, .uuid, .required)
            .field(Booklet.FieldKeys.createdAt, .datetime)
            .field(Booklet.FieldKeys.updatedAt, .datetime)
            .field(Booklet.FieldKeys.deletedAt, .datetime)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(Booklet.schema).delete()
    }
}
