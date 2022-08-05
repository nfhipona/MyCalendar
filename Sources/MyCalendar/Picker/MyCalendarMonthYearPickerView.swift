//
//  MyCalendarMonthYearPickerView.swift
//  
//
//  Created by Neil Francis Hipona on 8/5/22.
//

import SwiftUI

public struct MyCalendarMonthYearPickerView: View {
  @ObservedObject private var model: MyCalendarMonthYearPickerViewModel
  private let geometry: GeometryProxy
  private let padding: CGFloat
  
  @State private var monthSelection: Int = 0
  @State private var yearSelection: Int = 0
  
  public init(model: MyCalendarMonthYearPickerViewModel,
              geometry: GeometryProxy,
              padding: CGFloat = 24) {
    
    self.model = model
    self.geometry = geometry
    self.padding = padding
  }
  
  public var body: some View {
    HStack(spacing: 8) {
      let contentWidth = abs(geometry.size.width - (padding * 2)) / 2
      let textFont = model.config.textFont
      let textFontColor = model.config.textFontColor
      
      Picker("Month", selection: $monthSelection) {
        ForEach(model.monthsData, id: \.id) { data in
          Text(data.title)
            .accessibilityLabel(data.title)
            .font(textFont)
            .foregroundColor(textFontColor)
            .frame(width: contentWidth, alignment: .center)
        }
      }
      .frame(width: contentWidth, alignment: .center)
      .pickerStyle(.wheel)
      .clipped()
      .compositingGroup()
      .onChange(of: monthSelection) { newValue in
        let filteredData = model.monthsData.filter { $0.id == newValue }
        if let selectedData = filteredData.first {
          model.updateSelectedMonth(month: selectedData)
        }
      }
      
      Spacer(minLength: 0)
      
      Picker("Year", selection: $yearSelection) {
        ForEach(model.yearsData, id: \.id) { data in
          Text(data.title)
            .accessibilityLabel(data.title)
            .font(textFont)
            .foregroundColor(textFontColor)
            .frame(width: contentWidth, alignment: .center)
        }
      }
      .frame(width: contentWidth, alignment: .center)
      .pickerStyle(.wheel)
      .clipped()
      .compositingGroup()
      .onChange(of: yearSelection) { newValue in
        let filteredData = model.yearsData.filter { $0.id == newValue }
        if let selectedData = filteredData.first {
          model.updateSelectedYear(year: selectedData)
        }
      }
    }
    .padding(.horizontal, padding)
    .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
    .background(model.config.backgroundColor)
    .onAppear {
      monthSelection = model.monthYear.month.id
      yearSelection = model.monthYear.year.id
    }
  }
}

public struct MyCalendarMonthYearPickerView_Previews: PreviewProvider {
  public static var previews: some View {
    GeometryReader { geometry in
      MyCalendarMonthYearPickerView(model: .init(config: .stub,
                                                 generator: .stub,
                                                 monthYear: .stub),
                                    geometry: geometry)
    }
  }
}
