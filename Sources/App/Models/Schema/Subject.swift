//
//  File.swift
//  
//
//  Created by laijihua on 2020/4/22.
//

import Fluent
import Vapor

final class Subject: Content, Model {

    static let schema = "subjects"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    @OptionalField(key: "cover")
    var cover: String?

    @OptionalField(key: "remarks")
    var remarks: String?

    @Children(for: \.$subject)
    var topics: [Topic]

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    init(){ }

    init(name: String, remarks: String?, cover: String?) {
        self.name = name
        self.remarks = remarks
        self.cover = cover
    }

}
