//
//  MyCalendarGenerator.swift
//  
//
//  Created by Neil Francis Hipona on 8/5/22.
//

import SwiftUI

public struct MyCalendarGenerator {
  public typealias Weekday = MyCalendarComponents.Weekday
  public typealias DayModel = MyCalendarComponents.DayModel
  public typealias DaysRowModel = MyCalendarComponents.DaysRowModel
  
  let calendar: Calendar
  let formatter: MyCalendarFormatterProtocol
  let startOfWeek: Weekday
  let minYear: Int
  let maxYear: Int
  
  init(calendar: Calendar,
       formatter: MyCalendarFormatterProtocol,
       startOfWeek: Weekday = .sunday,
       minYear: Int = 5,
       maxYear: Int = 10) {
    
    self.calendar = calendar
    self.formatter = formatter
    self.startOfWeek = startOfWeek
    self.minYear = minYear
    self.maxYear = maxYear
  }
  
  var weekdayName: String {
    let symbolIndex = startOfWeek.rawValue - 1
    return calendar.standaloneWeekdaySymbols[symbolIndex]
  }
  
  var weekdaySymbols: [String] {
    let symbols = calendar.veryShortWeekdaySymbols
    let symbolIndex = startOfWeek.rawValue - 1
    return Array(symbols[symbolIndex..<symbols.count] + symbols[0..<symbolIndex])
  }
  
  var weekdayNameSymbols: [String] {
    let symbols = calendar.standaloneWeekdaySymbols
    let symbolIndex = startOfWeek.rawValue - 1
    return Array(symbols[symbolIndex..<symbols.count] + symbols[0..<symbolIndex])
  }
}

// MARK: - Calendar Data Generator
public extension MyCalendarGenerator {
  /**
   * Get days range for the month
   * Ex. Day 1 - 31 or Day 1 - 28
   */
  func generateCalendarDaysRange(forMonth month: Int,
                                 inYear year: Int) -> ClosedRange<Int> {
    var start = DateComponents(calendar: calendar)
    start.day = 1
    start.month = month
    start.year = year
    
    var end = DateComponents(calendar: calendar)
    end.day = 1
    end.month = month + 1
    end.year = year
    
    let dayCount = calendar
      .dateComponents([.day],
                      from: start,
                      to: end)
      .day ?? 0
    
    return 1...dayCount
  }
  
  /**
   * Generates calendar days for the month
   */
  func generateCalendarDays(forMonth month: Int,
                            inYear year: Int,
                            selectedDate: Date) -> [DayModel] {
    let range = generateCalendarDaysRange(forMonth: month, inYear: year)
    
    var days: [DayModel] = []
    var dayComponents = DateComponents(calendar: calendar)
    dayComponents.month = month
    dayComponents.year = year
    
    for day in range {
      dayComponents.day = day
      if let date = calendar.date(from: dayComponents) {
        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
        let dayLabel = formatter.dayLabel(forDate: date)
        let model = DayModel(calendar: calendar,
                             date: date,
                             number: day,
                             label: dayLabel,
                             isSelected: isSelected)
        days.append(model)
      }
    }
    
    return days
  }
  
  /**
   * Generates calendar offset days of the month
   */
  func generateOffsetDates(forMonth month: Int,
                           inYear year: Int,
                           selectedDate: Date,
                           option: OffsetDateOrder) -> [DayModel] {
    var generated: [DayModel] = []
    var start = DateComponents()
    start.day = 1
    start.month = month
    
    var end = DateComponents()
    end.day = 1
    end.month = month + 1
    
    let daysOfMonth = Calendar.current
      .dateComponents([.day],
                      from: start,
                      to: end)
      .day ?? 0
    
    var dayComponents = DateComponents(calendar: calendar)
    dayComponents.month = month
    dayComponents.year = year
    
    switch option {
    case .previous(let limit, let isDisabled):
      for day in (1...daysOfMonth).reversed() where generated.count < limit {
        dayComponents.day = day
        
        if let date = calendar.date(from: dayComponents) {
          let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
          let dayLabel = formatter.dayLabel(forDate: date)
          let model = DayModel(calendar: calendar,
                               date: date,
                               number: day,
                               label: dayLabel,
                               isDisabled: isDisabled,
                               isSelected: isSelected)
          generated.insert(model, at: 0)
        }
      }
    case .next(let start, let limit, let isDisabled):
      for day in start..<daysOfMonth where generated.count < limit {
        dayComponents.day = day
        
        if let date = calendar.date(from: dayComponents) {
          let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
          let dayLabel = formatter.dayLabel(forDate: date)
          let model = DayModel(calendar: calendar,
                               date: date,
                               number: day,
                               label: dayLabel,
                               isDisabled: isDisabled,
                               isSelected: isSelected)
          generated.append(model)
        }
      }
    }
    
    return generated
  }
  
  /**
   * Generates calendar offset days of the month
   */
  func generatePreviousMonthFillerDays(forMonth month: Int,
                                       inYear year: Int,
                                       selectedDate: Date,
                                       enableFillerDatesOnCurrentMonth: Bool = false) -> [DayModel] {
    var dComponents = DateComponents(calendar: calendar)
    dComponents.day = 1
    dComponents.month = month
    dComponents.year = year
    
    guard let startDate = calendar.date(from: dComponents) else { return [] }
    let dayStartInWeek = calendar.component(.weekday, from: startDate)
    let startInWeek = dayStartInWeek - startOfWeek.rawValue
    let offsetLimit = startInWeek < 0 ? 7 - abs(startInWeek) : startInWeek
    
    // fill previous month's days
    guard offsetLimit > 0 else { return [] }
    let previousMonth = month - 1
    let generated = generateOffsetDates(forMonth: previousMonth,
                                        inYear: year,
                                        selectedDate: selectedDate,
                                        option: .previous(offsetLimit,
                                                          isDisabled: !enableFillerDatesOnCurrentMonth))
    return generated
  }
  
  /**
   * Generates calendar days collection with offset days
   */
  func generateCalendarDaysCollection(for monthYear: MyCalendarMonthYearData,
                                      selectedDate: Date = Date(),
                                      enableFutureWeeksOfCurrentMonth: Bool = true,
                                      enableFutureDateOnCurrentMonth: Bool) -> [DaysRowModel] {
    let month = monthYear.month.value
    let year = monthYear.year.value
    
    // filler previous month days
    let fillerDays = generatePreviousMonthFillerDays(forMonth: month,
                                                     inYear: year,
                                                     selectedDate: selectedDate)
    var days = generateCalendarDays(forMonth: month,
                                    inYear: year,
                                    selectedDate: selectedDate)
    days.insert(contentsOf: fillerDays, at: 0)
    
    var daysCollection: [DaysRowModel] = []
    var collectionIndex: Int = 0
    var fillStart: Int = 1
    
    for _ in 1...6 { // rows
      var daysRow: [DayModel] = [] // week's days
      for _ in 1...7 where collectionIndex < days.count { // items/days per row
        daysRow.append(days[collectionIndex])
        collectionIndex += 1
      }
      
      if daysRow.count < 7 { // fill in next month's days
        let fillCount = 7 - daysRow.count
        let nextMonth = month + 1
        let generated = generateOffsetDates(forMonth: nextMonth,
                                            inYear: year,
                                            selectedDate: selectedDate,
                                            option: .next(fillStart,
                                                          limit: fillCount,
                                                          isDisabled: !enableFutureDateOnCurrentMonth))
        daysRow.append(contentsOf: generated)
        fillStart += fillCount
      }
      
      var isRowDisabled = false
      // check if future weeks are disabled
      if !enableFutureWeeksOfCurrentMonth, let firstDateModelInWeek = daysRow.first {
        // get first date in week's date row and check if date is future date
        isRowDisabled = firstDateModelInWeek.date > Date()
      }
      
      daysCollection.append(DaysRowModel(formatter: formatter,
                                         rows: daysRow,
                                         state: .default,
                                         isRowDisabled: isRowDisabled))
    }
    
    return daysCollection
  }
}

// MARK: - Picker Data Generator
public extension MyCalendarGenerator {
  func generateMonthData(for monthValue: Int) -> MyCalendarPickerData<Int> {
    let monthIndex = monthValue - 1
    let monthName = Calendar.current.monthSymbols[monthIndex]
    return .init(id: monthValue, title: monthName, value: monthValue)
  }
  
  func generateYearData(for yearValue: Int) -> MyCalendarPickerData<Int> {
    return .init(id: yearValue, title: yearValue.description, value: yearValue)
  }
  
  func previousMonth(of current: MyCalendarMonthYearData) -> MyCalendarMonthYearData {
    let previousMonth = current.month.value - 1
    let isPreviousYear = previousMonth < 1
    let monthValue = isPreviousYear ? 12 : previousMonth
    let monthData = generateMonthData(for: monthValue)
    
    if isPreviousYear {
      let yearValue = current.year.value - 1
      let yearData = generateYearData(for: yearValue)
      return .init(month: monthData, year: yearData)
    } else {
      return .init(month: monthData, year: current.year)
    }
  }
  
  func nextMonth(of current: MyCalendarMonthYearData) -> MyCalendarMonthYearData {
    let nextMonth = current.month.value + 1
    let isNextYear = nextMonth > 12
    let monthValue = isNextYear ? 1 : nextMonth
    let monthData = generateMonthData(for: monthValue)
    
    if isNextYear {
      let yearValue = current.year.value + 1
      let yearData = generateYearData(for: yearValue)
      return .init(month: monthData, year: yearData)
    } else {
      return .init(month: monthData, year: current.year)
    }
  }
  
  func monthYear(for date: Date) -> MyCalendarMonthYearData {
    let month = calendar.component(.month, from: date)
    let monthIndex = month - 1
    let monthName = Calendar.current.monthSymbols[monthIndex]
    let monthData: MyCalendarPickerData<Int> = .init(id: month, title: monthName, value: month)
    
    let year = calendar.component(.year, from: date)
    let yearData: MyCalendarPickerData<Int> = .init(id: year, title: year.description, value: year)
    
    return .init(month: monthData, year: yearData)
  }
  
  func generateMonths() -> [MyCalendarPickerData<Int>] {
    var data: [MyCalendarPickerData<Int>] = []
    for (idx, month) in calendar.monthSymbols.enumerated() {
      let monthValue = idx + 1
      data.append(MyCalendarPickerData(id: monthValue, title: month, value: monthValue))
    }
    return data
  }
  
  func generateYears() -> [MyCalendarPickerData<Int>] {
    guard let currentYear = calendar
      .dateComponents([.year], from: Date())
      .year
    else { return [] }
    
    var data: [MyCalendarPickerData<Int>] = []
    let minYearLimit = currentYear - minYear
    for year in minYearLimit..<currentYear {
      data.append(MyCalendarPickerData(id: year, title: year.description, value: year))
    }
    
    let maxYearLimit = currentYear + maxYear
    for year in currentYear...maxYearLimit {
      data.append(MyCalendarPickerData(id: year, title: year.description, value: year))
    }
    
    return data
  }
}

public extension MyCalendarGenerator {
  enum OffsetDateOrder {
    case previous(_ limit: Int, isDisabled: Bool = true)
    case next(_ start: Int = 1, limit: Int, isDisabled: Bool = true)
  }
}
