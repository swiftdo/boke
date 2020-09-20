//
//  File.swift
//  
//
//  Created by laijihua on 2020/4/22.
//

import Fluent

struct CreateSubject: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(Subject.schema)
            .id()
            .field(Subject.FieldKeys.name, .string, .required)
            .field(Subject.FieldKeys.remarks, .string)
            .field(Subject.FieldKeys.cover, .string)
            .field(Subject.FieldKeys.createdAt, .datetime)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(Subject.schema).delete()
    }
}
