//
//  File.swift
//  
//
//  Created by laijihua on 2020/5/6.
//

import Vapor
import Fluent

protocol RepositoryBooklet: Repository {
    func create(booklet: Booklet) -> EventLoopFuture<Booklet>
    func update(booklet: Booklet) -> EventLoopFuture<Booklet>
    func find(_ id: UUID) -> EventLoopFuture<Booklet?>
    func delete(_ id: UUID) -> EventLoopFuture<Void>
}

struct DatabaseRepositoryBooklet: RepositoryBooklet, DatabaseRepository {
    let database: Database

    func create(booklet: Booklet) -> EventLoopFuture<Booklet> {
        return booklet.create(on: database).map { booklet }
    }

    func update(booklet: Booklet) -> EventLoopFuture<Booklet> {
        return booklet.update(on: database).map { booklet }
    }

    func find(_ id: UUID) -> EventLoopFuture<Booklet?> {
        return Booklet.query(on: database).with(\.$author).filter(\.$id == id).first()
    }

    func delete(_ id: UUID) -> EventLoopFuture<Void> {
        return Booklet.query(on: database).with(\.$author).filter(\.$id == id).delete()
    }
}


extension Application.Repositories {
    var booklets: RepositoryBooklet {
        guard let factory = storage.makeBookletRepository else {
            fatalError("EmailToken repository not configured, use: app.repositories.use")
        }
        return factory(app)
    }

    func use(_ make: @escaping (Application) -> (RepositoryBooklet)) {
        storage.makeBookletRepository = make
    }
}
