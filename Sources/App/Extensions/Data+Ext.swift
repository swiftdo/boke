//
//  File.swift
//  
//
//  Created by laijihua on 2020/4/19.
//

import Foundation

extension Data: NamespaceWrappable {}

extension TypeWrapperProtocol where WrappedType == Data {
    public func base64URLEncodedString(options: Data.Base64EncodingOptions = []) -> String {
        return self.warppedValue
            .base64EncodedString(options: options)
            .ob
            .base64URLEscaped()
    }
}
