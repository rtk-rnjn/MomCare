import SwiftUI
import Foundation


struct NetworkInspectorView: View {

    // MARK: Internal

    var body: some View {
        List {
            if filtered.isEmpty {
                emptyState
            } else {
                ForEach(filtered) { request in
                    Button { selectedRequest = request } label: {
                        NetworkRequestRow(request: request)
                    }
                    .buttonStyle(.plain)
                    .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                }
            }
        }
        .listStyle(.insetGrouped)
        .searchable(text: $searchText, prompt: "Filter by URL or method")
        .navigationTitle("Network Inspector")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(role: .destructive) {
                    store.clearNetworkRequests()
                } label: {
                    Label("Clear", systemImage: "trash")
                }
                .disabled(store.networkRequests.isEmpty)
            }
        }
        .sheet(item: $selectedRequest) { req in
            NetworkRequestDetailView(request: req)
        }
    }

    // MARK: Private

    @EnvironmentObject private var store: DebugMenuStore
    @State private var selectedRequest: DebugNetworkRequest?
    @State private var searchText = ""

    private var filtered: [DebugNetworkRequest] {
        guard !searchText.isEmpty else { return Array(store.networkRequests) }
        return store.networkRequests.filter {
            $0.url.localizedCaseInsensitiveContains(searchText) ||
            $0.method.localizedCaseInsensitiveContains(searchText)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "network.slash")
                .font(.system(size: 44, weight: .thin))
                .foregroundStyle(.quaternary)
                .padding(.top, 32)
            Text("No Requests")
                .font(.headline)
                .foregroundStyle(.primary)
            Text("Network requests will appear here once captured.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .padding(.bottom, 32)
        }
        .frame(maxWidth: .infinity)
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }
}

// MARK: - Request Row

struct NetworkRequestRow: View {
    let request: DebugNetworkRequest

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            MethodBadge(method: request.method)
                .frame(width: 52, alignment: .leading)

            VStack(alignment: .leading, spacing: 3) {
                Text(request.url)
                    .font(.system(size: 13, weight: .regular, design: .default))
                    .lineLimit(1)
                    .truncationMode(.middle)
                    .foregroundStyle(.primary)

                HStack(spacing: 6) {
                    if let code = request.statusCode {
                        StatusCodeBadge(code: code)
                    }
                    if let err = request.error {
                        Label(err, systemImage: "exclamationmark.triangle.fill")
                            .font(.caption2)
                            .foregroundStyle(.red)
                            .lineLimit(1)
                    }
                }
            }

            Spacer(minLength: 0)

            VStack(alignment: .trailing, spacing: 3) {
                Text(formattedDuration)
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
                Text(request.timestamp.formatted(.dateTime.hour().minute().second()))
                    .font(.caption2.monospacedDigit())
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 4)
    }

    private var formattedDuration: String {
        let duration = Measurement(value: request.responseTime, unit: UnitDuration.seconds)

        if duration.converted(to: .milliseconds).value < 1000 {
            let ms = duration.converted(to: .milliseconds)
            return "\(Int(ms.value)) ms"
        } else {
            let formatter = MeasurementFormatter()
            formatter.unitOptions = .providedUnit
            formatter.numberFormatter.maximumFractionDigits = 2
            return formatter.string(from: duration)
        }
    }
}

// MARK: - Detail View

struct NetworkRequestDetailView: View {

    let request: DebugNetworkRequest

    @State private var showingRequestBody = false
    @State private var showingResponseBody = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                // Overview Section
                Section {
                    HStack(spacing: 16) {
                        MethodBadge(method: request.method, large: true)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(request.url)
                                .font(.system(size: 13, weight: .medium, design: .monospaced))
                                .lineLimit(3)
                                .textSelection(.enabled)
                            Text(request.timestamp.formatted(date: .abbreviated, time: .standard))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                } header: {
                    InspectorSectionHeader("Request", icon: "arrow.up.circle.fill")
                }

                // Response Section
                Section {
                    if let code = request.statusCode {
                        LabeledContent("Status") {
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(request.statusColor)
                                    .frame(width: 8, height: 8)
                                Text(statusDescription(for: code))
                                    .font(.subheadline.weight(.medium))
                                    .foregroundStyle(request.statusColor)
                                Text("(\(code))")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    LabeledContent("Duration") {
                        Text(formattedDuration)
                            .font(.system(.subheadline, design: .monospaced))
                            .foregroundStyle(.primary)
                    }
                } header: {
                    InspectorSectionHeader("Response", icon: "arrow.down.circle.fill")
                }

                // Request Body
                if let body = request.requestBody {
                    Section {
                        BodyPreviewButton(text: body, label: "Inspect Request Body") {
                            showingRequestBody = true
                        }
                    } header: {
                        InspectorSectionHeader("Request Body", icon: "doc.text")
                    }
                }

                // Response Body
                if let body = request.responseBody {
                    Section {
                        BodyPreviewButton(text: body, label: "Inspect Response Body") {
                            showingResponseBody = true
                        }
                    } header: {
                        InspectorSectionHeader("Response Body", icon: "doc.text.fill")
                    }
                }

                // Error
                if let err = request.error {
                    Section {
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.red)
                                .font(.callout)
                                .padding(.top, 1)
                            Text(err)
                                .font(.callout)
                                .foregroundStyle(.red)
                                .textSelection(.enabled)
                        }
                        .padding(.vertical, 2)
                    } header: {
                        InspectorSectionHeader("Error", icon: "xmark.octagon.fill")
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Request Detail")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .close) { dismiss() }
                        .fontWeight(.semibold)
                }
            }
        }
        .sheet(isPresented: $showingRequestBody) {
            if let body = request.requestBody {
                JSONSheetView(title: "Request Body", raw: body)
            }
        }
        .sheet(isPresented: $showingResponseBody) {
            if let body = request.responseBody {
                JSONSheetView(title: "Response Body", raw: body)
            }
        }
    }

    private var formattedDuration: String {
        let duration = Measurement(value: request.responseTime, unit: UnitDuration.seconds)
        let ms = duration.converted(to: .milliseconds).value

        if ms < 1000 {
            return Measurement(value: ms, unit: UnitDuration.milliseconds)
                .formatted(.measurement(width: .abbreviated, numberFormatStyle: .number.precision(.fractionLength(1))))
        } else {
            return duration
                .formatted(.measurement(width: .abbreviated, numberFormatStyle: .number.precision(.fractionLength(3))))
        }
    }

    private func statusDescription(for code: Int) -> String {
        return HTTPURLResponse.localizedString(forStatusCode: code).capitalized
    }
}

// MARK: - Reusable Sub-components

struct MethodBadge: View {
    let method: String
    var large: Bool = false

    var body: some View {
        Text(method.uppercased())
            .font(large
                  ? .system(size: 13, weight: .bold, design: .rounded)
                  : .system(size: 10, weight: .bold, design: .rounded))
            .foregroundStyle(color)
            .padding(.horizontal, large ? 8 : 5)
            .padding(.vertical, large ? 4 : 2)
            .background(color.opacity(0.12), in: RoundedRectangle(cornerRadius: 5, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .strokeBorder(color.opacity(0.25), lineWidth: 0.5)
            )
    }

    private var color: Color {
        switch method.uppercased() {
        case "GET":     return .blue
        case "POST":    return .green
        case "PUT":     return .orange
        case "PATCH":   return .yellow
        case "DELETE":  return .red
        case "HEAD":    return .cyan
        case "OPTIONS": return .purple
        default:        return .secondary
        }
    }
}

struct StatusCodeBadge: View {
    let code: Int

    var body: some View {
        Text("\(code)")
            .font(.system(size: 10, weight: .semibold, design: .monospaced))
            .foregroundStyle(color)
            .padding(.horizontal, 4)
            .padding(.vertical, 1)
            .background(color.opacity(0.10), in: RoundedRectangle(cornerRadius: 4, style: .continuous))
    }

    private var color: Color {
        switch code {
        case 200..<300: return .green
        case 300..<400: return .blue
        case 400..<500: return .orange
        case 500...:    return .red
        default:        return .secondary
        }
    }
}

struct InspectorSectionHeader: View {
    let title: String
    let icon: String

    init(_ title: String, icon: String) {
        self.title = title
        self.icon = icon
    }

    var body: some View {
        Label(title, systemImage: icon)
            .font(.system(size: 11, weight: .semibold))
            .textCase(nil)
    }
}

struct BodyPreviewButton: View {
    let text: String
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(label)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.primary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.tertiary)
                }
                Text(text.prefix(120) + (text.count > 120 ? "…" : ""))
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
                    .truncationMode(.tail)
                HStack {
                    Spacer()
                    Text("\(text.count) bytes")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
            .padding(.vertical, 2)
        }
        .buttonStyle(.plain)
    }
}
