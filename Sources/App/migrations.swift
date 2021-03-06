//
//  File.swift
//  
//
//  Created by laijihua on 2020/4/19.
//

import Vapor

func migrations(_ app: Application) throws {
    app.migrations.add(CreateUser())
    app.migrations.add(CreateUserAuth())
    app.migrations.add(CreateRefreshToken())
    app.migrations.add(CreateEmailToken())
    app.migrations.add(CreateAccessToken())
    app.migrations.add(CreateSubject())
    app.migrations.add(CreateTopic())
    app.migrations.add(CreateTag())
    app.migrations.add(CreateCatalog())
    app.migrations.add(CreateTopicTag())
    app.migrations.add(CreateBooklet())
    app.migrations.add(BlogMigrationSeed())

    app.migrations.add(CreateRole())
    app.migrations.add(CreatePermission())
    app.migrations.add(CreateRolePermission())

    app.migrations.add(RolePermissionSeed())
    app.migrations.add(UserAddRoleId())

//    app.migrations.add(TopicAddURLSourceMigration())
//    try app.autoMigrate().wait()
}
