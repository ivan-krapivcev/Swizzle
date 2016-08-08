//
//  Swizzle.swift
//  Swizzle
//
//  Created by Yasuhiro Inami on 2014/09/14.
//  Copyright (c) 2014年 Yasuhiro Inami. All rights reserved.
//

import ObjectiveC

internal func swizzleMethodOf(var class_: AnyClass!, replace selector1: Selector, by selector2: Selector, isClassMethod isClassMethod: Bool) {
    if isClassMethod {
        class_ = object_getClass(class_)
    }

    let method1: Method = class_getInstanceMethod(class_, selector1)
    let method2: Method = class_getInstanceMethod(class_, selector2)

    if class_addMethod(class_, selector1, method_getImplementation(method2), method_getTypeEncoding(method2)) {
        class_replaceMethod(class_, selector2, method_getImplementation(method1), method_getTypeEncoding(method1))
    } else {
        method_exchangeImplementations(method1, method2)
    }
}

public func swizzleInstanceMethod(var class_: AnyClass!, sel1: Selector, sel2: Selector) {
    swizzleMethodOf(class_, replace: sel1, by: sel2, isClassMethod: false)
}

public func swizzleClassMethod(var class_: AnyClass!, sel1: Selector, sel2: Selector) {
    swizzleMethodOf(class_, replace: sel1, by: sel2, isClassMethod: true)
}

//--------------------------------------------------
// MARK: - Custom Operators
// + - * / % = < > ! & | ^ ~ .
//--------------------------------------------------

infix operator <-> { associativity left }

/// Usage: (MyObject.self, "hello") <-> "bye"
public func <-> (tuple: (class_: AnyClass!, selector1: Selector), selector2: Selector) {
    swizzleInstanceMethod(tuple.class_, sel1: tuple.selector1, sel2: selector2)
}

infix operator <+> { associativity left }

/// Usage: (MyObject.self, "hello") <+> "bye"
public func <+> (tuple: (class_: AnyClass!, selector1: Selector), selector2: Selector) {
    swizzleClassMethod(tuple.class_, sel1: tuple.selector1, sel2: selector2)
}
