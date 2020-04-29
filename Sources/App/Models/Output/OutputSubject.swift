//
//  File.swift
//  
//
//  Created by laijihua on 2020/4/28.
//

import Foundation

struct OutputSubject: Output {

    let id: UUID?
    let name: String

    init(subject: Subject) {
        self.id = subject.id
        self.name = subject.name
    }
}
