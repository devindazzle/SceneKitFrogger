//
//  Array2D.swift
//  RWDevConSceneKitFinal
//
//  Created by Kim Pedersen on 24/11/14.
//  Copyright (c) 2014 RWDevCon. All rights reserved.
//

class Array2D {
  
  var cols: Int, rows: Int
  var data: [Int]
  
  init(cols columnCount: Int, rows rowCount: Int, value defaultValue: Int) {
    self.cols = columnCount
    self.rows = rowCount
    data = Array(count: cols * rows, repeatedValue: defaultValue)
  }
  
  subscript(column: Int, row: Int) -> Int {
    get {
      return data[cols * row + column]
    }
    set {
      data[cols * row + column] = newValue
    }
  }
  
  func columnCount() -> Int {
    return self.cols
  }
  
  func rowCount() -> Int {
    return self.rows
  }
  
}