//
//  File.swift
//  
//
//  Created by laijihua on 2020/4/22.
//

import Fluent

struct CreateTopic: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(Topic.schema)
            .id()
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(Topic.schema).delete()
    }
}

