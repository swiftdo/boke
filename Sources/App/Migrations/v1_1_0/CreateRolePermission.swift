//
//  File.swift
//  
//
//  Created by laijihua on 2020/11/10.
//

import Fluent

struct CreateRolePermission: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(RolePermission.schema)
            .id()
            .field(RolePermission.FieldKeys.roleId, .uuid, .required, .references(Role.schema, .id))
            .field(RolePermission.FieldKeys.permissionId, .uuid, .required, .references(Permission.schema, .id))
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(RolePermission.schema).delete()
    }
}
