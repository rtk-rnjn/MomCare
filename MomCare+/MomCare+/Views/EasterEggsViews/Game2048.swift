import SwiftUI
import Combine

@MainActor
class Game2048: ObservableObject {
    @Published var board: [[Int]] = Array(repeating: Array(repeating: 0, count: 4), count: 4)
    @Published var score: Int = 0
    @Published var tileIds: [[UUID]] = (0..<4).map { _ in (0..<4).map { _ in UUID() } }

    init() { reset() }

    func reset() {
        board = Array(repeating: Array(repeating: 0, count: 4), count: 4)
        tileIds = (0..<4).map { _ in (0..<4).map { _ in UUID() } }
        score = 0
        spawnTile(); spawnTile()
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

    private func slideAndMerge(_ line: [Int], _ ids: [UUID]) -> ([Int], [UUID]) {
        var newLine = line
        var newIds = ids

        // Slide
        for i in 0..<4 {
            if newLine[i] == 0 {
                for j in i+1..<4 {
                    if newLine[j] != 0 {
                        newLine[i] = newLine[j]
                        newIds[i] = newIds[j]
                        newLine[j] = 0
                        break
                    }
                }
            }
        }

        // Merge
        for i in 0..<3 {
            if newLine[i] != 0 && newLine[i] == newLine[i+1] {
                newLine[i] *= 2
                score += newLine[i]

                // keep tile i identity
                // remove tile i+1
                newLine[i+1] = 0

                for j in i+1..<3 {
                    newLine[j] = newLine[j+1]
                    newIds[j] = newIds[j+1]
                }

                newLine[3] = 0
                newIds[3] = UUID()
            }
        }
        return (newLine, newIds)
    }

    private func getLine(at i: Int, for dir: Edge) -> [Int] {
        switch dir {
        case .leading: return board[i]
        case .trailing: return board[i].reversed()
        case .top: return (0..<4).map { board[$0][i] }
        case .bottom: return (0..<4).map { board[$0][i] }.reversed()
        }
    }

    private func getIdLine(at i: Int, for dir: Edge) -> [UUID] {
        switch dir {
        case .leading: return tileIds[i]
        case .trailing: return tileIds[i].reversed()
        case .top: return (0..<4).map { tileIds[$0][i] }
        case .bottom: return (0..<4).map { tileIds[$0][i] }.reversed()
        }
    }

    private func setLine(_ line: [Int], _ ids: [UUID], at i: Int, for dir: Edge) {
        var fL = line; var fI = ids
        if dir == .trailing || dir == .bottom { fL.reverse(); fI.reverse() }
        for j in 0..<4 {
            if dir == .leading || dir == .trailing {
                board[i][j] = fL[j]; tileIds[i][j] = fI[j]
            } else {
                board[j][i] = fL[j]; tileIds[j][i] = fI[j]
            }
        }
    }
}

struct Game2048View: View {
    @StateObject private var engine = Game2048()
    @AppStorage("highScore") private var highScore: Int = 0
    @Namespace private var gridSpace

    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @Environment(\.accessibilityReduceTransparency) var reduceTransparency

    var body: some View {
        VStack(spacing: 24) {
            HStack {
                Text("2048").font(.system(size: 50, weight: .black))
                Spacer()
                ScoreBox(title: "SCORE", value: engine.score)
                ScoreBox(title: "BEST", value: highScore)
            }
            .padding(.horizontal)

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

                        let movementAnimation: Animation = reduceMotion ? .linear(duration: 0.1) : .spring(response: 0.2, dampingFraction: 0.8)

                        withAnimation(movementAnimation) {
                            engine.move(direction)
                        }

                        if engine.score > highScore { highScore = engine.score }
                    }
            )

            Button(action: { withAnimation { engine.reset() } }) {
                Label("New Game", systemImage: "arrow.clockwise")
                    .font(.headline).padding().frame(maxWidth: .infinity)
                    .background(Color.accentColor).foregroundColor(.white).cornerRadius(12)
            }
            .padding(.horizontal)
        }
    }

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
        VStack(spacing: 12) {
            ForEach(0..<4, id: \.self) { r in
                HStack(spacing: 12) {
                    ForEach(0..<4, id: \.self) { c in
                        let val = engine.board[r][c]
                        ZStack {
                            if val != 0 {
                                unsafe TileView(value: val)
                                    .matchedGeometryEffect(id: engine.tileIds[r][c], in: gridSpace)
                                    .transition(reduceMotion ? .opacity : .scale.combined(with: .opacity))
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
            }
        }
    }
}

// MARK: - Helper Views
private struct ScoreBox: View {
    let title: String
    let value: Int
    var body: some View {
        VStack {
            Text(title).font(.caption).bold()
            Text("\(value)").font(.title3).bold()
        }
        .padding(.vertical, 8).padding(.horizontal, 16)
        .background(Color(.systemGray4)).cornerRadius(8)
    }
}

private struct TileView: View {
    let value: Int
    @Environment(\.accessibilityReduceTransparency) var reduceTransparency

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(tileColor)
            Text("\(value)")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(value < 8 ? .black : .white)
                .minimumScaleFactor(0.5)
        }
    }

    private var tileColor: Color {
        switch value {
        case 2: return .white
        case 4: return Color(red: 0.95, green: 0.9, blue: 0.8)
        case 8: return .orange.opacity(0.6)
        case 16: return .orange.opacity(0.8)
        case 32: return .orange
        case 64: return .red.opacity(0.7)
        case 128...2048: return .yellow
        default: return .orange
        }
    }
}
