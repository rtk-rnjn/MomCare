import SwiftUI

struct JSONTreeRow: View {
    let key: String?
    let node: JSONNode
    let depth: Int

    @State private var expanded = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

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
                            .fill(Color.secondary.opacity(0.2))
                            .frame(width: 1)
                            .padding(.vertical, 2)
                    }
                }
                .frame(width: CGFloat(depth) * 16)
                .accessibilityHidden(true)
            }

            // Expand chevron or leaf bullet
            if node.isLeaf {
                Circle()
                    .frame(width: 5, height: 5)
                    .accessibilityHidden(true)
            } else {
                Image(systemName: expanded ? "chevron.down" : "chevron.right")
                    .font(.caption2.bold())
                    .frame(width: 12)
                    .accessibilityHidden(true)
            }

            // Key label
            if let key {
                Text(key)
                    .font(.footnote.monospaced())
                Text(":")
                    .font(.footnote.monospaced())
            }

            // Value or type badge
            if let leaf = node.leafDisplayValue {
                Text(leaf)
                    .font(.footnote.monospaced())
                    .textSelection(.enabled)
            } else {
                // Container badge
                HStack(spacing: 4) {
                    Text(node.typeLabel)
                        .font(.caption2.weight(.semibold).monospaced())
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .clipShape(RoundedRectangle(cornerRadius: 3))

                    Text("\(node.childCount)")
                        .font(.caption2.monospaced())
                        .foregroundStyle(.secondary)
                }
            }

            Spacer(minLength: 0)
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 12)
        .contentShape(Rectangle())
        .onTapGesture {
            if !node.isLeaf {
                withAnimation(reduceMotion ? nil : .default) {
                    expanded.toggle()
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(rowAccessibilityLabel)
        .accessibilityHint(node.isLeaf ? "" : (expanded ? "Double tap to collapse" : "Double tap to expand"))
        .accessibilityAddTraits(node.isLeaf ? [] : .isButton)
        .accessibilityValue(node.isLeaf ? "" : (expanded ? "expanded" : "collapsed"))
        .accessibilityAction {
            if !node.isLeaf {
                withAnimation(reduceMotion ? nil : .default) {
                    expanded.toggle()
                }
            }
        }
    }

    private var rowAccessibilityLabel: String {
        let keyPart = key.map { "\($0): " } ?? ""
        if let leaf = node.leafDisplayValue {
            return "\(keyPart)\(leaf)"
        } else {
            return "\(keyPart)\(node.typeLabel) with \(node.childCount) item\(node.childCount == 1 ? "" : "s")"
        }
    }

    @ViewBuilder
    private var children: some View {
        switch node {
        case .array(let items):
            ForEach(Array(items.enumerated()), id: \.offset) { idx, child in
                JSONTreeRow(key: "[\(idx)]", node: child, depth: depth + 1)
                    .transition(reduceMotion ? .opacity : .opacity.combined(with: .move(edge: .top)))
            }
        case .object(let pairs):
            ForEach(pairs, id: \.key) { pair in
                JSONTreeRow(key: pair.key, node: pair.value, depth: depth + 1)
                    .transition(reduceMotion ? .opacity : .opacity.combined(with: .move(edge: .top)))
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
                            .font(.footnote.monospaced())
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
                    .accessibilityLabel("Copy raw content")
                    .accessibilityHint("Copies the full JSON body to the clipboard")
                }
            }
        }
    }
}
