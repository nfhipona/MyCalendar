//
//  MyCalendarViewModel.swift
//  
//
//  Created by Neil Francis Hipona on 8/5/22.
//

import SwiftUI
import Combine

public class MyCalendarViewModel: ObservableObject {
  public typealias Weekday = MyCalendarComponents.Weekday
  public typealias DaysRowModel = MyCalendarComponents.DaysRowModel
  public typealias DayModel = MyCalendarComponents.DayModel
  
  let config: MyCalendarConfig
  let pickerModel: MyCalendarMonthYearPickerViewModel
  let generator: MyCalendarGenerator
  
  @Published var selectedDate: Date
  @Published var dates: [DaysRowModel] = []
  @Published internal var datesTempLeft: [DaysRowModel] = []
  @Published internal var datesTempRight: [DaysRowModel] = []
  @Published var monthYear: MyCalendarMonthYearData
  let activeMonthDatePublisher = PassthroughSubject<Date, Never>()
  
  private let enableFutureNavigation: Bool
  /// `enableFutureWeeksOfCurrentMonth` will override settings for `enableFutureDateOnCurrentMonth`. Default value is `true`.
  private let enableFutureWeeksOfCurrentMonth: Bool
  private let enableFutureDateOnCurrentMonth: Bool
  private var cancellables = Set<AnyCancellable>()
  
  public init(config: MyCalendarConfig,
       generator: MyCalendarGenerator,
       pickerModel: MyCalendarMonthYearPickerViewModel,
       
       initialDate: Date = Date(),
       enableFutureNavigation: Bool = true,
       enableFutureWeeksOfCurrentMonth: Bool = true,
       enableFutureDateOnCurrentMonth: Bool = false) {
    
    self.config = config
    self.generator = generator
    self.pickerModel = pickerModel
    
    self.selectedDate = initialDate
    self.enableFutureNavigation = enableFutureNavigation
    self.enableFutureWeeksOfCurrentMonth = enableFutureWeeksOfCurrentMonth
    self.enableFutureDateOnCurrentMonth = enableFutureDateOnCurrentMonth
    
    self.monthYear = generator.monthYear(for: initialDate)
    generateDaysCollectionPage(for: initialDate)
    preparePicker()
  }
}

public extension MyCalendarViewModel {
  var canNavigateFutureMonth: Bool {
    if !enableFutureNavigation {
      let calendarMonth = generator.calendar
        .component(.month, from: Date())
      let activeMonth = monthYear.month.value
      return activeMonth < calendarMonth
    }
    return true
  }
  
  var shortWeekdayInitialSymbols: [String] {
    generator.weekdaySymbols
  }
  
  var currentMonthYear: String {
    // MMMMyyyy
    return monthYear.monthYearTitle
  }
  
  var readableActiveDateRange: String? {
    let activeRow = dates.first { $0.isRowActive }
    return activeRow?.readableDateRange
  }
  
  var activeWeekDays: [Date] {
    if let activeWeekRow = dates.first(where: { $0.isRowActive }) {
      return activeWeekRow.rows.compactMap { $0.date }
    } else if let currentWeekRow = dates.first(where: { $0.hasCurrentDate }) {
      return currentWeekRow.rows.compactMap { $0.date }
    }
    return []
  }
}

internal extension MyCalendarViewModel {
  func navigatePreviousMonth() {
    monthYear = generator.previousMonth(of: monthYear)
  }
  
  func navigateNextMonth() {
    monthYear = generator.nextMonth(of: monthYear)
  }
  
  func refreshDaysCollection() {
    generateDaysCollectionPage(for: selectedDate)
  }
  
  func selectDate(with model: DayModel) {
    var datesTmp: [DaysRowModel] = []
    for collection in dates {
      let rows = collection.rows.map { row -> DayModel in
        let isSelected = row.id == model.id
        return row.setSelected(isSelected: isSelected)
      }
      
      let updated = collection.updateRows(with: rows)
      datesTmp.append(updated)
    }
    dates = datesTmp
    selectedDate = model.date
    activeMonthDatePublisher.send(model.date)
  }
  
  func selectDate(with date: Date) {
    let month = generator.calendar
      .component(.month, from: date)
    let monthData = generator.generateMonthData(for: month)
    
    let year = generator.calendar
      .component(.year, from: date)
    let yearData = generator.generateYearData(for: year)
    
    monthYear = .init(month: monthData, year: yearData)
    selectedDate = date
    generateDaysCollectionPage(for: date)
    activeMonthDatePublisher.send(date)
  }
  
  func updatePickerMonthYear() {
    pickerModel.updateMonthYear(with: monthYear)
  }
}

private extension MyCalendarViewModel {
  func preparePicker() {
    guard pickerModel.isPickerEnabled else { return }
    pickerModel.monthYearPublisher
      .sink { [weak self] data in
        guard let self = self else { return }
        let monthData = data.month
        let yearData = data.year
        let components = DateComponents(year: yearData.value, month: monthData.value, day: 1)
        guard let date = self.generator.calendar.date(from: components) else { return }
        self.monthYear = data
        self.generateDaysCollectionPage(for: date)
      }
      .store(in: &cancellables)
  }
  
  func generateDaysCollectionPage(for selectedDate: Date) {
    // past timeline
    let previousMonthData = generator.previousMonth(of: monthYear)
    datesTempLeft = generator.generateCalendarDaysCollection(for: previousMonthData,
                                                             selectedDate: selectedDate,
                                                             enableFutureWeeksOfCurrentMonth: enableFutureWeeksOfCurrentMonth,
                                                             enableFutureDateOnCurrentMonth: enableFutureDateOnCurrentMonth)
    
    // current timeline
    dates = generator.generateCalendarDaysCollection(for: monthYear,
                                                     selectedDate: selectedDate,
                                                     enableFutureWeeksOfCurrentMonth: enableFutureWeeksOfCurrentMonth,
                                                     enableFutureDateOnCurrentMonth: enableFutureDateOnCurrentMonth)
    
    // future timeline
    let nextMonthData = generator.nextMonth(of: monthYear)
    datesTempRight = generator.generateCalendarDaysCollection(for: nextMonthData,
                                                              selectedDate: selectedDate,
                                                              enableFutureWeeksOfCurrentMonth: enableFutureWeeksOfCurrentMonth,
                                                              enableFutureDateOnCurrentMonth: enableFutureDateOnCurrentMonth)
  }
}
