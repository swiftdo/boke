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

    try app.autoMigrate().wait()
}
