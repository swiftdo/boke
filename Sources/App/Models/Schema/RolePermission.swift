//
//  File.swift
//  
//
//  Created by laijihua on 2020/11/10.
//


import Fluent
import Vapor

final class RolePermission: Model {

    static let schema = "roles_permissions"

    @ID(key: .id) var id: UUID?
    @Parent(key: FieldKeys.roleId) var role: Role
    @Parent(key: FieldKeys.permissionId) var permission: Permission

    init() {}

    init(roleId: UUID, permissionId: UUID) {
        self.$role.id = roleId
        self.$permission.id = permissionId
    }

}

extension RolePermission {
    struct FieldKeys {
        static var roleId: FieldKey { "role_id" }
        static var permissionId: FieldKey { "permission_id" }
    }
}
