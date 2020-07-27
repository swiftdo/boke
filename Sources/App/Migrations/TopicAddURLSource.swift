//
//  File.swift
//  
//
//  Created by laijihua on 2020/7/17.
//

import Fluent


struct TopicAddURLSourceMigration: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Topic.schema)
            .field("url", .string)
            .field("source", .string)
            .update()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Topic.schema)
            .deleteField("url")
            .deleteField("source")
            .update()
    }
}
