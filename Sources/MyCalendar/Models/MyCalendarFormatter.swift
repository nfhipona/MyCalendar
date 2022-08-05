//
//  MyCalendarFormatter.swift
//  
//
//  Created by Neil Francis Hipona on 8/5/22.
//

import Foundation

public protocol MyCalendarFormatterStyleProtocol {
  var weekdayLabel: String { get }
  var dayMonthLabel: String { get }
  var fullMonthLabel: String { get }
}

public struct MyCalendarFormatterStyle: MyCalendarFormatterStyleProtocol {
  /**
   * VoiceOver: Wednesday, August 3
   */
  public let weekdayLabel = "EEEE, MMMM d"
  
  /**
   * VoiceOver: 3 Aug
   */
  public let dayMonthLabel = "d MMM"
  
  /**
   * VoiceOver: 3 Aug 2022
   */
  public let fullMonthLabel = "d MMM yyyy"
}

public protocol MyCalendarFormatterProtocol {
  func dayLabel(forDate: Date) -> String
  
  func readableRange(from date: Date,
                     to endDate: Date) -> String
}

public struct MyCalendarFormatter: MyCalendarFormatterProtocol {
  private let calendar: Calendar
  private let dateFormatter = DateFormatter()
  private let formatterStyle: MyCalendarFormatterStyleProtocol
  
  init(calendar: Calendar,
       formatterStyle: MyCalendarFormatterStyleProtocol) {
    self.calendar = calendar
    self.formatterStyle = formatterStyle
    self.dateFormatter.calendar = calendar
  }
  
  public func dayLabel(forDate date: Date) -> String {
    dateFormatter.dateFormat = formatterStyle.weekdayLabel
    return dateFormatter.string(from: date)
  }
  
  public func readableRange(from date: Date,
                            to endDate: Date) -> String {
    if calendar.component(.month, from: date) == calendar.component(.month, from: endDate) {
      dateFormatter.dateFormat = formatterStyle.dayMonthLabel
      let sDateString = dateFormatter.string(from: date)
      dateFormatter.dateFormat = formatterStyle.fullMonthLabel
      let eDateString = dateFormatter.string(from: endDate)
      return "\(sDateString) - \(eDateString)"
    } else {
      dateFormatter.dateFormat = formatterStyle.fullMonthLabel
      let sDateString = dateFormatter.string(from: date)
      let eDateString = dateFormatter.string(from: endDate)
      return "\(sDateString) - \(eDateString)"
    }
  }
}
