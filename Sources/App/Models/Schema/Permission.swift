//
//  File.swift
//  
//
//  Created by laijihua on 2020/11/10.
//
import Vapor
import Fluent
/// 权限
final class Permission: Model {
    static let schema = "permissions"

    @ID(key: .id)var id: UUID?
    @Field(key: FieldKeys.name) var name: String
    @Siblings(through: RolePermission.self, from: \.$permission, to: \.$role) var roles: [Role]

    init(){ }

    init(name: String) {
        self.name = name
    }
}

extension Permission {
    struct FieldKeys {
        static var name: FieldKey { "name" }
    }
}

