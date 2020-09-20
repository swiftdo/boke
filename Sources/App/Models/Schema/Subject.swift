//
//  File.swift
//  
//
//  Created by laijihua on 2020/4/22.
//

import Fluent
import Vapor

final class Subject: Model {

    static let schema = "subjects"

    @ID(key: .id) var id: UUID?
    @Field(key: FieldKeys.name) var name: String
    @OptionalField(key: FieldKeys.cover) var cover: String?
    @OptionalField(key: FieldKeys.remarks) var remarks: String?
    @Children(for: \.$subject) var topics: [Topic]
    @Timestamp(key: FieldKeys.createdAt, on: .create) var createdAt: Date?

    init(){ }

    init(name: String, remarks: String?, cover: String?) {
        self.name = name
        self.remarks = remarks
        self.cover = cover
    }
}

extension Subject {
    struct FieldKeys {
        static var name: FieldKey { "name" }
        static var cover: FieldKey { "cover" }
        static var remarks: FieldKey { "remarks" }
        static var createdAt: FieldKey { "created_at" }
    }
}
