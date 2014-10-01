//
//  Helpers.swift
//  CommandPrompt
//
//  Created by Nate Parrott on 9/2/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

import Foundation

func arrayContains<T:Equatable>(item: T, array: [T]) -> Bool {
    for x in array {
        if x == item {
            return true
        }
    }
    return false
}

extension Dictionary {
    func getOrDefault(key: Key, defaultVal: Value) -> Value {
        if let existing = self[key] {
            return existing
        } else {
            return defaultVal
        }
    }
    mutating func getOrSetDefault(key: Key, defaultVal: Value) -> Value {
        if let existing = self[key] {
            return existing
        } else {
            updateValue(defaultVal, forKey: key)
            return defaultVal
        }
    }
    func items() -> [(Key, Value)] {
        var items = [(Key, Value)]()
        for (k, v) in self {
            items.append((k, v))
        }
        return items
    }
    func get(key: Key) -> Value? {
        // because subscripts are fucked
        let result: Value? = self[key]
        return result
    }
}

extension Dictionary {
	func mergedWith(otherDict: [Key: Value]) -> [Key: Value] {
		var merged = self
		for (k, v) in otherDict {
			merged[k] = v
		}
		return merged
	}
}

extension Array {
	func mapFilter<T2>(fn: T -> T2?) -> [T2] {
		return self.map(fn).filter({ $0 != nil }).map({ $0! })
	}
}

extension NSURL {
    func queryValueForKey(key: String) -> String? {
        let components = NSURLComponents(URL: self, resolvingAgainstBaseURL: false)
        if let queryItems = components.queryItems as? [NSURLQueryItem] {
            let matchingItems = queryItems.filter({ $0.name == key })
            return matchingItems.first?.value
        }
        return nil
    }
}

func AsyncOnMainQueue(code: () -> ()) {
    dispatch_async(dispatch_get_main_queue(), code)
}

extension String {
    func substring(start: Int, length: Int) -> String {
        let fromIndex = advance(self.startIndex, start)
        let toIndex = advance(self.startIndex, start + length)
        let range = fromIndex..<toIndex
        return self[range]
    }
}
