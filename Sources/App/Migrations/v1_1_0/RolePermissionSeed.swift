//
//  File.swift
//  
//
//  Created by laijihua on 2020/11/10.
//

import Fluent

struct RolePermissionSeed: Migration {

    let rolesPermissionMap:[ETNameSpace.Role: [ETNameSpace.Permission]]  = [
        .locked: [.follow, .collect],
        .user: [.follow, .collect, .comment, .upload],
        .moderator: [.follow, .collect, .comment, .upload, .moderate],
        .administrator: [.follow, .collect, .comment, .upload, .moderate, .administer]
    ]

    func prepare(on database: Database) -> EventLoopFuture<Void> {
        let futures = rolesPermissionMap.compactMap { rolePersMap -> EventLoopFuture<Void> in
            return Role
                .query(on: database)
                .filter(\.$name == rolePersMap.key.string)
                .first()
                .map { role  in
                    return (role ?? Role(name: rolePersMap.key.string)).save(on: database)
                }
                .flatMap { _ in
                    return rolePersMap.value.compactMap { (epermission) in
                        return Permission
                            .query(on: database)
                            .filter(\.$name == epermission.string)
                            .first()
                            .flatMap { permission in
                            return (permission ?? Permission(name: epermission.string)).save(on: database)
                        }
                    }.flatten(on: database.eventLoop)
                }
        }
        return database.eventLoop.flatten(futures)
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.eventLoop.flatten([
            Role.query(on: database).delete(),
            Permission.query(on: database).delete(),
        ])
    }
}
