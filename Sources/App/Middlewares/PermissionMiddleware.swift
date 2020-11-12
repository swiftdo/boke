//
//  File.swift
//  
//
//  Created by laijihua on 2020/11/12.
//

import Vapor
import Fluent


protocol PermissionFilterable: Model, Authenticatable {
    static var roleKey: KeyPath<Self, OptionalParent<Role>> { get }
}

extension PermissionFilterable {
    
    public static func permissionMiddleware(
        _ permission: ETNameSpace.Permission
    ) -> Middleware {
        PermissionFilterMiddleware<Self>(permission: permission)
    }
    
    var _$role: OptionalParent<Role> {
        self[keyPath: Self.roleKey]
    }
}


private struct PermissionFilterMiddleware<A>: Middleware
    where A: PermissionFilterable
{
    public let permission: ETNameSpace.Permission
    
    func respond(to req: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
        guard let user = req.auth.get(A.self) else {
            return req.eventLoop.makeFailedFuture(Abort(.unauthorized, reason: "\(Self.self) not authenticated."))
        }
        
        let permissionId = Permission
            .query(on: req.db)
            .filter(\.$name == permission.string)
            .first()
            .unwrap(or: ApiError(code: .permissionNotExist))
            .flatMapThrowing { try $0.requireID() }
        
        return user._$role.get(on: req.db)
            .unwrap(or: ApiError(code: .roleNotExist))
            .and(permissionId)
            .flatMap { (role: Role, perId: UUID) in
                role.$permissons.query(on: req.db).filter(\.$id == perId).count()
            }
            .guard({ $0 > 0 }, else: ApiError(code: .permissionInsufficient))
            .flatMap { _ in
                next.respond(to: req)
            }
    }

}
