//
//  MyCalendarPickerData.swift
//  
//
//  Created by Neil Francis Hipona on 8/5/22.
//

import SwiftUI

public struct MyCalendarPickerData<T: Hashable>: Identifiable, Hashable {
  public let id: Int
  let title: String
  let value: T
  
  public init(id: Int, title: String, value: T) {
    self.id = id
    self.title = title
    self.value = value
  }
  
  public static func == (lhs: MyCalendarPickerData<T>,
                         rhs: MyCalendarPickerData<T>) -> Bool {
    return lhs.id == rhs.id && lhs.title == rhs.title && lhs.value == rhs.value
  }
  
  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
    hasher.combine(title)
    hasher.combine(value)
  }
}
