//
//  File.swift
//  
//
//  Created by laijihua on 2020/4/19.
//

import Vapor
import Crypto


public protocol RandomGenerator {
    func generate(bits: Int) -> String
}

extension Application {

    public struct RandomGenerators {

        public struct Provider {
            let run: ((Application) -> Void)

            static var random: Self {
                .init {
                    $0.randomGenerators.use { _ in RealRandomGenerator() }
                }
            }
        }


        final class Storage {
            var makeGenerator: ((Application) -> RandomGenerator)?
            init() {}
        }

        private struct Key: StorageKey {
            typealias Value = Storage
        }

        public let app: Application

        public func use(_ provider: Provider) {
            provider.run(app)
        }

        public func use(_ makeGenerator: @escaping ((Application) -> RandomGenerator)) {
            storage.makeGenerator = makeGenerator
        }

        var storage: Storage {
            if let existing = self.app.storage[Key.self] {
                return existing
            } else {
                let new = Storage()
                self.app.storage[Key.self] = new
                return new
            }
        }
    }


}

extension Application {
    var randomGenerators: RandomGenerators {
        .init(app: self)
    }
}


extension Request {
    /// 获取 application 存储的 random
    var random: RandomGenerator {
        self.application.random
    }
}
