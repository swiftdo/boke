//
//  File.swift
//  
//
//  Created by laijihua on 2020/11/10.
//
import Fluent
import Vapor

/// 角色
final class Role: Model {
    static let schema = "roles"

    @ID(key: .id)var id: UUID?
    @Field(key: FieldKeys.name) var name: String

    @Siblings(through: RolePermission.self, from: \.$role, to: \.$permission) var permissons: [Permission]
    @Children(for: \.$role) var users: [User]

    init(){ }

    init(name: String) {
        self.name = name
    }
}

extension Role {
    struct FieldKeys {
        static var name: FieldKey { "name" }
    }
}
