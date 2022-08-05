//
//  MyCalendarMonthYearPickerViewModel.swift
//  
//
//  Created by Neil Francis Hipona on 8/5/22.
//

import Combine
import SwiftUI

public class MyCalendarMonthYearPickerViewModel: ObservableObject {
  let config: MyCalendarPickerConfig
  let generator: MyCalendarGenerator
  
  @Published public var monthYear: MyCalendarMonthYearData
  let monthsData: [MyCalendarPickerData<Int>]
  let yearsData: [MyCalendarPickerData<Int>]
  let isPickerEnabled: Bool
  
  public let monthYearPublisher = PassthroughSubject<MyCalendarMonthYearData, Never>()
  
  public init(config: MyCalendarPickerConfig,
              generator: MyCalendarGenerator,
              monthYear: MyCalendarMonthYearData,
              isPickerEnabled: Bool = true) {
    
    self.config = config
    self.generator = generator
    self.monthYear = monthYear
    self.isPickerEnabled = isPickerEnabled
    
    self.monthsData = generator.generateMonths()
    self.yearsData = generator.generateYears()
  }
}

internal extension MyCalendarMonthYearPickerViewModel {
  func updateSelectedMonth(month: MyCalendarPickerData<Int>) {
    monthYear = .init(month: month, year: monthYear.year)
    monthYearPublisher.send(monthYear)
  }
  
  func updateSelectedYear(year: MyCalendarPickerData<Int>) {
    monthYear = .init(month: monthYear.month, year: year)
    monthYearPublisher.send(monthYear)
  }
  
  func updateMonthYear(with current: MyCalendarMonthYearData) {
    monthYear = current
  }
}
