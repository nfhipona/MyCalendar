//
//  MyCalendarView.swift
//  
//
//  Created by Neil Francis Hipona on 8/5/22.
//

import SwiftUI

public struct MyCalendarView: View {
  @ObservedObject private var model: MyCalendarViewModel
  private var geometry: GeometryProxy
  private let padding: CGFloat
  
  @State private var isMonthYearPickerActive: Bool = false
  @State private var activeDatesPage: Int = 1
  @GestureState private var isGestureFinished = true
  
  public init(model: MyCalendarViewModel, geometry: GeometryProxy, padding: CGFloat = 16) {
    self.model = model
    self.geometry = geometry
    self.padding = padding
  }
  
  public var body: some View {
    VStack(spacing: 0) {
      let contentWidth = abs(geometry.size.width - (padding * 2))
      ZStack(alignment: .center) {
        buildMonthYearButtonViewStack(contentWidth: contentWidth)
        HStack {
          Spacer()
          buildMonthNavigationButtonViewStack()
        }
      }
      .frame(minWidth: contentWidth, minHeight: 20, alignment: .center)
      
      VStack {
        drawDaysOfTheMonthTitleViewStack(contentWidth: contentWidth)
        drawDaysOfTheMonthPageViewStack(contentWidth: contentWidth)
      }
      .padding(.vertical, padding)
      .overlay(monthYearPickerViewStack())
    }
    .padding(.horizontal, padding)
    .frame(width: geometry.size.width, alignment: .center)
    .background(model.config.backgroundColor)
  }
  
  @ViewBuilder
  private func monthYearPickerViewStack() -> some View {
    if isMonthYearPickerActive {
      GeometryReader { geometry in
        MyCalendarMonthYearPickerView(model: model.pickerModel,
                                      geometry: geometry)
        .transition(.move(edge: .top))
        .onAppear {
          model.updatePickerMonthYear()
        }
      }
    }
  }
  
  @ViewBuilder
  private func buildMonthYearButtonViewStack(contentWidth: CGFloat) -> some View {
    let config = model.config
    HStack {
      if model.pickerModel.isPickerEnabled {
        Button {
          withAnimation {
            isMonthYearPickerActive = !isMonthYearPickerActive
          }
        } label: {
          HStack(spacing: 8) {
            Text(model.currentMonthYear)
              .accessibilityLabel(model.currentMonthYear)
              .font(config.titleFont)
              .foregroundColor(config.titleFontColor)
            Image(systemName: "chevron.right")
              .font(config.navigationFont)
              .foregroundColor(config.titleFontColor)
              .rotationEffect(isMonthYearPickerActive ? .degrees(90) : .degrees(0))
          }
          .frame(height: 40, alignment: .leading)
        }
      } else {
        Text(model.currentMonthYear)
          .accessibilityLabel(model.currentMonthYear)
          .font(config.titleFont)
          .foregroundColor(config.titleFontColor)
      }
    }
    .frame(width: contentWidth, alignment: model.pickerModel.isPickerEnabled ? .leading : .center)
  }
  
  private func buildMonthNavigationButtonViewStack() -> some View {
    HStack(spacing: 10) {
      let config = model.config
      let iconSize = CGSize(width: 30, height: 20)
      let chevronFont = config.navigationFont
      
      Button {
        model.navigatePreviousMonth()
        activeDatesPage = 0
      } label: {
        Image(systemName: "chevron.left")
          .font(chevronFont)
          .foregroundColor(config.navigationColor)
          .frame(width: iconSize.width, height: iconSize.height, alignment: .center)
      }
      
      Button {
        model.navigateNextMonth()
        activeDatesPage = 2
      } label: {
        let foregroundColor = model.canNavigateFutureMonth ? config.navigationColor : config.navigationColorDisabled
        Image(systemName: "chevron.right")
          .font(chevronFont)
          .foregroundColor(foregroundColor)
          .frame(width: iconSize.width, height: iconSize.height, alignment: .center)
      }
      .disabled(!model.canNavigateFutureMonth)
    }
    .frame(height: 40, alignment: .leading)
  }
  
  private func drawDaysOfTheMonthTitleViewStack(contentWidth: CGFloat) -> some View {
    HStack(spacing: 0) {
      let config = model.config
      let dayWidth = contentWidth / CGFloat(model.shortWeekdayInitialSymbols.count)
      ForEach(Array(model.shortWeekdayInitialSymbols.enumerated()), id: \.offset) { _, weekDay in
        Text(weekDay.uppercased())
          .font(config.weekNamesTitleFont)
          .foregroundColor(config.weekNamesTitleColor)
          .frame(width: dayWidth, alignment: .center)
      }
    }
    .accessibilityElement(children: .combine)
    .accessibilityHidden(true)
    .frame(width: contentWidth, height: 30, alignment: .center)
  }
  
  @ViewBuilder
  private func drawDaysOfTheMonthPageViewStack(contentWidth: CGFloat, dayHeight: CGFloat = 30) -> some View {
    let daysContainerHeight = dayHeight * 6
    ScrollViewReader { proxy in
      ScrollView(.horizontal, showsIndicators: false) {
        LazyHStack(spacing: 0) {
          let dates = [model.datesTempLeft, model.dates, model.datesTempRight]
          ForEach(0...2, id: \.self) { pageIndex in
            let dateCollection = dates[pageIndex]
            let isActivePage = pageIndex == 1
            drawDateCollectionPageViewStack(dateCollection: dateCollection,
                                            contentWidth: contentWidth,
                                            daysContainerHeight: daysContainerHeight,
                                            dayHeight: dayHeight,
                                            isActivePage: isActivePage)
          }
        }
        .background(drawContentReferenceViewStack())
      }
      .simultaneousGesture(swipeGesture, including: .all)
      .frame(width: geometry.size.width, height: daysContainerHeight, alignment: .center)
      .onAppear {
        proxy.scrollTo(activeDatesPage, anchor: .center)
      }
      .onChange(of: activeDatesPage) { newValue in
        if newValue == 1 {
          proxy.scrollTo(newValue, anchor: .center)
          model.refreshDaysCollection()
        } else {
          withAnimation {
            proxy.scrollTo(newValue, anchor: .center)
          }
        }
      }
    }
    .coordinateSpace(name: "contentOffset")
    .onPreferenceChange(ScrollViewOffsetKey.self) { value in
      let contentOffsetIndex = value / geometry.size.width
      if contentOffsetIndex == 0 || contentOffsetIndex == 2 {
        activeDatesPage = 1
      }
    }
  }
  
  private func drawContentReferenceViewStack() -> some View {
    GeometryReader { geometry in
      Color.clear
        .preference(key: ScrollViewOffsetKey.self,
                    value: abs(geometry.frame(in: .named("contentOffset")).origin.x))
    }
  }
  
  private func drawDateCollectionPageViewStack(dateCollection: [MyCalendarViewModel.DaysRowModel],
                                               contentWidth: CGFloat,
                                               daysContainerHeight: CGFloat,
                                               dayHeight: CGFloat,
                                               isActivePage: Bool) -> some View {
    LazyVStack(spacing: 0) {
      ForEach(dateCollection, id: \.id) { rowModel in
        drawDaysOfTheMonthRowViewStack(contentWidth: contentWidth,
                                       rowModel: rowModel,
                                       dayHeight: dayHeight)
      }
    }
    .accessibilityHidden(!isActivePage)
    .frame(width: geometry.size.width, height: daysContainerHeight, alignment: .top)
  }
  
  @ViewBuilder
  private func drawDaysOfTheMonthRowViewStack(contentWidth: CGFloat,
                                              rowModel: MyCalendarViewModel.DaysRowModel,
                                              dayHeight: CGFloat) -> some View {
    let config = model.config
    let dayWidth = contentWidth / CGFloat(model.shortWeekdayInitialSymbols.count)
    HStack(spacing: 0) {
      ForEach(rowModel.rows, id: \.id) { day in
        let rowStateDisabled = rowModel.isRowDisabled || day.isDisabled
        let backgroundColor = day.isCurrentDate ? config.daysNowBackgroundColor : .clear
        let activeBacgroundColor = day.isSelected ? config.daysSelectedBackgroundColor : backgroundColor
        Button {
          model.selectDate(with: day)
        } label: {
          let textFont = rowStateDisabled ? config.daysFontDisabled : config.daysFont
          let currentTextFont = day.isCurrentDate ? config.daysNowFont : textFont
          let activeTextFont = day.isSelected ? config.daysSelectedFont : currentTextFont
          
          let fontColor = rowStateDisabled ? config.daysFontColorDisabled : config.daysFontColor
          let currentFontColor = day.isCurrentDate ? config.daysNowFontColor : fontColor
          let activeFontColor = day.isSelected ? config.daysSelectedFontColor : currentFontColor
          
          Text(day.number.description)
            .font(activeTextFont)
            .foregroundColor(activeFontColor)
            .frame(width: dayWidth, height: dayHeight, alignment: .center)
        }
        .accessibilityLabel(day.label)
        .accessibilityHidden(rowStateDisabled)
        .disabled(rowStateDisabled)
        .background(activeBacgroundColor)
        .mask(drawDaysOfTheMonthDayMaskViewStack(day: day))
      }
    }
    .frame(width: contentWidth, height: dayHeight, alignment: .leading)
    .background(drawDaysOfTheMonthRowBGViewStack(rowModel: rowModel))
  }
  
  private func drawDaysOfTheMonthDayMaskViewStack(day: MyCalendarViewModel.DayModel) -> some View {
    GeometryReader { geometry in
      if day.isCurrentDate || day.isSelected {
        let originX = abs(geometry.size.width - geometry.size.height) / 2
        let squareSize = geometry.size.height
        let path = Path(roundedRect: .init(x: originX,
                                           y: 0,
                                           width: squareSize,
                                           height: squareSize),
                        cornerRadius: squareSize / 2)
        ShapeView(path: path)
      } else {
        let rect = CGRect(x: 0,
                          y: 0,
                          width: geometry.size.width,
                          height: geometry.size.height)
        ShapeView(path: .init(rect))
      }
    }
  }
  
  private func drawDaysOfTheMonthRowBGViewStack(rowModel: MyCalendarViewModel.DaysRowModel) -> some View {
    GeometryReader { geometry in
      VStack {
        let config = model.config
        let colorProfile = rowModel.hasCurrentDate ? config.currentWeekDaysBackgroundColor : rowModel.state.stateColor
        let bgColor = rowModel.isRowActive ? config.activeWeekDaysBackgroundColor : colorProfile
        RoundedRectangle(cornerRadius: geometry.size.height / 2)
          .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
          .foregroundColor(bgColor)
      }
      .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
    }
  }
}

private extension MyCalendarView {
  struct ScrollViewOffsetKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue = CGFloat.zero
    static func reduce(value: inout Value, nextValue: () -> Value) {
      value += nextValue()
    }
  }
  
  var swipeGesture: some Gesture {
    DragGesture(minimumDistance: 0, coordinateSpace: .global)
      .updating($isGestureFinished) { _, state, _ in
        state = false
      }
  }
}

private extension MyCalendarView {
  struct ShapeView: Shape {
    private let path: Path
    
    init(path: Path) {
      self.path = path
    }
    
    init(with coordinates: [CGPoint], shouldClosePath: Bool = false) {
      var borderPath = Path()
      for (idx, coordinate) in coordinates.enumerated() {
        if idx > 0 {
          borderPath.addLine(to: coordinate)
        } else {
          borderPath.move(to: coordinate)
        }
      }
      
      if shouldClosePath {
        borderPath.closeSubpath()
      }
      
      self.path = borderPath
    }
    
    func path(in rect: CGRect) -> Path {
      return path
    }
  }
}

public struct MyCalendarView_Previews: PreviewProvider {
  typealias RowState = MyCalendarComponents.RowState
  public static var model: MyCalendarViewModel = .stub
  public static var previews: some View {
    GeometryReader { geometry in
      MyCalendarView(model: model, geometry: geometry)
        .onReceive(model.selectedDayPublisher) { output in
          
        }
        .onReceive(model.selectedDatePublisher) { output in
          
        }
        .onAppear {
          model.updateRowState(with: Date(), rowState: RowState.warning)
        }
    }
  }
}
