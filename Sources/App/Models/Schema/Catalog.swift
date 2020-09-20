//
//  File.swift
//  
//
//  Created by laijihua on 2020/4/22.
//


import Fluent
import Vapor

/// 目录
final class Catalog: Model {

    static let schema = "catalogs"

    @ID(key: .id) var id: UUID?
    @OptionalParent(key: FieldKeys.pid) var parentCatalog: Catalog?
    @Field(key: FieldKeys.title) var title: String
    @OptionalField(key: FieldKeys.cover) var cover: String?
    @OptionalField(key: FieldKeys.remarks) var remarks: String?
    @OptionalField(key: FieldKeys.path) var path: String? // 表示父的 id 列表
    @Field(key: FieldKeys.level) var level: Int // 层级，辅助字段，记录该菜单是第几级
    @Field(key: FieldKeys.order) var order: Int // 权重，用于同一等级的菜单之间的排序, 数字越大，越靠前
    @OptionalField(key: FieldKeys.topicId) var topicId: UUID? // 文章 id
    @Timestamp(key: FieldKeys.createdAt, on: .create) var createdAt: Date?
    @Timestamp(key: FieldKeys.updatedAt, on: .update) var updatedAt: Date?
    @Timestamp(key: FieldKeys.deletedAt, on: .delete) var deletedAt: Date?

    init() {

    }

    init(pid: UUID? = nil,
         title: String,
         remarks: String? = nil,
         path: String? = nil,
         level: Int = 1,
         order: Int = 0,
         topicId: UUID? = nil) {

        self.$parentCatalog.id = pid
        self.title = title
        self.path = path
        self.level = level
        self.order = order
        self.topicId = topicId
        self.remarks = nil
    }
}

extension Catalog {
    struct FieldKeys {
        static var pid: FieldKey { "pid" }
        static var title: FieldKey { "title" }
        static var cover: FieldKey { "cover" }
        static var remarks: FieldKey { "remarks" }
        static var path: FieldKey { "path" }
        static var level: FieldKey { "level" }
        static var order: FieldKey { "order" }
        static var topicId: FieldKey { "topic_id" }
        static var createdAt: FieldKey { "created_at" }
        static var updatedAt: FieldKey { "updated_at" }
        static var deletedAt: FieldKey { "deleted_at" }
    }
}
