import Combine
import SwiftUI

enum WaterType: CaseIterable {
    case blue
    case red
    case green
    case yellow
    case purple
    case orange

    // MARK: Internal

    var color: Color {
        switch self {
        case .blue: return .blue; case .red: return .red; case .green: return .green
        case .yellow: return .yellow; case .purple: return .purple; case .orange: return .orange
        }
    }

    // Symbols for Colorblind accessibility
    var symbol: String {
        switch self {
        case .blue: return "drop.fill"; case .red: return "flame.fill"
        case .green: return "leaf.fill"; case .yellow: return "sun.max.fill"
        case .purple: return "moon.fill"; case .orange: return "bolt.fill"
        }
    }

    var name: String {
        "\(self)".capitalized
    }
}

class WaterSortEngine: ObservableObject {
    // MARK: Lifecycle

    init(difficulty: Int = 3) {
        self.difficulty = difficulty
        setupLevel()
    }

    // MARK: Internal

    @Published var bottles: [[WaterType]] = []
    @Published var selectedBottleIndex: Int?
    @Published var moves: Int = 0
    @Published var isSolved: Bool = false

    let capacity = 4
    var difficulty: Int // Number of colors

    func setupLevel() {
        var colors = [WaterType]()
        let activeColors = Array(WaterType.allCases.prefix(difficulty))

        // Create 4 units of each color
        for color in activeColors {
            for _ in 0..<capacity {
                colors.append(color)
            }
        }
        colors.shuffle()

        // Distribute into bottles (plus 2 empty ones)
        bottles = []
        for i in 0..<difficulty {
            let start = i * capacity
            bottles.append(Array(colors[start..<start+capacity]))
        }
        bottles.append([]); bottles.append([]) // Empty relief bottles
        isSolved = false
        moves = 0
    }

    func selectBottle(_ index: Int) {
        if let selected = selectedBottleIndex {
            if selected == index {
                selectedBottleIndex = nil // Deselect
            } else {
                tryPour(from: selected, to: index)
                selectedBottleIndex = nil
            }
        } else {
            if !bottles[index].isEmpty {
                selectedBottleIndex = index
            }
        }
    }

    // MARK: Private

    private func tryPour(from src: Int, to dst: Int) {
        guard !bottles[src].isEmpty else {
            return
        }
        guard bottles[dst].count < capacity else {
            return
        }

        let colorToMove = bottles[src].last!

        // Rule: Must be empty or match top color
        if bottles[dst].isEmpty || bottles[dst].last == colorToMove {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                // Pour all contiguous units of the same color
                while !bottles[src].isEmpty, bottles[src].last == colorToMove, bottles[dst].count < capacity {
                    bottles[dst].append(bottles[src].removeLast())
                }
                moves += 1
            }
            checkWin()
        }
    }

    private func checkWin() {
        isSolved = bottles.allSatisfy { bottle in
            bottle.isEmpty || (bottle.count == capacity && bottle.allSatisfy { $0 == bottle.first })
        }
    }
}

struct GameWaterSortView: View {
    // MARK: Internal

    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 70))], spacing: 40) {
                    ForEach(0..<engine.bottles.count, id: \.self) { index in
                        BottleView(
                            colors: engine.bottles[index],
                            isSelected: engine.selectedBottleIndex == index,
                            capacity: engine.capacity
                        )
                        .onTapGesture {
                            engine.selectBottle(index)
                        }
                    }
                }
                .padding()

                Spacer()

                if engine.isSolved {
                    Text("🎉 Well Done!")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.green)
                        .transition(.scale)
                }
            }
            .navigationTitle("Water Sort")
            .navigationBarTitleDisplayMode(.large)
            .navigationSubtitle("Moves: \(engine.moves)")
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    Button("Restart") {
                        withAnimation {
                            engine.setupLevel()
                        }
                    }
                }

                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button("Easy (4 colors)") { withAnimation { engine.difficulty = 4; engine.setupLevel() } }
                        Button("Medium (6 colors)") { withAnimation { engine.difficulty = 6; engine.setupLevel() } }
                        Button("Hard (8 colors)") { withAnimation { engine.difficulty = 8; engine.setupLevel() } }
                    } label: {
                        Label("Difficulty", systemImage: "gearshape.fill")
                    }
                    .accessibilityLabel("Settings")
                }
            }
        }
    }

    // MARK: Private

    // MARK: Private

    @StateObject private var engine: WaterSortEngine = .init(difficulty: 4)
}

struct BottleView: View {
    let colors: [WaterType]
    let isSelected: Bool
    let capacity: Int

    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @Environment(\.accessibilityReduceTransparency) var reduceTransparency

    var body: some View {
        VStack(spacing: 8) {
            ZStack(alignment: .bottom) {
                // Glass Shape
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.primary.opacity(reduceTransparency ? 1.0 : 0.3), lineWidth: 3)
                    .frame(width: 60, height: 160)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(reduceTransparency ? Color(.systemBackground) : Color.primary.opacity(0.05))
                    )

                // Water Layers
                VStack(spacing: 0) {
                    ForEach((0..<colors.count).reversed(), id: \.self) { i in
                        let type = colors[i]
                        ZStack {
                            Rectangle()
                                .fill(type.color)

                            // ACCESSIBILITY: Symbol for Colorblind users
                            Image(systemName: type.symbol)
                                .foregroundColor(.white.opacity(0.8))
                                .font(.system(size: 14, weight: .bold))
                                .shadow(radius: 1)
                        }
                        .frame(width: 54, height: 150 / CGFloat(capacity))
                        .overlay(Rectangle().stroke(Color.white.opacity(0.2), lineWidth: 1))
                        .accessibilityLabel(type.name)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(3)
            }
            // ACCESSIBILITY: Replace "flying" animation with simple highlight if Reduce Motion is on
            .offset(y: (isSelected && !reduceMotion) ? -20 : 0)
            .scaleEffect((isSelected && reduceMotion) ? 1.1 : 1.0)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.accentColor, lineWidth: isSelected ? 4 : 0)
            )
            .animation(reduceMotion ? .none : .spring(response: 0.3), value: isSelected)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Bottle with \(colors.count) layers. Top color is \(colors.last?.name ?? "empty")")
        .accessibilityHint("Tap to select or pour.")
    }
}
