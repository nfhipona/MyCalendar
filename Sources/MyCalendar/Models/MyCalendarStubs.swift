//
//  MyCalendarStubs.swift
//  
//
//  Created by Neil Francis Hipona on 8/5/22.
//

import SwiftUI

// MARK: - Calendar Config
public extension MyCalendarConfig {
  static let stub: MyCalendarConfig = {
    .init(titleFont: .title,
          titleFontColor: .white,
          
          navigationFont: .caption,
          navigationColor: .white,
          navigationColorDisabled: .gray,
          
          weekNamesTitleFont: .subheadline,
          weekNamesTitleColor: .white,
          
          daysNowFont: .body,
          daysNowFontColor: .white,
          daysSelectedFont: .body,
          daysSelectedFontColor: .white,
          daysFont: .body,
          daysFontColor: .white,
          daysFontDisabled: .body,
          daysFontColorDisabled: .gray,
          
          backgroundColor: .black,
          daysNowBackgroundColor: .green,
          daysSelectedBackgroundColor: .blue,
          currentWeekDaysBackgroundColor: .blue.opacity(0.8),
          activeWeekDaysBackgroundColor: .yellow,
          
          pickerConfig: .stub)
  }()
}

// MARK: - MonthYear Picker Config
public extension MyCalendarPickerConfig {
  static let stub: MyCalendarPickerConfig = {
    .init(backgroundColor: .gray,
          titleFont: .title,
          titleFontColor: .secondary,
          textFont: .body,
          textFontColor: .black)
  }()
}

// MARK: - Calendar Generator
public extension MyCalendarGenerator {
  static let stub: MyCalendarGenerator = {
    var calendar = Calendar(identifier: .gregorian)
    calendar.locale = .current
    calendar.timeZone = .current
    return .init(calendar: calendar,
                 formatter: MyCalendarFormatter.stub,
                 startOfWeek: .sunday)
  }()
}

// MARK: - Calendar Formatter
public extension MyCalendarFormatter {
  static let stub: MyCalendarFormatter = {
    .init(calendar: .init(identifier: .gregorian),
          formatterStyle: MyCalendarFormatterStyle())
  }()
}

// MARK: - Calendar View Model
public extension MyCalendarViewModel {
  static let stub: MyCalendarViewModel = {
    var calendar = Calendar(identifier: .gregorian)
    calendar.locale = .current
    calendar.timeZone = .current
    let generator: MyCalendarGenerator = .init(calendar: calendar,
                                               formatter: MyCalendarFormatter.stub,
                                               startOfWeek: .monday)
    let model = MyCalendarViewModel(config: .stub,
                                    generator: generator,
                                    pickerModel: .init(config: .stub,
                                                       generator: generator,
                                                       monthYear: .stub,
                                                       isPickerEnabled: true),
                                    initialDate: Date(),
                                    enableFutureNavigation: false,
                                    enableFutureWeeksOfCurrentMonth: false,
                                    enableFutureDateOnCurrentMonth: false)
    return model
  }()
}

// MARK: - Calendar Picker MonthYear Data
public extension MyCalendarMonthYearData {
  static let stub: MyCalendarMonthYearData = {
    let monthValue = Calendar.current
      .component(.month, from: Date())
    let monthIndex = monthValue - 1
    let monthName = Calendar.current.monthSymbols[monthIndex]
    let yearValue = Calendar.current
      .component(.year, from: Date())
    return .init(month: .init(id: monthValue, title: monthName, value: monthValue),
                 year: .init(id: yearValue, title: yearValue.description, value: yearValue))
  }()
}
