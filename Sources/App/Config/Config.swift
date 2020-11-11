//
//  File.swift
//  
//
//  Created by laijihua on 2020/9/27.
//

import Vapor

struct MyConfig {
    /// 本地开发
    let urlPre = "https://sb.loveli.site/api/"
    let adminEmail = "1164258202@qq.com"
}

struct MyConfigKey: StorageKey {
    typealias Value = MyConfig
}

extension Application {
    var myConfig: MyConfig? {
        get {
            self.storage[MyConfigKey.self]
        }
        set {
            self.storage[MyConfigKey.self] = newValue
        }
    }
}

extension Request {
    var myConfig: MyConfig {
        return application.myConfig!
    }
}
