//
//  File.swift
//  
//
//  Created by laijihua on 2020/4/28.
//

import Foundation

struct OutputTopic: Output {
    let id: UUID?
    let title: String
    let cover: String?
    let subject: OutputSubject
    let author: OutputUser
    let tags: [OutputTag]
    let contentType: Topic.ContentType
    let weight: Int
    let createdAt: TimeInterval?
    let remarks: String?
    let content: String

    init(topic: Topic) {
        self.id = topic.id
        self.title = topic.title
        self.cover = topic.cover
        self.subject = OutputSubject(subject: topic.subject)
        self.author = OutputUser(from:  topic.author)
        self.tags = topic.tags.map { OutputTag(tag: $0)}
        self.contentType = topic.contentType
        self.weight = topic.weight
        self.remarks = topic.remarks
        self.createdAt = topic.createdAt?.timeIntervalSince1970
        self.content = topic.content
    }

}
