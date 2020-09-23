//
//  File.swift
//  
//
//  Created by laijihua on 2020/9/24.
//

import Vapor
import Queues
import SMTP

struct EmailContent : Codable {
    let to: String
    let message: String
    let subject: String
}

struct EmailJob: Job {

    typealias Payload = EmailContent

    func dequeue(_ context: QueueContext, _ payload: EmailContent) -> EventLoopFuture<Void> {
        let email = Email(from: EmailAddress(address: "13576051334@163.com", name: "lai"), to: [EmailAddress(address: payload.to, name: "小号")], subject: payload.subject, body: payload.message)

        let _ = SMTP(application: context.application, on: context.eventLoop).send(email)

        return context.eventLoop.future()
    }
}
