import SwiftUI

struct WaterLogView: View {
    // MARK: Internal

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                CompactCalendarView(selectedDate: $selectedDate, isExpanded: $controlState.showingExpandedCalendar)

                Spacer()

                VStack(spacing: 10) {
                    dropSection

                    HStack {
                        Text(
                            Measurement(
                                value: contentService.waterIntakeTodayInMilliliters,
                                unit: UnitVolume.milliliters
                            ),
                            format: .measurement(
                                width: .abbreviated,
                                usage: .asProvided,
                                numberFormatStyle: .number.precision(.fractionLength(1))
                            )
                        )
                        .contentTransition(reduceMotion ? .identity : .numericText())
                        .animation(reduceMotion ? nil : .easeInOut, value: contentService.waterIntakeTodayInMilliliters)

                        Text("of")

                        Text(
                            Measurement(
                                value: contentService.waterIntakeGoalInMilliliters,
                                unit: UnitVolume.milliliters
                            ),
                            format: .measurement(
                                width: .abbreviated,
                                usage: .asProvided,
                                numberFormatStyle: .number.precision(.fractionLength(1))
                            )
                        )
                        .contentTransition(reduceMotion ? .identity : .numericText())
                        .animation(reduceMotion ? nil : .easeInOut, value: contentService.waterIntakeGoalInMilliliters)
                    }
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color(hex: "924350").opacity(0.6))
                    .contentTransition(reduceMotion ? .identity : .numericText())
                    .padding(.top, 10)
                }

                Spacer()

                actionPanel
                    .padding(.top, 18)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
            }
            .toolbar {
                ToolbarItemGroup(placement: .cancellationAction) {
                    MCCancelButton {
                        dismiss()
                    }
                }

                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button {
                        showLogs = true
                    } label: {
                        Label("Log", systemImage: "list.bullet")
                    }
                    .accessibilityLabel(String(localized: "a11y_view_water_log_label"))

                    Menu {
                        Button {
                            showSettings = true
                        } label: {
                            Label("Settings", systemImage: "gearshape.fill")
                        }

                        Button {
                            withAnimation(reduceMotion ? nil : .easeInOut) {
                                controlState.showingExpandedCalendar.toggle()
                            }
                        } label: {
                            Label {
                                if controlState.showingExpandedCalendar {
                                    Text("Collapse Calendar")
                                } else {
                                    Text("Expand Calendar")
                                }
                            } icon: {
                                Image(systemName: "calendar")
                            }
                            .font(.body)
                            .foregroundStyle(Color.CustomColors.mutedRaspberry)
                            .symbolEffect(.bounce, value: controlState.showingExpandedCalendar)
                        }
                        .accessibilityLabel(controlState.showingExpandedCalendar ? String(localized: "a11y_collapse_calendar_label") : String(localized: "a11y_expand_calendar_label"))
                        .accessibilityIdentifier("expandCalendarButton")

                        Button {
                            selectedDate = .init()
                        } label: {
                            Label {
                                Text("Today")
                            } icon: {
                                if #available(iOS 26.0, *) {
                                    Image(systemName: "\(Calendar.current.component(.day, from: Date())).calendar")
                                } else {
                                    Image(systemName: "calendar")
                                }
                            }
                        }
                        .accessibilityLabel(String(localized: "a11y_jump_to_today_label"))
                        .accessibilityIdentifier("jumpToTodayButton")

                    } label: {
                        Label("More options", systemImage: "ellipsis")
                    }
                    .accessibilityLabel(String(localized: "a11y_more_options_label"))
                }
            }
            .navigationTitle("Water Log")
            .navigationBarTitleDisplayMode(.inline)
        }
        .task {
            contentService.fetchWaterIntake()
        }
        .sheet(isPresented: $showLogs) {
            WaterLogListView(selectedDate: $selectedDate)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showSettings) {
            settingsSheet
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
        .alert("Custom Amount", isPresented: $showCustomInput) {
            TextField("e.g. 250", text: $customAmountText).keyboardType(.numberPad)
            Button("Add") {
                if let ml = Double(customAmountText), ml > 0 {
                    Task { await addWater(ml) }
                }
                customAmountText = ""
            }
            Button("Cancel", role: .cancel) { customAmountText = "" }
        } message: {
            Text("Enter amount in millilitres")
        }
        .onChange(of: selectedDate) {
            contentService.fetchWaterIntake(for: selectedDate)
        }
        .errorAlert(error: $error)
    }

    // MARK: Private

    @EnvironmentObject private var contentService: ContentServiceHandler
    @EnvironmentObject private var controlState: ControlState

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dismiss) private var dismiss

    @State private var showLogs = false
    @State private var showSettings = false
    @State private var showCustomInput = false
    @State private var customAmountText = ""
    @State private var rippleTriggers: [UUID] = []
    @State private var splashParticles: [UUID] = []
    @State private var selectedDate: Date = .init()
    @State private var error: (any Error)?

    private let quickAmounts: [(label: String, ml: Double)] = [
        ("+150ml", 150), ("+200ml", 200), ("+300ml", 300), ("+500ml", 500)
    ]

    private var progress: Double {
        let progress = contentService.waterIntakeTodayInMilliliters / contentService.waterIntakeGoalInMilliliters
        return progress.clamped(to: 0...1)
    }

    private var dropSection: some View {
        ZStack {
            WaterDropFillView(progress: progress)

            ForEach(rippleTriggers, id: \.self) { _ in
                WaterRippleEffect()
                    .frame(width: 70, height: 70)
                    .offset(y: 30)
            }

            ForEach(splashParticles, id: \.self) { _ in
                SplashParticleView()
                    .offset(y: 30)
            }
        }
        .aspectRatio(0.78, contentMode: .fit)
        .shadow(color: Color(hex: "5B9BD5").opacity(0.18), radius: 20, x: 0, y: 10)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(String(localized: "a11y_water_intake_progress_label"))
        .accessibilityValue("\(Int(progress * 100)) percent, \(Int(contentService.waterIntakeTodayInMilliliters)) of \(Int(contentService.waterIntakeGoalInMilliliters)) millilitres")
    }

    private var actionPanel: some View {
        VStack(spacing: 12) {
            HStack(spacing: 10) {
                ForEach(quickAmounts, id: \.label) { preset in
                    Button { Task { await addWater(preset.ml) } } label: {
                        Text(preset.label)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                            .background(
                                .cyan,
                                in: RoundedRectangle(cornerRadius: 16, style: .continuous)
                            )
                            .shadow(color: Color(hex: "5B9BD5").opacity(0.28), radius: 6, x: 0, y: 3)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(String(format: String(localized: "a11y_add_water_ml_label"), Int(preset.ml)))
                }
            }
        }
    }

    private var settingsSheet: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Label("Daily Goal", systemImage: "target")
                        Spacer()
                        Text("\(Int(contentService.waterIntakeGoalInMilliliters))ml").foregroundStyle(.secondary)
                    }
                    Slider(value: $contentService.waterIntakeGoalInMilliliters, in: 1000...4000, step: 100) {
                        Text("Daily goal")
                    } minimumValueLabel: {
                        Text("1L").font(.caption)
                    } maximumValueLabel: {
                        Text("4L").font(.caption)
                    }
                } header: { Text("Hydration Goal") }
            }
            .scrollDismissesKeyboard(.immediately)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func addWater(_ ml: Double) async {
        _ = try? await contentService.logWaterIntake(milliliters: ml, at: selectedDate)
        guard !reduceMotion else {
            return
        }

        let rid = UUID()
        withAnimation { rippleTriggers.append(rid) }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) { rippleTriggers.removeAll { $0 == rid } }

        let pid = UUID()
        withAnimation { splashParticles.append(pid) }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) { splashParticles.removeAll { $0 == pid } }
    }
}
