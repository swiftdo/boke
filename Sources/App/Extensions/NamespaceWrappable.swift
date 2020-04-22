//
//  File.swift
//  
//
//  Created by laijihua on 2020/4/19.
//

import Foundation

/// 添加扩展前缀
public protocol NamespaceWrappable {
    associatedtype WrapperType
    var ob: WrapperType { get }
    static var ob: WrapperType.Type { get }
}

public extension NamespaceWrappable {
    var ob: NamespaceWrapper<Self> {
        return NamespaceWrapper(value: self)
    }

    static var ob: NamespaceWrapper<Self>.Type {
        return NamespaceWrapper.self
    }
}

public protocol TypeWrapperProtocol {
    associatedtype WrappedType
    var warppedValue: WrappedType { get }
    init(value: WrappedType)
}

public struct NamespaceWrapper<T>: TypeWrapperProtocol {
    public let warppedValue: T

    public init(value: T) {
        self.warppedValue = value
    }
}
