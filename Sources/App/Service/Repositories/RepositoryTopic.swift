//
//  File.swift
//  
//
//  Created by laijihua on 2020/4/28.
//

import Vapor
import Fluent

protocol RepositoryTopic: Repository {
    func create(_ topic: Topic) -> EventLoopFuture<Void>
}

struct DatabaseRepositoryTopic: RepositoryTopic, DatabaseRepository {
    let database: Database

    func create(_ topic: Topic) -> EventLoopFuture<Void> {
        return topic.create(on: database)
    }
}

extension Application.Repositories {
    var topics: RepositoryTopic {
        guard let factory = storage.makeTopicRepository else {
            fatalError("RepositoryTopic repository not configured, use: app.repositories.use")
        }
        return factory(app)
    }

    func use(_ make: @escaping (Application) -> (RepositoryTopic)) {
        storage.makeTopicRepository = make
    }
}
