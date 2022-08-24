//
//  MyCalendarComponents.swift
//  
//
//  Created by Neil Francis Hipona on 8/5/22.
//

import SwiftUI

public protocol RowStateProtocol {
  var stateColor: Color{ get }
}

public struct MyCalendarComponents {
  public enum Weekday: Int, CaseIterable {
    case sunday = 1
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
  }
  
  public enum RowState: RowStateProtocol {
    case `default`
    case selected
    case warning
    
    public var stateColor: Color {
      switch self {
      case .warning:
        return .orange
      case .selected:
        return .yellow
      default:
        return .clear
      }
    }
  }
  
  public struct DayModel {
    private let calendar: Calendar
    
    let id: UUID
    let date: Date
    let number: Int
    let label: String
    let isDisabled: Bool
    let isSelected: Bool
    
    var isCurrentDate: Bool {
      let isCurrent = calendar.isDateInToday(date)
      return isCurrent
    }
    
    init(id: UUID = UUID(),
         calendar: Calendar,
         date: Date,
         number: Int,
         label: String,
         isDisabled: Bool = false,
         isSelected: Bool = false) {
      
      self.id = id
      self.calendar = calendar
      self.date = date
      self.label = label
      self.number = number
      self.isDisabled = isDisabled
      self.isSelected = isSelected
    }
    
    func setSelected(isSelected: Bool) -> Self {
      .init(id: id,
            calendar: calendar,
            date: date,
            number: number,
            label: label,
            isDisabled: isDisabled,
            isSelected: isSelected)
    }
  }
  
  public struct DaysRowModel {
    private let formatter: MyCalendarFormatterProtocol
    
    let id: UUID
    let rows: [DayModel]
    let state: RowStateProtocol
    let isRowDisabled: Bool
    
    init(id: UUID = UUID(),
         formatter: MyCalendarFormatterProtocol,
         rows: [DayModel],
         state: RowStateProtocol,
         isRowDisabled: Bool = false) {
      
      self.id = id
      self.formatter = formatter
      self.rows = rows
      self.state = state
      self.isRowDisabled = isRowDisabled
    }
    
    var isRowActive: Bool {
      return !rows.filter { $0.isSelected }.isEmpty
    }
    
    var hasCurrentDate: Bool {
      return !rows.filter { $0.isCurrentDate }.isEmpty
    }
    
    var readableDateRange: String? {
      guard let firstItem = rows.first,
            let lastItem = rows.last
      else { return nil }
      let startDate = firstItem.date
      let endDate = lastItem.date
      return formatter.readableRange(from: startDate, to: endDate)
    }
    
    func updateRows(with rows: [DayModel]) -> DaysRowModel {
      return .init(id: id,
                   formatter: formatter,
                   rows: rows,
                   state: state,
                   isRowDisabled: isRowDisabled)
    }
    
    func updateRowState(with state: RowStateProtocol) -> DaysRowModel {
      return .init(id: id,
                   formatter: formatter,
                   rows: rows,
                   state: state,
                   isRowDisabled: isRowDisabled)
    }
  }
}
