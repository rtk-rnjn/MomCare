import SwiftUI

typealias MCEditButton = EditButton

struct MCSaveButton: View {
    let action: () -> Void

    var body: some View {
        if #available(iOS 26.0, *) {
            Button(role: .confirm, action: action)
        } else {
            Button("Save", systemImage: "checkmark", role: nil, action: action)
        }
    }
}

struct MCCancelButton: View {
    let action: () -> Void

    var body: some View {
        if #available(iOS 26.0, *) {
            Button(role: .cancel, action: action)
        } else {
            Button("Cancel", systemImage: "xmark", role: .cancel, action: action)
        }
    }
}

struct MCDoneButton: View {
    let action: () -> Void

    var body: some View {
        if #available(iOS 26.0, *) {
            Button(role: .confirm, action: action)
        } else {
            Button("Done", systemImage: "checkmark", role: nil, action: action)
        }
    }
}

struct MCCloseButton: View {
    let action: () -> Void

    var body: some View {
        if #available(iOS 26.0, *) {
            Button(role: .cancel, action: action)
        } else {
            Button("Cancel", systemImage: "xmark", role: .cancel, action: action)
        }
    }
}

struct MCDeleteButton: View {
    let action: () -> Void

    var body: some View {
        if #available(iOS 26.0, *) {
            Button(role: .destructive, action: action)
        } else {
            Button("Delete", systemImage: "trash", role: .destructive, action: action)
        }
    }
}

struct MCAddButton: View {
    let action: () -> Void

    var body: some View {
        Button("Add", systemImage: "plus", role: nil, action: action)
    }
}
