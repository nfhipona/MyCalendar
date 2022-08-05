//
//  MyCalendarConfig.swift
//  
//
//  Created by Neil Francis Hipona on 8/5/22.
//

import Foundation

// MARK: - Calendar Config
public struct MyCalendarConfig {
  // title
  let titleFont: Font
  let titleFontColor: Color
  
  let navigationFont: Font
  let navigationColor: Color
  let navigationColorDisabled: Color
  
  let weekNamesTitleFont: Font
  let weekNamesTitleColor: Color
  
  // calendar days
  let daysNowFont: Font
  let daysNowFontColor: Color
  
  let daysSelectedFont: Font
  let daysSelectedFontColor: Color
  
  let daysFont: Font
  let daysFontColor: Color
  
  let daysFontDisabled: Font
  let daysFontColorDisabled: Color
  
  // calendar ui
  let backgroundColor: Color
  let daysNowBackgroundColor: Color
  let daysSelectedBackgroundColor: Color
  let currentWeekDaysBackgroundColor: Color
  let activeWeekDaysBackgroundColor: Color
  
  // picker
  let pickerConfig: MyCalendarPickerConfig
}

// MARK: - MonthYear Picker Config
public struct MyCalendarPickerConfig {
  // picker
  let backgroundColor: Color
  let titleFont: Font
  let titleFontColor: Color
  let textFont: Font
  let textFontColor: Color
}
