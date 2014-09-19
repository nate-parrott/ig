//
//  Set.swift
//  CommandPrompt
//
//  Created by Nate Parrott on 9/3/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

import Foundation

public class Set<T:Hashable> : SequenceType, Printable {
    public init() {
        
    }
    public init(array: [T]) {
        for item in array {
            add(item)
        }
    }
    // right now, sets are just represented as dictionaries
    private var items = [T: Bool]()
    
    public func add(item: T) {
        items[item] = true
    }
    public func remove(item: T) {
        items.removeValueForKey(item)
    }
    public func contains(item: T) -> Bool {
        return items.getOrDefault(item, defaultVal: false)
    }
    public func array() -> [T] {
        return Array(items.keys)
    }
    public func any() -> T? {
        // TODO: more efficient:
        for (k, v) in items {
            return k
        }
        return nil
    }
    
    public func generate() -> GeneratorOf<T> {
        var i = 0
        let allItems = array()
        let length = countElements(allItems)
        return GeneratorOf<T> {
            return i >= length ? nil : allItems[i++]
        }
    }
    
    public var description: String {
        get {
            let itemDescriptions = array().map({"\($0)"}).sorted({ $0 < $1 }).reduce("", combine: {$0 + ", " + $1})
            return "Set(\(itemDescriptions))"
        }
    }
}

public func +<T>(lhs: Set<T>, rhs: Set<T>) -> Set<T> {
    return Set<T>(array: lhs.array() + rhs.array())
}

public func -<T>(lhs: Set<T>, rhs: Set<T>) -> Set<T> {
    let set = Set(array: lhs.array())
    for item in rhs {
        set.remove(item)
    }
    return set
}
