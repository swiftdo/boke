//
//  File.swift
//  
//
//  Created by laijihua on 2020/4/19.
//

import Vapor

protocol RequestService {
    func `for`(_ req: Request) -> Self
}
