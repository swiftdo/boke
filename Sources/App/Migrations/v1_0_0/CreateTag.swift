//
//  File.swift
//  
//
//  Created by laijihua on 2020/4/22.
//

import Fluent

struct CreateTag: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(Tag.schema)
            .id()
            .field(Tag.FieldKeys.name, .string, .required)
            .field(Tag.FieldKeys.remarks, .string)
            .field(Tag.FieldKeys.createdAt, .datetime)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(Tag.schema).delete()
    }
}
