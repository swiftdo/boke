//
//  File.swift
//  
//
//  Created by laijihua on 2020/4/29.
//

import Vapor

struct InputTopic: Input {
    var title: String // 必传
    var content: String
    var cover: String?
    var subjectId: String // 必传
    var tagIds: String // 必传, tagid 分割
    var remarks: String?
    var contentType: Topic.ContentType // 必传
    var weight: Int // 权重
    var url: Stirng? // 转载文章的来源
    var source: String? // 转载来源
}

extension InputTopic: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("title", as: String.self, is: !.empty)
        validations.add("content", as: String.self, is: !.empty, required: true)
        validations.add("subjectId", as: String.self, is: !.empty)
        validations.add("tagIds", as: String.self, is: !.empty)
        validations.add("contentType", as: Topic.ContentType.self, required: true)
        validations.add("weight", as: Int.self, required: true)
    }
}
