import SwiftUI

struct DataInspectorView: View {

    // MARK: Internal

    var body: some View {
        List {
            Section("UserDefaults (\(udEntries.count) keys)") {
                if udEntries.isEmpty {
                    Text("No user defaults found")
                        .foregroundStyle(.secondary)
                        .font(.caption)
                } else {
                    ForEach(udEntries, id: \.key) { entry in
                        VStack(alignment: .leading, spacing: 2) {
                            Text(entry.key)
                                .font(.caption.bold())
                            Text(entry.value)
                                .font(.caption.monospaced())
                                .foregroundStyle(.secondary)
                                .lineLimit(3)
                        }
                        .padding(.vertical, 2)
                    }
                }
            }

            // MARK: Cached Files
            Section("Cache Directory (\(cachedFiles.count) files)") {
                if cachedFiles.isEmpty {
                    Text("Cache is empty")
                        .foregroundStyle(.secondary)
                        .font(.caption)
                } else {
                    ForEach(cachedFiles) { file in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(file.name)
                                    .font(.caption.bold())
                                    .lineLimit(1)
                                Text(file.path)
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }
                            Spacer()
                            Text(file.formattedSize)
                                .font(.caption2.monospacedDigit())
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }

            Section("Actions") {
                Button {
                    showClearConfirm = true
                } label: {
                    Label("Clear Cache", systemImage: "trash")
                        .foregroundStyle(.red)
                }

                Button {
                    loadData()
                } label: {
                    Label("Refresh", systemImage: "arrow.clockwise")
                }
            }
        }
        .navigationTitle("Data Inspector")
        .navigationBarTitleDisplayMode(.inline)
        .task { loadData() }
        .confirmationDialog("Clear all cached data?", isPresented: $showClearConfirm, titleVisibility: .visible) {
            Button("Clear Cache", role: .destructive) {
                clearCache()
                loadData()
            }
        }
    }

    // MARK: Private

    @State private var udEntries: [(key: String, value: String)] = []
    @State private var cachedFiles: [CachedFileInfo] = []
    @State private var showClearConfirm = false

    private func loadData() {
        loadUserDefaults()
        loadCachedFiles()
    }

    private func loadUserDefaults() {
        let dict = UserDefaults.standard.dictionaryRepresentation()
        udEntries = dict
            .filter { !$0.key.hasPrefix("com.apple") && !$0.key.hasPrefix("NS") }
            .sorted { $0.key < $1.key }
            .map { (key: $0.key, value: "\($0.value)") }
    }

    private func loadCachedFiles() {
        guard let cacheURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first,
              let contents = try? FileManager.default.contentsOfDirectory(
                at: cacheURL, includingPropertiesForKeys: [.fileSizeKey, .isDirectoryKey],
                options: .skipsHiddenFiles)
        else { cachedFiles = []; return }

        cachedFiles = contents.compactMap { url -> CachedFileInfo? in
            let attrs = try? url.resourceValues(forKeys: [.fileSizeKey, .isDirectoryKey])
            let size = attrs?.fileSize ?? 0
            return CachedFileInfo(
                name: url.lastPathComponent,
                path: url.path,
                sizeBytes: size
            )
        }
        .sorted { $0.sizeBytes > $1.sizeBytes }
    }

    private func clearCache() {
        guard let cacheURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first,
              let contents = try? FileManager.default.contentsOfDirectory(
                at: cacheURL, includingPropertiesForKeys: nil)
        else { return }
        for url in contents {
            try? FileManager.default.removeItem(at: url)
        }
    }
}

private struct CachedFileInfo: Identifiable {
    let id: UUID = .init()
    let name: String
    let path: String
    let sizeBytes: Int

    var formattedSize: String {
        ByteCountFormatter.string(fromByteCount: Int64(sizeBytes), countStyle: .file)
    }
}
