//
//  File.swift
//  
//
//  Created by laijihua on 2020/11/10.
//

import Fluent

struct UserAddRoleId: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return Role
            .query(on: database)
            .filter(\.$name == ETNameSpace.Role.user.string)
            .first()
            .flatMap { role in
            return database.schema(User.schema)
                .field(User.FieldKeys.roleId, .uuid, .required, .references(Role.schema, .id), .custom("DEFAULT \(role!.id!)"))
                .update()
        }
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(User.schema)
            .deleteField(User.FieldKeys.roleId)
            .update()
    }
}

