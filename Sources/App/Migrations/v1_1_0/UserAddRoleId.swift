//
//  File.swift
//  
//
//  Created by laijihua on 2020/11/10.
//

import Fluent

struct UserAddRoleId: Migration {
    
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(User.schema)
            .field(User.FieldKeys.roleId, .uuid, .references(Role.schema, .id))
            .update()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(User.schema)
            .deleteField(User.FieldKeys.roleId)
            .update()
    }
}

