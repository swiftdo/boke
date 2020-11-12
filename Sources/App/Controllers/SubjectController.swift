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
            // authenticator: 进行auth.login(), guardMiddleware: 判断 auth.get()
            let authGroup = subject.grouped(AccessToken.authenticator(), User.guardMiddleware())
            authGroup.post("add", use: add)
            authGroup.post("delete", ":id", use: delete)
            subject.get(":id", "topics", use: getTopics)
            subject.get("all", use: getChannel)
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

    private func delete(_ req: Request) throws -> EventLoopFuture<OutputJson<String>> {
        guard let idStr = req.parameters.get("id", as: String.self), let id = UUID(uuidString: idStr) else {
            throw ApiError(code: OutputStatus.missParameters)
        }
        return req.repositorySubjects.delete(for: id).transform(to: OutputJson(success: "成功删除"))
    }

    private func getChannel(_ req: Request) throws -> EventLoopFuture<OutputJson<[OutputSubject]>> {
        return req.repositorySubjects
            .channels()
            .map {
                $0.map { OutputSubject(subject: $0) }
            }.map { OutputJson(success: $0)}

    }

    private func getTopics(_ req: Request) throws -> EventLoopFuture<OutputJson<Page<OutputTopic>>> {
        if let idStr = req.parameters.get("id", as: String.self), let id = UUID(uuidString: idStr) {
            return req.repositorySubjects
                .find(id: id)
                .unwrap(or: ApiError(code: .subjectNotExist))
                .flatMap { subject in
                    return subject.$topics
                        .query(on: req.db)
                        .sort(\.$createdAt, .descending)
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
        } else { // 如果没有 subjectId, 就返回全部 topics, 除了 booklet
            return req.repositorySubjects
                .find(name: "booklet")
                .unwrap(or: ApiError.init(code: .subjectNotExist))
                .flatMapThrowing{ subject in
                    try subject.requireID()
                }
                .flatMap { subjectId in
                    return Topic
                        .query(on: req.db)
                        .filter(\.$subject.$id != subjectId) // booklet
                        .sort(\.$createdAt, .descending)
                        .with(\.$subject)
                        .with(\.$author)
                        .with(\.$tags)
                        .paginate(for: req)
                        .map { page in
                            return page.map{ OutputTopic(topic: $0) }
                        }.map {
                            return OutputJson(success: $0)
                        }
                }
        }
    }
}
