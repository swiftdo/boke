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
            .field("name", .string, .required)
            .field("remarks", .string)
            .field("cover", .string)
            .field("created_at", .datetime)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(Subject.schema).delete()
    }
}
