import SwiftUI

struct JSONTreeRow: View {
    let key: String?
    let node: JSONNode
    let depth: Int

    @State private var expanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            rowContent
            if expanded {
                children
            }
        }
    }

    @ViewBuilder
    private var rowContent: some View {
        HStack(spacing: 6) {
            // Indent guides
            if depth > 0 {
                HStack(spacing: 8) {
                    ForEach(0..<depth, id: \.self) { _ in
                        Rectangle()
                            .fill(Color.white.opacity(0.07))
                            .frame(width: 1)
                            .padding(.vertical, 2)
                    }
                }
                .frame(width: CGFloat(depth) * 16)
            }

            // Expand chevron or leaf bullet
            if node.isLeaf {
                Circle()
                    .frame(width: 5, height: 5)
            } else {
                Image(systemName: expanded ? "chevron.down" : "chevron.right")
                    .font(.system(size: 9, weight: .bold))
                    .frame(width: 12)
            }

            // Key label
            if let key {
                Text(key)
                    .font(.system(size: 12, design: .monospaced))
                Text(":")
                    .font(.system(size: 12, design: .monospaced))
            }

            // Value or type badge
            if let leaf = node.leafDisplayValue {
                Text(leaf)
                    .font(.system(size: 12, design: .monospaced))
                    .textSelection(.enabled)
            } else {
                // Container badge
                HStack(spacing: 4) {
                    Text(node.typeLabel)
                        .font(.system(size: 9, weight: .semibold, design: .monospaced))
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .clipShape(RoundedRectangle(cornerRadius: 3))

                    Text("\(node.childCount)")
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.3))
                }
            }

            Spacer(minLength: 0)
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 12)
        .contentShape(Rectangle())
        .onTapGesture {
            if !node.isLeaf {
                expanded.toggle()
                
            }
        }
    }

    @ViewBuilder
    private var children: some View {
        switch node {
        case .array(let items):
            ForEach(Array(items.enumerated()), id: \.offset) { idx, child in
                JSONTreeRow(key: "[\(idx)]", node: child, depth: depth + 1)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        case .object(let pairs):
            ForEach(pairs, id: \.key) { pair in
                JSONTreeRow(key: pair.key, node: pair.value, depth: depth + 1)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        default:
            EmptyView()
        }
    }
}


indirect enum JSONNode {
    case null
    case bool(Bool)
    case number(Double)
    case string(String)
    case array([JSONNode])
    case object([(key: String, value: JSONNode)])

    static func parse(_ data: Data) -> JSONNode? {
        guard let obj = try? JSONSerialization.jsonObject(with: data) else { return nil }
        return JSONNode(any: obj)
    }

    init?(any value: Any) {
        if value is NSNull { self = .null }
        else if let b = value as? Bool { self = .bool(b) }
        else if let n = value as? Double { self = .number(n) }
        else if let s = value as? String { self = .string(s) }
        else if let a = value as? [Any] {
            self = .array(a.compactMap { JSONNode(any: $0) })
        } else if let d = value as? [String: Any] {
            let pairs = d.sorted { $0.key < $1.key }.compactMap { k, v -> (String, JSONNode)? in
                guard let node = JSONNode(any: v) else { return nil }
                return (k, node)
            }
            self = .object(pairs)
        } else { return nil }
    }

    var isLeaf: Bool {
        switch self {
        case .array(let a): return a.isEmpty
        case .object(let o): return o.isEmpty
        default: return true
        }
    }

    var typeLabel: String {
        switch self {
        case .null:   return "null"
        case .bool:   return "bool"
        case .number: return "num"
        case .string: return "str"
        case .array:  return "arr"
        case .object: return "obj"
        }
    }

    var leafDisplayValue: String? {
        switch self {
        case .null:        return "null"
        case .bool(let b): return b ? "true" : "false"
        case .number(let n):
            return n.truncatingRemainder(dividingBy: 1) == 0
                ? String(Int(n)) : String(n)
        case .string(let s): return "\"\(s)\""
        default: return nil
        }
    }

    var childCount: Int {
        switch self {
        case .array(let a): return a.count
        case .object(let o): return o.count
        default: return 0
        }
    }
}


struct JSONSheetView: View {
    let title: String
    let raw: String

    @Environment(\.dismiss) private var dismiss

    private var rootNode: JSONNode? {
        guard let data = raw.data(using: .utf8) else { return nil }
        return JSONNode.parse(data)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                if let root = rootNode {
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 0) {
                            JSONTreeRow(key: nil, node: root, depth: 0)
                        }
                        .padding(.vertical, 8)
                    }
                } else {
                    // Fallback: raw text
                    ScrollView {
                        Text(raw)
                            .font(.system(size: 12, design: .monospaced))
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        UIPasteboard.general.string = raw
                    } label: {
                        Label("Copy", systemImage: "doc.on.doc")
                            .font(.caption)
                    }
                }
            }
        }
    }
}
