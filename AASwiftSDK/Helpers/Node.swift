//
//  Node.swift
//  AASwiftSDK
//
//  Created by Brett Clifton on 10/5/20.
//  Copyright © 2020 AdAdapted. All rights reserved.
//

import Foundation

public class Node<T> {
  var value: T
  var next: Node<T>?
  weak var previous: Node<T>?

  init(value: T) {
    self.value = value
  }
}
