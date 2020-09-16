//
//  Queue.swift
//  AASwiftSDK
//
//  Created by Brett Clifton on 10/5/20.
//  Copyright © 2020 AdAdapted. All rights reserved.
//

import Foundation

public struct Queue<T> {

  fileprivate var list = LinkedList<T>()

  public var isEmpty: Bool {
    return list.isEmpty
  }
  
  public mutating func enqueue(_ element: T) {
    list.append(value: element)
  }
    
  public mutating func dequeue() -> T? {
    guard !list.isEmpty, let element = list.first else { return nil }

    list.remove(node: element)

    return element.value
  }

  public func peek() -> T? {
    return list.first?.value
  }
    
    public func hasItems() -> Bool {
        return !list.isEmpty
    }
}
