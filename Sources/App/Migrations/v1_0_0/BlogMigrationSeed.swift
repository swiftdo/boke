//
//  File.swift
//  
//
//  Created by laijihua on 2020/9/20.
//

import Fluent

struct BlogMigrationSeed: Migration {

    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.eventLoop.flatten([
            [
                Tag(name: "empty", remarks: "booklet 的文章"),
                Tag(name: "Swift", remarks: "Swift 文章")
            ].create(on: database),

            [
                Subject(name: "booklet", remarks: "booklet 的文章", cover: nil),
                Subject(name: "博客", remarks: "博客文章", cover: nil),
            ].create(on: database)
        ])
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.eventLoop.flatten([
            Tag.query(on: database).delete(),
            Subject.query(on: database).delete(),
        ])
    }
}

