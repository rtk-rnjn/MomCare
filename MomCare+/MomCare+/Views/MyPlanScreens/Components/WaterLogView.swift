import SwiftUI

struct WaterLogView: View {

    @StateObject private var store = WaterStore()
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dismiss) private var dismiss

    @State private var showLogs          = false
    @State private var showSettings      = false
    @State private var showCustomInput   = false
    @State private var customAmountText  = ""
    @State private var rippleTriggers:  [UUID] = []
    @State private var splashParticles: [UUID] = []
    @State private var lastAdded: Double?        = nil
    @State private var feedbackOffset: CGFloat   = 0
    @State private var feedbackOpacity: Double   = 0
    @State private var selectedDate              = Date()
    @State private var quoteIndex: Int           = 0

    private var motivationalText: String {
        if store.progress >= 1.0    { return "Amazing! You've hit your goal today. 🌸" }
        if store.progress >= 0.75   { return "Almost there — just a little more!" }
        if store.progress >= 0.5    { return "Great progress, keep it up! 💧" }
        if store.progress >= 0.25   { return "Good start — stay consistent!" }
        return "Start hydrating for a healthy day. 🌷"
    }

    private let quickAmounts: [(label: String, ml: Double)] = [
        ("+150ml", 150), ("+200ml", 200), ("+300ml", 300), ("+500ml", 500)
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                background
                
                VStack(spacing: 0) {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {
                            Text(motivationalText)
                                .font(.subheadline)
                                .foregroundStyle(Color(hex: "924350").opacity(0.7))
                                .multilineTextAlignment(.center)
                                .padding(.top, 6)
                                .padding(.horizontal, 32)
                                .animation(.easeInOut(duration: 0.4), value: motivationalText)
                            
                            dropSection
                                .padding(.top, 10)
                                .padding(.horizontal, 52)
                            
                            Text("\(Int(store.todayTotal))ml of \(Int(store.dailyTarget))ml")
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(Color(hex: "924350").opacity(0.6))
                                .contentTransition(.numericText())
                                .animation(.spring(response: 0.5), value: store.todayTotal)
                                .padding(.top, 10)
                            
                            actionPanel
                                .padding(.top, 18)
                                .padding(.horizontal, 16)
                                .padding(.bottom, 36)
                        }
                    }
                }
                
                // Floating feedback label
                if let amt = lastAdded {
                    Text("+\(Int(amt))ml")
                        .font(.title2.weight(.bold))
                        .foregroundColor(Color(hex: "924350"))
                        .shadow(color: Color(hex: "FAE8E4"), radius: 3)
                        .offset(y: feedbackOffset)
                        .opacity(feedbackOpacity)
                        .allowsHitTesting(false)
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel) {
                        dismiss()
                    }
                }
                
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button {
                        showLogs = true
                    } label: {
                        Label("", systemImage: "list.bullet")
                    }
                    
                    Menu {
                        Button {
                            showSettings = true
                        } label: {
                            Label("Settings", systemImage: "gearshape.fill")
                        }
                        
                        Toggle(isOn: Binding(
                            get: { store.notificationsEnabled },
                            set: { v in Task { await store.toggleReminders(v) } }
                        )) {
                            if store.notificationsEnabled {
                                Label("Reminder", systemImage: "bell.fill")
                            } else {
                                Label("Reminder", systemImage: "bell.slash.fill")
                            }
                        }

                    } label: {
                        Label("", systemImage: "ellipsis")
                    }
                }
            }
            .navigationTitle("Water Log")
            .navigationBarTitleDisplayMode(.inline)
        }
        .task {
            await store.setup()
            quoteIndex = Int.random(in: 0..<WaterStore.waterQuotes.count)
        }
        .sheet(isPresented: $showLogs) {
            WaterLogListView(store: store)
                .presentationDetents([.large])
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
                if let ml = Double(customAmountText), ml > 0 { Task { await addWater(ml) } }
                customAmountText = ""
            }
            Button("Cancel", role: .cancel) { customAmountText = "" }
        } message: {
            Text("Enter amount in millilitres")
        }
        .onChange(of: selectedDate) {
            Task { await store.fetchWater(for: selectedDate) }
        }

    }

    private var background: some View {
        ZStack {
            Color(hex: "F5F8FD")
                .ignoresSafeArea()

            LinearGradient(
                colors: [Color(hex: "FAE8E4").opacity(0.5), Color(hex: "EAF5FB").opacity(0.6)],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()
        }
    }

    private var dropSection: some View {
        ZStack {
            WaterDropFillView(progress: store.progress)

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
    }

    private var actionPanel: some View {
        VStack(spacing: 12) {
            HStack(spacing: 10) {
                ForEach(quickAmounts, id: \.label) { preset in
                    Button { Task { await addWater(preset.ml) } } label: {
                        Text(preset.label)
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                            .background(
                                LinearGradient(
                                    colors: [Color(hex: "7BB8E8"), Color(hex: "5B9BD5")],
                                    startPoint: .topLeading, endPoint: .bottomTrailing
                                ),
                                in: RoundedRectangle(cornerRadius: 16, style: .continuous)
                            )
                            .shadow(color: Color(hex: "5B9BD5").opacity(0.28), radius: 6, x: 0, y: 3)
                    }
                    .buttonStyle(.plain)
                }
            }
            quoteCard
        }
    }

    // MARK: Quote card

    private var quoteCard: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "quote.bubble.fill")
                .foregroundColor(Color(hex: "924350").opacity(0.65))
                .font(.headline)

            Text(WaterStore.waterQuotes[quoteIndex])
                .font(.footnote.italic())
                .foregroundStyle(Color(hex: "924350").opacity(0.8))
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(3)
        }
        .padding(14)
        .background(Color(hex: "FAE8E4").opacity(0.55),
                    in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color(hex: "924350").opacity(0.1), lineWidth: 1)
        )
    }

    private var settingsSheet: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Label("Daily Goal", systemImage: "target")
                        Spacer()
                        Text("\(Int(store.dailyTarget))ml").foregroundStyle(.secondary)
                    }
                    Slider(value: $store.dailyTarget, in: 1000...4000, step: 100) {
                        Text("Daily goal")
                    } minimumValueLabel: {
                        Text("1L").font(.caption)
                    } maximumValueLabel: {
                        Text("4L").font(.caption)
                    }
                } header: { Text("Hydration Goal") }

                Section {
                    Toggle(isOn: Binding(
                        get: { store.notificationsEnabled },
                        set: { v in Task { await store.toggleReminders(v) } }
                    )) {
                        Label("Drink Reminders", systemImage: "bell.badge")
                    }

                    if store.notificationsEnabled {
                        Picker("Remind every", selection: $store.reminderIntervalHours) {
                            Text("1 hour").tag(1)
                            Text("2 hours").tag(2)
                            Text("3 hours").tag(3)
                        }
                        .onChange(of: store.reminderIntervalHours) {
                            Task { await store.scheduleReminders() }
                        }
                    }
                } header: { Text("Notifications") }
                footer: {
                    if store.notificationsEnabled {
                        Text("Reminders are scheduled from 7 AM to 10 PM daily.")
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: Add water + feedback

    private func addWater(_ ml: Double) async {
        await store.log(milliliters: ml)
        guard !reduceMotion else { return }

        let rid = UUID()
        withAnimation { rippleTriggers.append(rid) }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) { rippleTriggers.removeAll { $0 == rid } }

        let pid = UUID()
        withAnimation { splashParticles.append(pid) }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) { splashParticles.removeAll { $0 == pid } }

        lastAdded = ml; feedbackOffset = 0; feedbackOpacity = 1.0
        withAnimation(.easeOut(duration: 0.85)) { feedbackOffset = -80; feedbackOpacity = 0 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) { lastAdded = nil }
    }

    private func weekDays(around date: Date) -> [Date] {
        let cal = Calendar.current
        let weekday = cal.component(.weekday, from: date)
        let startOfWeek = cal.date(byAdding: .day, value: -(weekday - 1), to: date)!
        return (0..<7).compactMap { cal.date(byAdding: .day, value: $0, to: startOfWeek) }
    }

    private func dayNumber(_ date: Date) -> String {
        let fmt = DateFormatter(); fmt.dateFormat = "d"
        return fmt.string(from: date)
    }

    private func dayName(_ date: Date) -> String {
        let fmt = DateFormatter(); fmt.dateFormat = "EEE"
        return fmt.string(from: date).uppercased()
    }

    private func monthYearString(for date: Date) -> String {
        let fmt = DateFormatter(); fmt.dateFormat = "MMMM yyyy"
        return fmt.string(from: date)
    }
}
