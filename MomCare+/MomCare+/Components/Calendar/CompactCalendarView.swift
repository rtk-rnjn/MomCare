import SwiftUI

struct CompactCalendarView: View {
    @Binding var selectedDate: Date
    @Binding var isExpanded: Bool

    @State private var slideOffset: CGFloat = 0
    @State private var displayedDate: Date = Date()
    @State private var incomingDate: Date? = nil
    @State private var incomingDirection: CGFloat = 0
    @State private var isDraggingHorizontal: Bool? = nil

    @State private var expandProgress: CGFloat = 0 // 0 = collapsed, 1 = expanded

    private let calendar = Calendar.current

    private let alwaysSixWeeks: Bool = true
    private let showsOutOfMonthDays: Bool = false

    var body: some View {
        VStack(spacing: 0) {

            header

            GeometryReader { geo in
                let width = geo.size.width

                ZStack(alignment: .top) {
                    // Week strip — visible when collapsed
                    WeekStripView(date: displayedDate, selectedDate: $selectedDate)
                        .offset(x: slideOffset)
                        .frame(width: width)
                        .opacity(Double(1 - expandProgress))
                        .offset(y: -expandProgress * 20)

                    // Month grid — visible when expanded
                    MonthGridView(
                        date: displayedDate,
                        selectedDate: $selectedDate,
                        showsOutOfMonthDays: showsOutOfMonthDays,
                        alwaysSixWeeks: alwaysSixWeeks
                    )
                    .offset(x: slideOffset)
                    .frame(width: width)
                    .opacity(Double(expandProgress))
                    .offset(y: (1 - expandProgress) * 20)

                    // Incoming slide view (paging)
                    if let incoming = incomingDate {
                        Group {
                            if isExpanded {
                                MonthGridView(
                                    date: incoming,
                                    selectedDate: $selectedDate,
                                    showsOutOfMonthDays: showsOutOfMonthDays,
                                    alwaysSixWeeks: alwaysSixWeeks
                                )
                            } else {
                                WeekStripView(date: incoming, selectedDate: $selectedDate)
                            }
                        }
                        .offset(x: slideOffset + incomingDirection * width)
                        .frame(width: width)
                    }
                }
                .clipped()
                .contentShape(Rectangle())
                .gesture(dragGesture(width: width))
            }
            .frame(height: currentHeight)
            .padding(.horizontal, 8)
            .padding(.bottom, 12)
        }
        .background(Color(.systemBackground))
        .onAppear {
            displayedDate = selectedDate
            expandProgress = isExpanded ? 1 : 0
        }
        .onChange(of: isExpanded) { _, newValue in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                expandProgress = newValue ? 1 : 0
            }
        }
    }

    // MARK: - Header (slides with paging)

    private var header: some View {
        let titleDate = isExpanded ? displayedDate : calendar.startOfWeek(for: displayedDate)

        return HStack {
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                    expandProgress = isExpanded ? 1 : 0
                }
            } label: {
                HStack(spacing: 6) {

                    GeometryReader { g in
                        let w = g.size.width

                        ZStack {
                            Text(titleDate.formatted(.dateTime.month(.wide).year()))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .frame(width: w, alignment: .leading)
                                .offset(x: slideOffset)

                            if let incoming = incomingDate {
                                let incomingTitleDate = isExpanded ? incoming : calendar.startOfWeek(for: incoming)

                                Text(incomingTitleDate.formatted(.dateTime.month(.wide).year()))
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .frame(width: w, alignment: .leading)
                                    .offset(x: slideOffset + incomingDirection * w)
                            }
                        }
                        .clipped()
                    }
                    .frame(height: 18)

                    Image(systemName: "chevron.down")
                        .font(.caption2.weight(.semibold))
                        .foregroundColor(.secondary)
                        .rotationEffect(.degrees(expandProgress * -180))
                        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: expandProgress)
                }
            }
            .buttonStyle(.plain)

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }

    // MARK: - Drag Gesture

    private func dragGesture(width: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 10)
            .onChanged { value in
                let h = value.translation.width
                let v = value.translation.height

                if isDraggingHorizontal == nil {
                    if abs(h) > abs(v) + 5 {
                        isDraggingHorizontal = true
                    } else if abs(v) > abs(h) + 5 {
                        isDraggingHorizontal = false
                    }
                }

                if isDraggingHorizontal == true {
                    // Horizontal paging
                    let direction: CGFloat = h < 0 ? -1 : 1
                    if incomingDate == nil {
                        incomingDirection = -direction
                        incomingDate = adjacentDate(direction: -direction)
                    }
                    slideOffset = h

                } else if isDraggingHorizontal == false {
                    // Vertical expand/collapse progress
                    if !isExpanded {
                        let progress = min(max(v / expandTravelDistance, 0), 1)
                        expandProgress = progress
                    } else {
                        let progress = min(max(1 + v / expandTravelDistance, 0), 1)
                        expandProgress = progress
                    }
                }
            }
            .onEnded { value in
                let h = value.translation.width
                let velocityX = value.velocity.width
                let velocityY = value.velocity.height

                if isDraggingHorizontal == true {
                    let direction: CGFloat = h < 0 ? -1 : 1
                    let shouldCommit = abs(h) > 30 || abs(velocityX) > 300
                    if shouldCommit {
                        commitSlide(direction: direction, width: width)
                    } else {
                        cancelSlide()
                    }

                } else if isDraggingHorizontal == false {
                    let shouldExpand = !isExpanded && (expandProgress > 0.4 || velocityY > 400)
                    let shouldCollapse = isExpanded && (expandProgress < 0.6 || velocityY < -400)

                    if shouldExpand {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            isExpanded = true
                            expandProgress = 1
                        }
                    } else if shouldCollapse {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            isExpanded = false
                            expandProgress = 0
                        }
                    } else {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            expandProgress = isExpanded ? 1 : 0
                        }
                    }

                } else {
                    // snap back
                    cancelSlide()
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        expandProgress = isExpanded ? 1 : 0
                    }
                }

                isDraggingHorizontal = nil
            }
    }

    // MARK: - Heights (FSCalendar-like fixed 6 rows)

    private var compactHeight: CGFloat { 80 }

    private var expandedHeight: CGFloat {
        (6 * 44) + 40
    }

    private var expandTravelDistance: CGFloat { 120 }

    private var currentHeight: CGFloat {
        compactHeight + (expandedHeight - compactHeight) * expandProgress
    }

    // MARK: - Paging logic

    private func adjacentDate(direction: CGFloat) -> Date {
        if isExpanded {
            return calendar.date(byAdding: .month, value: direction > 0 ? 1 : -1, to: displayedDate) ?? displayedDate
        } else {
            return calendar.date(byAdding: .weekOfYear, value: direction > 0 ? 1 : -1, to: displayedDate) ?? displayedDate
        }
    }

    private func commitSlide(direction: CGFloat, width: CGFloat) {
        withAnimation(.spring(response: 0.28, dampingFraction: 0.82)) {
            slideOffset = direction * width
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.26) {
            if let incoming = incomingDate {
                displayedDate = incoming
            }
            slideOffset = 0
            incomingDate = nil
            incomingDirection = 0
        }
    }

    private func cancelSlide() {
        withAnimation(.spring(response: 0.32, dampingFraction: 0.88)) {
            slideOffset = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.32) {
            incomingDate = nil
            incomingDirection = 0
        }
    }
}
