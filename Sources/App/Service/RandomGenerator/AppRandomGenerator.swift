//
//  File.swift
//  
//
//  Created by laijihua on 2020/4/19.
//
import Vapor

struct AppRandomGenerator: RandomGenerator {
    let app: Application

    var generator: RandomGenerator {
        /// 从预先配置地方取
        guard let makeGenerator = app.randomGenerators.storage.makeGenerator else {
            fatalError("randomGenerators not configured, please use: app.randomGenerators.use")
        }

        return makeGenerator(app)
    }

    func generate(bits: Int) -> String {
        generator.generate(bits: bits)
    }
}

extension Application {
    var random: AppRandomGenerator {
        .init(app: self)
    }
}
