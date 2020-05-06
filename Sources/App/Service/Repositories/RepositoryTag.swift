//
//  File.swift
//  
//
//  Created by laijihua on 2020/4/28.
//

import Vapor
import Fluent

protocol RepositoryTag: Repository {
    func create(_ tag: Tag) -> EventLoopFuture<Void>
    func find(name: String) -> EventLoopFuture<Tag?>
    func find(_ id: UUID?) -> EventLoopFuture<Tag?>
    func all() -> EventLoopFuture<[Tag]>
}

struct DatabaseRepositoryTag: RepositoryTag, DatabaseRepository {
    let database: Database

    func create(_ tag: Tag) -> EventLoopFuture<Void> {
        return tag.create(on: database)
    }

    func find(name: String) -> EventLoopFuture<Tag?> {
        return Tag.query(on: database).filter(\.$name == name).first()
    }

    func find(_ id: UUID?) -> EventLoopFuture<Tag?> {
        return Tag.find(id, on: database)
    }

    func all() -> EventLoopFuture<[Tag]> {
        return Tag.query(on: database).all()
    }
}

extension Application.Repositories {
    var tags: RepositoryTag {
        guard let factory = storage.makeTagRepository else {
            fatalError("RefreshToken repository not configured, use: app.repositories.use")
        }
        return factory(app)
    }

    func use(_ make: @escaping (Application) -> (RepositoryTag)) {
        storage.makeTagRepository = make
    }
}
