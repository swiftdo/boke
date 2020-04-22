//
//  File.swift
//  
//
//  Created by laijihua on 2020/4/19.
//

import Foundation

extension String: NamespaceWrappable {}

extension TypeWrapperProtocol where WrappedType == String {
    public func base64URLEscaped() -> String {
        return self.warppedValue
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }

    public func base64URLUnescaped() -> String {
        let replaced = self.warppedValue
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        /// https://stackoverflow.com/questions/43499651/decode-base64url-to-base64-swift
        let padding = replaced.count % 4
        if padding > 0 {
            return replaced + String(repeating: "=", count: 4 - padding)
        } else {
            return replaced
        }
    }
}
