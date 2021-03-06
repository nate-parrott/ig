//
//  Helpers.swift
//  CommandPrompt
//
//  Created by Nate Parrott on 9/2/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

import Foundation

func indexOfOutlier(data: [Double], tolerableDeviance: Double) -> Int? {
    let inlierProbs = (0..<data.count).map({ probabilityOfInlier(data + [mean(data) + tolerableDeviance], index: $0) })
    // println("\(inlierProbs)")
    let cutoff = 1.0
    let lowest = minItem(inlierProbs)
    if lowest < cutoff {
        let index = inlierProbs.indexOf(lowest)!
        if index == data.count {
            return nil
        } else {
            return index
        }
    } else {
        return nil
    }
}

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
    func mapFilter<T2>(fn: Element -> T2?) -> [T2] {
        return self.map(fn).filter({ $0 != nil }).map({ $0! })
    }
}

extension NSURL {
    func queryValueForKey(key: String) -> String? {
        if let components = NSURLComponents(URL: self, resolvingAgainstBaseURL: false) {
            let matchingItems = (components.queryItems ?? []).filter({ $0.name == key })
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
        let fromIndex = self.startIndex.advancedBy(start)
        let toIndex = self.startIndex.advancedBy(start + length)
        let range = fromIndex..<toIndex
        return self[range]
    }
}

func delay(delay:Double, closure:()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
}

func normpdf(x: Double, mean: Double, stddev: Double) -> Double {
    let variance = pow(stddev, 2.0)
    let denom = sqrt(2 * M_PI * variance)
    let numerator = exp(-pow(x-mean, 2) / (2 * variance))
    return numerator / denom
}

func sum(data: [Double]) -> Double {
    return data.reduce(0, combine: {$0.0 + $0.1})
}

func mean(data: [Double]) -> Double {
    return sum(data) / Double(data.count)
}

func stddev(data: [Double]) -> Double {
    let m = mean(data)
    return sqrt(sum(data.map({ pow($0 - m, 2) })))
}

func probabilityOfInlier(data: [Double], index: Int) -> Double {
    let dataWithoutIndex = Array(data[0..<index]) + Array(data[index+1..<data.count])
    return normpdf(data[index], mean: mean(dataWithoutIndex), stddev: stddev(dataWithoutIndex))
}

func minItem(data: [Double]) -> Double {
    return data.reduce(data[0], combine: {min($0.0, $0.1)})
}

