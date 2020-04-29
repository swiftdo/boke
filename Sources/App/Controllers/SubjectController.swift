//
//  File.swift
//  
//
//  Created by laijihua on 2020/4/28.
//

import Fluent
import Vapor

struct SubjectController: RouteCollection {

    func boot(routes: RoutesBuilder) throws {
        routes.group("subject") { subject in
            let authGroup = subject.grouped(AccessToken.authenticator(), User.guardMiddleware())
            authGroup.post("add", use: add)
            subject.get(":id", "topics", use: getTopics)
        }
    }
}

extension SubjectController {
    private func add(_ req: Request) throws -> EventLoopFuture<OutputJson<OutputSubject>> {
        let inputSubject = try req.content.decode(InputSubject.self)
        return req.repositorySubjects
            .find(name: inputSubject.name)
            .guard({ $0 == nil }, else: ApiError(code: .subjectExist))
            .transform(to: Subject(name: inputSubject.name, remarks: inputSubject.remarks, cover: inputSubject.cover))
            .flatMap { subject in
                return req.repositorySubjects.create(subject).map { _ in OutputJson(success: OutputSubject(subject: subject))}
            }
    }

    private func getTopics(_ req: Request) throws -> EventLoopFuture<OutputJson<Page<OutputTopic>>> {
        guard let idStr = req.parameters.get("id", as: String.self), let id = UUID(uuidString: idStr) else {
            throw ApiError(code: OutputStatus.missParameters)
        }

        return req.repositorySubjects
            .find(id: id)
            .unwrap(or: ApiError(code: .subjectNotExist))
            .flatMap { subject in
                return subject.$topics
                    .query(on: req.db)
                    .with(\.$subject)
                    .with(\.$author)
                    .with(\.$tags)
                    .paginate(for: req)
                    .map { page in
                        return page.map{ OutputTopic(topic: $0) }
                }
        }.map {
            OutputJson(success: $0)
        }
    }
}
