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
    func find(_ id: UUID) -> EventLoopFuture<Topic?>
    func delete(_ id: UUID) -> EventLoopFuture<Void>
    func save(_ topic: Topic) -> EventLoopFuture<Topic>
}

struct DatabaseRepositoryTopic: RepositoryTopic, DatabaseRepository {
    let database: Database

    func create(_ topic: Topic) -> EventLoopFuture<Void> {
        return topic.create(on: database)
    }

    func delete(_ id: UUID) -> EventLoopFuture<Void> {
        return Topic.query(on: database).filter(\.$id == id).delete()
    }

    func save(_ topic: Topic) -> EventLoopFuture<Topic> {
        return topic.update(on: database).map { topic }
    }

    func find(_ id: UUID) -> EventLoopFuture<Topic?> {
        return Topic.query(on: database)
            .with(\.$author)
            .with(\.$subject)
            .with(\.$tags)
            .filter(\.$id == id)
            .first()
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
