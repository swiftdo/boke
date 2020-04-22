//
//  File.swift
//  
//
//  Created by laijihua on 2020/4/19.
//

import Crypto
import Foundation

extension SHA256Digest: NamespaceWrappable {}
extension TypeWrapperProtocol where WrappedType == SHA256Digest {
    var base64: String {
        Data(warppedValue).base64EncodedString()
    }
    var base64URLEncoded: String {
        Data(warppedValue).ob.base64URLEncodedString()
    }
}

extension SHA256: NamespaceWrappable {}
extension TypeWrapperProtocol where WrappedType == SHA256 {
    /// Returns hex-encoded string
    static func hash(_ string: String) -> String {
        hash(data: string.data(using: .utf8)!)
    }

    /// Returns a hex encoded string
    static func hash<D>(data: D) -> String where D : DataProtocol {
        SHA256.hash(data: data).hex
    }
}

