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
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(Catalog.schema).delete()
    }
}
