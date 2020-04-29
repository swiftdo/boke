//
//  File.swift
//  
//
//  Created by laijihua on 2020/4/28.
//

import Foundation


import Vapor
import Fluent

protocol RepositoryTag: Repository {
    func create(_ tag: Tag) -> EventLoopFuture<Void>
}

struct DatabaseRepositoryTag: RepositoryTag, DatabaseRepository {
    let database: Database

    func create(_ tag: Tag) -> EventLoopFuture<Void> {
        return tag.create(on: database)
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
