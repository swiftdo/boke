//
//  File.swift
//  
//
//  Created by laijihua on 2020/5/6.
//

import Vapor
import Fluent

struct BookletController: RouteCollection {

    func boot(routes: RoutesBuilder) throws {
        routes.group("booklet") { booklet in
            /// 小册列表
            booklet.get("list", use: bookletList)
            booklet.get(":id", use: bookletDetail)

            /// 小册目录树
            booklet.get("catalog", use: catalogDetail)
            booklet.get("catalog", ":id", use: catalogSubs)

            let authGroup = booklet.grouped(AccessToken.authenticator(), User.guardMiddleware())

            /// 小册添加
            authGroup.post("add", use: bookletAdd)

            /// 小册更新
            authGroup.post("update", use: bookletUpdate)

            /// 小册删除
            authGroup.post("delete", ":id", use: bookletDelete)

            /// 目录添加
            authGroup.post("catalog", "add", use: catalogAdd)

            /// 目录更新
            authGroup.post("catalog", "update", use: catalogUpdate)

            /// 目录删除
            authGroup.post("catalog", "delete", ":id", use: catalogDelete)

        }
    }
}

extension BookletController {

    func bookletList(_ req: Request) throws -> EventLoopFuture<OutputJson<Page<OutputBooklet>>> {
        return Booklet.query(on: req.db).with(\.$author).paginate(for: req).map {
            $0.map { OutputBooklet(booklet: $0)}
        }.map {
            OutputJson(success: $0)
        }
    }

    func catalogDetail(_ req: Request) throws -> EventLoopFuture<OutputJson<[OutputCatalog]>> {
        return req.repositoryCatalogs.findMenuTree().map {
            OutputJson(success: $0)
        }
    }

    func catalogSubs(_ req: Request) throws -> EventLoopFuture<OutputJson<[OutputCatalog]>> {

        guard let idStr = req.parameters.get("id", as: String.self), let id = UUID(uuidString: idStr) else {
            throw ApiError(code: OutputStatus.missParameters)
        }
        return req.repositoryCatalogs.findMenuTreeAt(catalogId: id).map{
             OutputJson(success: $0)
        }
    }

    func bookletDetail(_ req: Request) throws -> EventLoopFuture<OutputJson<OutputBooklet>> {
        guard let idStr = req.parameters.get("id", as: String.self), let id = UUID(uuidString: idStr) else {
            throw ApiError(code: OutputStatus.missParameters)
        }
        return req.repositoryBooklets
            .find(id)
            .unwrap(or: ApiError(code: .bookletNotExist))
            .map { OutputJson(success: OutputBooklet(booklet: $0)) }
    }

    func bookletAdd(_ req: Request) throws -> EventLoopFuture<OutputJson<OutputBooklet>> {
        guard let user = req.auth.get(User.self) else {
            throw ApiError(code: OutputStatus.userNotExist)
        }
        let bookletInput = try req.content.decode(InputBooklet.self)
        let catelog = Catalog(title: bookletInput.name, remarks: bookletInput.remarks)
        return req.repositoryCatalogs
            .saveBy(menu: catelog)
            .transform(to: catelog)
            .flatMapThrowing{ catalog in
                return try Booklet(name: bookletInput.name, userId: user.requireID(), catalogId: catelog.requireID(), cover: bookletInput.cover, remarks: bookletInput.remarks)
            }
            .flatMap{
                return req.repositoryBooklets.create(booklet: $0).map{ OutputJson(success: OutputBooklet(booklet: $0, author: user)) }
            }
    }

    func bookletUpdate(_ req: Request) throws -> EventLoopFuture<OutputJson<OutputBooklet>> {
        let inputBooklet = try req.content.decode(InputBooklet.self)
        var uuid: UUID? = nil
        if let id = inputBooklet.id {
            uuid = UUID(uuidString: id)
        }
        guard let bookletId = uuid else {
            throw ApiError(code: OutputStatus.missParameters)
        }

        return req.repositoryBooklets
            .find(bookletId)
            .unwrap(or: ApiError(code: .bookletNotExist))
            .flatMap { booklet in
                booklet.name = inputBooklet.name
                booklet.remarks = inputBooklet.remarks
                booklet.cover = inputBooklet.cover
                return req.repositoryBooklets.update(booklet: booklet).transform(to: booklet)
        }.map {
            OutputJson(success: OutputBooklet(booklet: $0))
        }
    }

    func bookletDelete(_ req: Request) throws -> EventLoopFuture<OutputJson<String>> {
        guard let idStr = req.parameters.get("id", as: String.self), let id = UUID(uuidString: idStr) else {
            throw ApiError(code: OutputStatus.missParameters)
        }
        return req.repositoryBooklets.delete(id).transform(to: OutputJson(success: "成功删除"))
    }

    func catalogAdd(_ req: Request) throws -> EventLoopFuture<OutputJson<OutputCatalog>> {
        guard let user = req.auth.get(User.self) else {
            throw ApiError(code: OutputStatus.userNotExist)
        }
        let catalogInput = try req.content.decode(InputCatalog.self)
        return req.repositorySubjects
            .find(name: "booklet")
            .unwrap(or: ApiError(code: .bookletNotExist))
            .flatMapThrowing { subject in
                return try Topic(title: catalogInput.title, content: catalogInput.content, subjectID: subject.requireID(), authorID: user.requireID(), contentType: Topic.ContentType.markdown)
            }.flatMap { topic in
                return req.repositoryTopics.create(topic).transform(to: topic)
            }.flatMapThrowing {
                var pid : UUID? = nil
                if let tpid = catalogInput.pid {
                    pid = UUID(uuidString: tpid)
                }

                return try Catalog(pid: pid,
                           title: catalogInput.title,
                           remarks: catalogInput.remarks,
                           path: catalogInput.path,
                           level: catalogInput.level,
                           order: catalogInput.order,
                           topicId: $0.requireID())
            }.flatMap {
                return req.repositoryCatalogs.saveBy(menu: $0).map { OutputJson(success: OutputCatalog(catalog: $0))}
            }
    }

    func catalogUpdate(_ req: Request) throws -> EventLoopFuture<OutputJson<OutputCatalog>> {
        guard let _ = req.auth.get(User.self) else {
            throw ApiError(code: OutputStatus.userNotExist)
        }

        let catalogInput = try req.content.decode(InputCatalog.self)

        guard let catalogId = catalogInput.id, let uuid = UUID(uuidString: catalogId) else {
            throw ApiError(code: OutputStatus.missParameters)
        }

        return req.repositoryCatalogs
            .findBy(menuId: uuid)
            .unwrap(or: ApiError(code: .catalogNotExist))
            .flatMap { catalog in
                catalog.title = catalogInput.title
                catalog.level = catalogInput.level
                catalog.path = catalogInput.path
                catalog.order = catalogInput.order

                let topicUpdate: EventLoopFuture<Topic> = req.repositoryTopics
                    .find(catalog.topicId!)
                    .unwrap(or: ApiError(code: .topicNotExist))
                    .flatMap { topic in
                        topic.title = catalogInput.title
                        topic.content = catalogInput.content
                        return req.repositoryTopics.save(topic)
                    }

                return req.repositoryCatalogs
                    .saveBy(menu: catalog)
                    .and(topicUpdate)
                    .transform(to: OutputJson(success: OutputCatalog(catalog: catalog)))
        }

    }

    func catalogDelete(_ req: Request) throws -> EventLoopFuture<OutputJson<String>> {
        guard let idStr = req.parameters.get("id", as: String.self), let id = UUID(uuidString: idStr) else {
            throw ApiError(code: OutputStatus.missParameters)
        }

        return req.repositoryCatalogs
            .findBy(menuId: id)
            .unwrap(or: ApiError(code: .catalogNotExist))
            .flatMap{ catalog in
                req.repositoryCatalogs.removeBy(menu: catalog)
            }.transform(to: OutputJson(success: "删除成功"))
    }
}
