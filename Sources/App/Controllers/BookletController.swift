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

}
