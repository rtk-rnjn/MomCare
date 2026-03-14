import SwiftUI
import Foundation

struct NetworkInspectorView: View {

    // MARK: Internal

    var body: some View {
        List {
            if filtered.isEmpty {
                ContentUnavailableView(
                    "No Requests",
                    systemImage: "network.slash",
                    description: Text("Register DebugURLProtocol in URLSession to capture traffic.")
                )
            } else {
                ForEach(filtered) { request in
                    Button { selectedRequest = request } label: {
                        NetworkRequestRow(request: request)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .searchable(text: $searchText, prompt: "Filter by URL or method")
        .navigationTitle("Network Inspector")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Clear") { store.clearNetworkRequests() }
                    .foregroundStyle(.red)
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
        guard !searchText.isEmpty else { return store.networkRequests }
        return store.networkRequests.filter {
            $0.url.localizedCaseInsensitiveContains(searchText) ||
            $0.method.localizedCaseInsensitiveContains(searchText)
        }
    }

}

private struct NetworkRequestRow: View {
    let request: DebugNetworkRequest

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack {
                MethodBadge(method: request.method)
                if let code = request.statusCode {
                    Text("\(code)")
                        .font(.caption.bold())
                        .foregroundStyle(request.statusColor)
                }
                Spacer()
                Text(Measurement(value: request.responseTime * 1000, unit: UnitDuration.milliseconds).formatted(.measurement(width: .abbreviated, numberFormatStyle: .number.precision(.fractionLength(0)))))
                .font(.caption.monospacedDigit())
                .foregroundStyle(.secondary)
            }
            Text(request.url)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
            if let err = request.error {
                Text(err)
                    .font(.caption2)
                    .foregroundStyle(.red)
            }
        }
        .padding(.vertical, 2)
    }
}

private struct NetworkRequestDetailView: View {

    // MARK: Internal

    let request: DebugNetworkRequest

    var body: some View {
        NavigationStack {
            List {
                Section("Request") {
                    DebugRow(label: "Method", value: request.method)
                    DebugRow(label: "URL", value: request.url)
                    DebugRow(label: "Time", value: request.timestamp.formatted(date: .omitted, time: .standard))
                }
                Section("Response") {
                    if let code = request.statusCode {
                        DebugRow(label: "Status", value: "\(code)", valueColor: request.statusColor)
                    }
                    DebugRow(label: "Duration", value: Measurement(value: request.responseTime * 1000, unit: UnitDuration.milliseconds).formatted(.measurement(width: .abbreviated, numberFormatStyle: .number.precision(.fractionLength(1)))))
                }
                if let body = request.requestBody {
                    Section("Request Body") {
                        Text(body)
                            .font(.caption.monospaced())
                            .textSelection(.enabled)
                    }
                }
                if let body = request.responseBody {
                    Section("Response Body") {
                        Text(body)
                            .font(.caption.monospaced())
                            .textSelection(.enabled)
                    }
                }
                if let err = request.error {
                    Section("Error") {
                        Text(err)
                            .foregroundStyle(.red)
                            .font(.caption)
                    }
                }
            }
            .navigationTitle("Request Detail")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    // MARK: Private

    @Environment(\.dismiss) private var dismiss

}

struct MethodBadge: View {

    // MARK: Internal

    let method: String

    var body: some View {
        Text(method.uppercased())
            .font(.caption2.bold())
            .padding(.horizontal, 5)
            .padding(.vertical, 2)
            .background(color.opacity(0.2))
            .foregroundStyle(color)
            .clipShape(RoundedRectangle(cornerRadius: 4))
    }

    // MARK: Private

    private var color: Color {
        switch method.uppercased() {
        case "GET": return .blue
        case "POST": return .green
        case "PUT": return .orange
        case "PATCH": return .yellow
        case "DELETE": return .red
        default: return .gray
        }
    }

}
