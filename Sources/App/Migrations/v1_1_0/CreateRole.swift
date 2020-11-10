//
//  File.swift
//  
//
//  Created by laijihua on 2020/11/10.
//

import Fluent

struct CreateRole: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(Role.schema)
            .id()
            .field(Role.FieldKeys.name, .string, .required)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(Role.schema).delete()
    }
}

