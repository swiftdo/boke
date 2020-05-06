//
//  File.swift
//  
//
//  Created by laijihua on 2020/4/28.
//

import Vapor
import Fluent

protocol RepositorySubject: Repository {
    func create(_ subject: Subject) -> EventLoopFuture<Void>
    func find(id: UUID?) -> EventLoopFuture<Subject?>
    func find(name: String) -> EventLoopFuture<Subject?>
    func delete(_ subject: Subject) -> EventLoopFuture<Void>
    func count() -> EventLoopFuture<Int>
    func all() -> EventLoopFuture<[Subject]>
    func delete(for subjectID: UUID) -> EventLoopFuture<Void>
}

struct DatabaseRepositorySubject: RepositorySubject, DatabaseRepository {
    let database: Database

    func create(_ subject: Subject) -> EventLoopFuture<Void> {
        return subject.create(on: database)
    }
    func find(id: UUID?) -> EventLoopFuture<Subject?> {
        return Subject.find(id, on: database)
    }
    func find(name: String) -> EventLoopFuture<Subject?> {
        return Subject.query(on: database).filter(\.$name == name).first()
    }

    func delete(_ subject: Subject) -> EventLoopFuture<Void> {
        return subject.delete(on: database)
    }
    func count() -> EventLoopFuture<Int> {
        return Subject.query(on: database).count()
    }
    func delete(for subjectID: UUID) -> EventLoopFuture<Void> {
        return Subject.query(on: database).filter(\.$id == subjectID).delete()
    }

    func all() -> EventLoopFuture<[Subject]> {
        return Subject.query(on: database).all()
    }
}

extension Application.Repositories {
    var subjects: RepositorySubject {
        guard let factory = storage.makeSubjectRepository else {
            fatalError("RefreshToken repository not configured, use: app.repositories.use")
        }
        return factory(app)
    }

    func use(_ make: @escaping (Application) -> (RepositorySubject)) {
        storage.makeSubjectRepository = make
    }
}

