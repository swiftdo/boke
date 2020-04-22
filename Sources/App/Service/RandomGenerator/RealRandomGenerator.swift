//
//  File.swift
//  
//
//  Created by laijihua on 2020/4/19.
//

import Foundation

struct RealRandomGenerator: RandomGenerator {
    func generate(bits: Int) -> String {
        [UInt8].random(count: bits / 8).hex
    }
}
