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
            .field(Catalog.FieldKeys.pid, .uuid)
            .field(Catalog.FieldKeys.title, .string, .required)
            .field(Catalog.FieldKeys.path, .string)
            .field(Catalog.FieldKeys.cover, .string)
            .field(Catalog.FieldKeys.remarks, .string)
            .field(Catalog.FieldKeys.level, .int, .required)
            .field(Catalog.FieldKeys.order, .int, .required)
            .field(Catalog.FieldKeys.topicId, .uuid)
            .field(Catalog.FieldKeys.createdAt, .datetime)
            .field(Catalog.FieldKeys.updatedAt, .datetime)
            .field(Catalog.FieldKeys.deletedAt, .datetime)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(Catalog.schema).delete()
    }
}
