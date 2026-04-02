import Combine
import SwiftUI

@MainActor
class Game2048: ObservableObject {
    // MARK: Lifecycle

    init() {
        reset()
    }

    // MARK: Internal

    @Published var board: [[Int]] = Array(repeating: Array(repeating: 0, count: 4), count: 4)
    @Published var score: Int = 0
    @Published var tileIds: [[UUID]] = (0..<4).map { _ in (0..<4).map { _ in UUID() } }

    func reset() {
        board = Array(repeating: Array(repeating: 0, count: 4), count: 4)
        tileIds = (0..<4).map { _ in (0..<4).map { _ in UUID() } }
        score = 0
        spawnTile()
        spawnTile()
    }

    func spawnTile() {
        let emptyCells = board.indices.flatMap { r in
            board[r].indices.filter { board[r][$0] == 0 }.map { (r, $0) }
        }
        if let (r, c) = emptyCells.randomElement() {
            board[r][c] = Double.random(in: 0...1) < 0.9 ? 2 : 4
            tileIds[r][c] = UUID()
        }
    }

    func move(_ direction: Edge) {
        let oldBoard = board

        for i in 0..<4 {
            var line = getLine(at: i, for: direction)
            var idLine = getIdLine(at: i, for: direction)
            (line, idLine) = slideAndMerge(line, idLine)
            setLine(line, idLine, at: i, for: direction)
        }

        if board != oldBoard {
            spawnTile()
        }
    }

    // MARK: Private

    private func slideAndMerge(_ line: [Int], _ ids: [UUID]) -> ([Int], [UUID]) {
        var newLine = Array(repeating: 0, count: 4)
        var newIds = (0..<4).map { _ in UUID() }

        var lastIndex = 0
        for i in 0..<4 where line[i] != 0 {
            newLine[lastIndex] = line[i]
            newIds[lastIndex] = ids[i]
            lastIndex += 1
        }

        for i in 0..<3 where newLine[i] != 0 && newLine[i] == newLine[i+1] {
            newLine[i] *= 2
            score += newLine[i]

            for j in i+1..<3 {
                newLine[j] = newLine[j+1]
                newIds[j] = newIds[j+1]
            }
            newLine[3] = 0
            newIds[3] = UUID()
        }

        return (newLine, newIds)
    }

    private func getLine(at i: Int, for dir: Edge) -> [Int] {
        switch dir {
        case .leading: board[i]
        case .trailing: board[i].reversed()
        case .top: (0..<4).map { board[$0][i] }
        case .bottom: (0..<4).map { board[$0][i] }.reversed()
        }
    }

    private func getIdLine(at i: Int, for dir: Edge) -> [UUID] {
        switch dir {
        case .leading: tileIds[i]
        case .trailing: tileIds[i].reversed()
        case .top: (0..<4).map { tileIds[$0][i] }
        case .bottom: (0..<4).map { tileIds[$0][i] }.reversed()
        }
    }

    private func setLine(_ line: [Int], _ ids: [UUID], at i: Int, for dir: Edge) {
        var fL = line
        var fI = ids
        if dir == .trailing || dir == .bottom {
            fL.reverse()
            fI.reverse()
        }
        for j in 0..<4 {
            if dir == .leading || dir == .trailing {
                board[i][j] = fL[j]
                tileIds[i][j] = fI[j]
            } else {
                board[j][i] = fL[j]
                tileIds[j][i] = fI[j]
            }
        }
    }
}

struct Game2048View: View {
    // MARK: Internal

    var body: some View {
        NavigationStack {
            VStack {
                ZStack {
                    boardBackground
                    boardGrid
                }
                .aspectRatio(1, contentMode: .fit)
                .padding(12)
                .background(reduceTransparency ? Color.gray : Color(.systemGray5).opacity(0.8))
                .cornerRadius(12)
                .padding()
                .gesture(
                    DragGesture(minimumDistance: 30)
                        .onEnded { gesture in
                            let h = gesture.translation.width
                            let v = gesture.translation.height
                            let direction: Edge = abs(h) > abs(v) ? (h > 0 ? .trailing : .leading) : (v > 0 ? .bottom : .top)

                            withAnimation(reduceMotion ? .linear(duration: 0.1) : .spring(response: 0.2, dampingFraction: 0.8)) {
                                engine.move(direction)
                            }

                            if engine.score > highScore {
                                highScore = engine.score
                            }
                        }
                )
            }
            .padding(.horizontal)
            .navigationTitle("2048")
            .navigationBarTitleDisplayMode(.large)
            .navigationSubtitle("Score: \(engine.score) | High Score: \(highScore)")
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    Button {
                        withAnimation { engine.reset() }
                    } label: {
                        Label("New Game", systemImage: "arrow.clockwise")
                            .frame(maxWidth: .infinity)
                            .background(Color.accentColor)
                            .foregroundStyle(.white)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel) {
                        dismiss()
                    }
                }
            }
        }
    }

    // MARK: Private

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.dismiss) private var dismiss

    @StateObject private var engine: Game2048 = .init()
    @AppStorage("highScore", store: Database.shared.userDefaults) private var highScore: Int = 0
    @Namespace private var gridSpace

    private var boardBackground: some View {
        VStack(spacing: 12) {
            ForEach(0..<4, id: \.self) { _ in
                HStack(spacing: 12) {
                    ForEach(0..<4, id: \.self) { _ in
                        RoundedRectangle(cornerRadius: 8)
                            .fill(reduceTransparency ? Color.gray : Color(.systemGray6))
                    }
                }
            }
        }
    }

    private var boardGrid: some View {
        GeometryReader { proxy in
            let cellSize = (proxy.size.width - 36) / 4

            ZStack(alignment: .topLeading) {
                ForEach(0..<4, id: \.self) { r in
                    ForEach(0..<4, id: \.self) { c in
                        let val = engine.board[r][c]
                        if val != 0 {
                            TileView(value: val)
                                .frame(width: cellSize, height: cellSize)
                                // Calculate exact position so tiles can fly anywhere
                                .offset(
                                    x: CGFloat(c) * (cellSize + 12),
                                    y: CGFloat(r) * (cellSize + 12)
                                )
                                .matchedGeometryEffect(id: engine.tileIds[r][c], in: gridSpace)
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                }
            }
        }
    }
}

private struct ScoreBox: View {
    let title: String
    let value: Int

    var body: some View {
        VStack {
            Text(title).font(.caption).bold()
            Text("\(value)").font(.title3).bold()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(Color(.systemGray4))
        .cornerRadius(8)
    }
}

private struct TileView: View {
    // MARK: Internal

    let value: Int

    @Environment(\.accessibilityReduceTransparency) var reduceTransparency

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(tileColor)
            Text("\(value)")
                .font(.largeTitle)
.bold()
                .foregroundStyle(value < 8 ? .black : .white)
                .minimumScaleFactor(0.5)
        }
    }

    // MARK: Private

    private var tileColor: Color {
        switch value {
        case 2: .white
        case 4: Color(red: 0.95, green: 0.9, blue: 0.8)
        case 8: .orange.opacity(0.6)
        case 16: .orange.opacity(0.8)
        case 32: .orange
        case 64: .red.opacity(0.7)
        case 128...2048: .yellow
        default: .orange
        }
    }
}
