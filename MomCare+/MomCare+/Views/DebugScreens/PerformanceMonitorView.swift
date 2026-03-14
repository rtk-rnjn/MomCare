import SwiftUI
import Charts

struct PerformancePoint: Identifiable {
    let id: UUID = .init()
    let time: Date
    let value: Double
}

final class FPSMonitor: NSObject {

    // MARK: Lifecycle

    private override init() {}

    // MARK: Internal

    static let shared: FPSMonitor = .init()

    var onFPSUpdate: ((Double) -> Void)?

    func start() {
        guard displayLink == nil else { return }
        let link = CADisplayLink(target: self, selector: #selector(tick(_:)))
        link.add(to: .main, forMode: .common)
        displayLink = link
    }

    func stop() {
        displayLink?.invalidate()
        displayLink = nil
        lastTimestamp = 0
        frameCount = 0
    }

    // MARK: Private

    private var displayLink: CADisplayLink?
    private var lastTimestamp: CFTimeInterval = 0
    private var frameCount = 0

    @objc private func tick(_ link: CADisplayLink) {
        if lastTimestamp == 0 { lastTimestamp = link.timestamp }
        frameCount += 1
        let elapsed = link.timestamp - lastTimestamp
        guard elapsed >= 1.0 else { return }
        let fps = Double(frameCount) / elapsed
        frameCount = 0
        lastTimestamp = link.timestamp
        onFPSUpdate?(fps)
    }
}

struct PerformanceMonitorView: View {

    // MARK: Internal

    var body: some View {
        List {
            Section("Processor") {
                MetricCard(
                    title: "CPU Usage",
                    value: store.performanceSnapshot.cpuUsage,
                    unit: "%",
                    maxValue: 100,
                    history: store.cpuHistory,
                    warnAt: 60, dangerAt: 85,
                    baseColor: .green
                )
            }

            Section("Memory") {
                MetricCard(
                    title: "RAM Usage",
                    value: store.performanceSnapshot.ramUsageMB,
                    unit: "MB",
                    maxValue: totalRAMMB,
                    history: store.ramHistory,
                    warnAt: totalRAMMB * 0.60,
                    dangerAt: totalRAMMB * 0.85,
                    baseColor: .blue
                )
                DebugRow(label: "Physical RAM", value: Measurement(value: totalRAMMB, unit: UnitInformationStorage.megabytes)
                    .formatted(.measurement(width: .abbreviated, numberFormatStyle: .number.precision(.fractionLength(0)))))
            }

            Section("Rendering") {
                MetricCard(
                    title: "FPS",
                    value: store.performanceSnapshot.fps,
                    unit: "fps",
                    maxValue: maxFPS,
                    history: store.fpsHistory,
                    warnAt: 45, dangerAt: 30,
                    baseColor: .purple,
                    invertThreshold: true
                )
                DebugRow(label: "Display Max", value: "\(maxFPS.formatted(.number.precision(.fractionLength(0)))) fps")
            }

            Section("Storage") {
                DiskCard(usedGB: store.performanceSnapshot.diskUsageGB, totalGB: totalDiskGB)
            }

            Section("Network I/O") {
                DebugRow(label: "Sent", value: Measurement(value: store.performanceSnapshot.networkSentKB, unit: UnitInformationStorage.kilobytes)
                    .formatted(.measurement(width: .abbreviated, numberFormatStyle: .number.precision(.fractionLength(1)))))
                DebugRow(label: "Received",
                         value: Measurement(value: store.performanceSnapshot.networkReceivedKB, unit: UnitInformationStorage.kilobytes).formatted(.measurement(width: .abbreviated, usage: .asProvided, numberFormatStyle: .number.precision(.fractionLength(1)))))
            }

            Section("Tasks") {
                DebugRow(label: "Background Tasks",
                         value: "\(store.performanceSnapshot.backgroundTasks)")
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Performance")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: Private

    @EnvironmentObject private var store: DebugMenuStore

    private var totalRAMMB: Double {
        Double(ProcessInfo.processInfo.physicalMemory) / 1_048_576
    }

    private var totalDiskGB: Double {
        guard let attrs = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory()),
              let total = attrs[.systemSize] as? Int64 else { return 1 }
        return Double(total) / 1_000_000_000
    }

    private var maxFPS: Double {
        Double(UIScreen.current.maximumFramesPerSecond)
    }

}

private struct MetricCard: View {

    // MARK: Internal

    let title: String
    let value: Double
    let unit: String
    let maxValue: Double
    let history: [PerformancePoint]
    let warnAt: Double
    let dangerAt: Double
    let baseColor: Color
    var invertThreshold: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text(title)
                    .font(.subheadline.bold())
                Spacer()
                Text(value, format: .number.precision(.fractionLength(1)))
                    .font(.title2.bold().monospacedDigit())
                    .foregroundStyle(statusColor)
                    .contentTransition(.numericText())
                    .animation(reduceMotion ? nil : .spring(duration: 0.25), value: value)
                Text(unit)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.leading, 1)
            }

            Group {
                if history.isEmpty {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.secondary.opacity(0.08))
                        .overlay(
                            Text("Collecting…")
                                .font(.caption2)
                                .foregroundStyle(.quaternary)
                        )
                } else {
                    Chart(history) { pt in
                        AreaMark(
                            x: .value("t", pt.time),
                            yStart: .value("zero", 0),
                            yEnd: .value("v", pt.value)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [statusColor.opacity(0.30), statusColor.opacity(0.03)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .interpolationMethod(.catmullRom)

                        LineMark(
                            x: .value("t", pt.time),
                            y: .value("v", pt.value)
                        )
                        .foregroundStyle(statusColor)
                        .lineStyle(.init(lineWidth: 2))
                        .interpolationMethod(.catmullRom)

                        if pt.id == history.last?.id {
                            PointMark(
                                x: .value("t", pt.time),
                                y: .value("v", pt.value)
                            )
                            .symbolSize(28)
                            .foregroundStyle(statusColor)
                        }
                    }
                    .chartXAxis(.hidden)
                    .chartYAxis {
                        AxisMarks(position: .trailing, values: .automatic(desiredCount: 3)) { _ in
                            AxisGridLine(stroke: .init(lineWidth: 0.5))
                                .foregroundStyle(Color.secondary.opacity(0.2))
                            AxisValueLabel()
                                .font(.caption2)
                                .fontDesign(.monospaced)
                                .foregroundStyle(Color.secondary)
                        }
                    }
                    .chartYScale(domain: yDomain)
                    .animation(reduceMotion ? nil : .linear(duration: 0.5), value: history.count)
                }
            }
            .frame(height: 70)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.secondary.opacity(0.15))
                        .frame(height: 5)
                    Capsule()
                        .fill(statusColor)
                        .frame(width: geo.size.width * fraction, height: 5)
                        .animation(reduceMotion ? nil : .linear(duration: 0.4), value: fraction)
                }
            }
            .frame(height: 5)
        }
        .padding(.vertical, 6)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(title): \(value.formatted(.number.precision(.fractionLength(1)))) \(unit)")
        .accessibilityValue("\(Int(fraction * 100))%")
    }

    // MARK: Private

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var fraction: Double {
        maxValue > 0 ? min(value / maxValue, 1) : 0
    }

    private var statusColor: Color {
        let v = invertThreshold ? (maxValue - value) : value
        if v >= dangerAt { return .red }
        if v >= warnAt { return .orange }
        return baseColor
    }

    private var yDomain: ClosedRange<Double> { 0...(maxValue * 1.1) }

}

private struct DiskCard: View {

    // MARK: Internal

    let usedGB: Double
    let totalGB: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {

            HStack(alignment: .firstTextBaseline) {
                Text("Disk Usage")
                    .font(.subheadline.bold())
                Spacer()
                Text(usedGB, format: .number.precision(.fractionLength(1)))
                    .font(.title2.bold().monospacedDigit())
                    .foregroundStyle(statusColor)
                Text("/ \(totalGB.formatted(.number.precision(.fractionLength(0)))) GB")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Chart {
                BarMark(x: .value("used", usedGB))
                    .foregroundStyle(statusColor)
                    .cornerRadius(3)
                BarMark(x: .value("free", freeGB))
                    .foregroundStyle(Color.secondary.opacity(0.18))
                    .cornerRadius(3)
            }
            .chartXScale(domain: 0...totalGB)
            .chartXAxis(.hidden)
            .chartYAxis(.hidden)
            .chartPlotStyle { plot in
                plot.frame(height: 14)
            }
            .frame(height: 14)

            HStack {
                Label("\(usedGB.formatted(.number.precision(.fractionLength(1)))) GB used",
                      systemImage: "internaldrive.fill")
                    .foregroundStyle(statusColor)

                Spacer()

                Label("\(freeGB.formatted(.number.precision(.fractionLength(1)))) GB free",
                      systemImage: "archivebox")
                    .foregroundStyle(.secondary)
            }
            .font(.caption)
        }
        .padding(.vertical, 6)
    }

    // MARK: Private

    private var usedFraction: Double { totalGB > 0 ? min(usedGB / totalGB, 1) : 0 }
    private var freeGB: Double { max(totalGB - usedGB, 0) }
    private var statusColor: Color {
        if usedFraction >= 0.90 { return .red }
        if usedFraction >= 0.75 { return .orange }
        return .blue
    }

}
