//
//  Queue.swift
//  AASwiftSDK
//
//  Created by Brett Clifton on 10/5/20.
//  Copyright © 2020 AdAdapted. All rights reserved.
//

import Foundation

public struct Queue<T> {

    fileprivate var list = [T]()

    public var isEmpty: Bool {
        return list.isEmpty
    }
  
    public mutating func enqueue(_ element: T) {
        list.append(element)
    }
    
    public mutating func dequeue() -> T? {
        guard !list.isEmpty else { return nil }

        return list.removeFirst()
    }

    public func peek() -> T? {
        guard !list.isEmpty else { return nil }
        return list.first
    }
    
    public func hasItems() -> Bool {
        return !list.isEmpty
    }
    
    public func size() -> Int {
        return list.count
    }
}
