//
//  File.swift
//  
//
//  Created by laijihua on 2020/4/22.
//

import Fluent
import Vapor

/// 目录
final class Catalog: Content, Model {

    static let schema = "catalogs"

    @ID(key: .id)
    var id: UUID?

    @OptionalParent(key: "pid")
    var parentCatalog: Catalog?

    @Field(key: "title")
    var title: String

    @OptionalField(key: "cover")
    var cover: String?

    @OptionalField(key: "remarks")
    var remarks: String?

    @OptionalField(key: "path")
    var path: String? // 表示父的 id 列表

    @Field(key: "level")
    var level: Int // 层级，辅助字段，记录该菜单是第几级

    @Field(key: "order")
    var order: Int // 权重，用于同一等级的菜单之间的排序, 数字越大，越靠前

    @OptionalField(key: "topic_id")
    var topicId: UUID? // 文章 id

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    @Timestamp(key: "deleted_at", on: .delete)
    var deletedAt: Date?

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
