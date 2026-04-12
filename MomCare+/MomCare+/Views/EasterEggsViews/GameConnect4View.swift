import Combine
import SwiftUI

enum C4Player {
    case human
    case computer

    // MARK: Internal

    var color: Color {
        switch self {
        case .human: .red
        case .computer: .yellow
        }
    }

    var name: String {
        switch self {
        case .human: "You"
        case .computer: "CPU"
        }
    }
}

enum C4GameState: Equatable {
    case playing
    case won(C4Player)
    case draw
}

@MainActor
class Connect4Engine: ObservableObject {
    // MARK: Lifecycle

    init() {
        reset()
    }

    // MARK: Internal

    static let rows = 6
    static let columns = 7

    @Published var board: [[C4Player?]] = Connect4Engine.emptyBoard()
    @Published var gameState: C4GameState = .playing
    @Published var currentTurn: C4Player = .human
    @Published var winningCells: Set<[Int]> = []
    @Published var isComputerThinking: Bool = false
    @Published var hoverColumn: Int?
    @Published var playerWins: Int = 0
    @Published var computerWins: Int = 0
    @Published var draws: Int = 0

    // Which row just had a piece dropped (for drop animation)
    @Published var lastDropped: (row: Int, col: Int)?

    func reset() {
        board = Connect4Engine.emptyBoard()
        gameState = .playing
        currentTurn = .human
        winningCells = []
        isComputerThinking = false
        hoverColumn = nil
        lastDropped = nil
    }

    func humanDrop(column: Int) {
        guard gameState == .playing,
              currentTurn == .human,
              !isComputerThinking,
              let row = lowestEmpty(column: column) else {
                  return
              }

        place(player: .human, row: row, col: column)

        if let cells = checkWin(for: .human) {
            winningCells = cells
            gameState = .won(.human)
            playerWins += 1
            return
        }
        if isFull() {
            gameState = .draw
            draws += 1
            return
        }

        currentTurn = .computer
        isComputerThinking = true

        Task {
            try? await Task.sleep(nanoseconds: 500_000_000)
            computerDrop()
        }
    }

    func lowestEmpty(column: Int) -> Int? {
        lowestEmpty(column: column, board: board)
    }

    func checkWin(for player: C4Player) -> Set<[Int]>? {
        checkWin(for: player, on: board).map { Set($0.map { $0 }) }
    }

    // MARK: Private

    private lazy var cachedColumnOrder: [Int] = {
        let cols = Connect4Engine.columns
        let center = cols / 2
        return (0..<cols).sorted { abs($0 - center) < abs($1 - center) }
    }()

    private static func emptyBoard() -> [[C4Player?]] {
        Array(repeating: Array(repeating: nil, count: columns), count: rows)
    }

    private func place(player: C4Player, row: Int, col: Int) {
        board[row][col] = player
        lastDropped = (row, col)
    }

    private func computerDrop() {
        guard gameState == .playing else {
            isComputerThinking = false; return
        }

        let col = bestColumn()
        guard let row = lowestEmpty(column: col) else {
            isComputerThinking = false; return
        }

        place(player: .computer, row: row, col: col)
        isComputerThinking = false

        if let cells = checkWin(for: .computer) {
            winningCells = cells
            gameState = .won(.computer)
            computerWins += 1
            return
        }
        if isFull() {
            gameState = .draw
            draws += 1
            return
        }

        currentTurn = .human
    }

    private func bestColumn() -> Int {
        let cols = Connect4Engine.columns

        // Win immediately
        for c in 0..<cols {
            if let r = lowestEmpty(column: c) {
                var b = board; b[r][c] = .computer
                if checkWin(for: .computer, on: b) != nil {
                    return c
                }
            }
        }
        // Block human win
        for c in 0..<cols {
            if let r = lowestEmpty(column: c) {
                var b = board; b[r][c] = .human
                if checkWin(for: .human, on: b) != nil {
                    return c
                }
            }
        }

        // Negamax
        var bestScore = Int.min
        var bestCol = cols / 2

        let order = columnOrder()
        for c in order {
            if let r = lowestEmpty(column: c) {
                var b = board; b[r][c] = .computer
                let score = -negamax(board: b, depth: 5, alpha: Int.min + 1, beta: Int.max, player: .human)
                if score > bestScore {
                    bestScore = score; bestCol = c
                }
            }
        }
        return bestCol
    }

    private func negamax(board: [[C4Player?]], depth: Int, alpha: Int, beta: Int, player: C4Player) -> Int {
        let opp: C4Player = player == .human ? .computer : .human

        if checkWin(for: opp, on: board) != nil {
            return 1000 + depth
        }
        if depth == 0 || isFull(board: board) {
            return evaluate(board: board, for: opp)
        }

        var a = alpha
        for c in columnOrder() {
            if let r = lowestEmpty(column: c, board: board) {
                var b = board; b[r][c] = player
                let score = -negamax(board: b, depth: depth - 1, alpha: -beta, beta: -a, player: opp)
                if score > a {
                    a = score
                }
                if a >= beta {
                    break
                }
            }
        }
        return a
    }

    /// Heuristic: count runs of 2 and 3 for each player
    private func evaluate(board: [[C4Player?]], for player: C4Player) -> Int {
        let opp: C4Player = player == .human ? .computer : .human
        var score = 0
        score += countWindows(of: player, length: 3, board: board) * 5
        score += countWindows(of: player, length: 2, board: board) * 2
        score -= countWindows(of: opp, length: 3, board: board) * 4
        // Center column bonus
        let center = Connect4Engine.columns / 2
        let centerCount = (0..<Connect4Engine.rows).filter { board[$0][center] == player }.count
        score += centerCount * 3
        return score
    }

    private func countWindows(of player: C4Player, length: Int, board: [[C4Player?]]) -> Int {
        var count = 0
        let R = Connect4Engine.rows
        let C = Connect4Engine.columns
        let dirs = [(0, 1), (1, 0), (1, 1), (1, -1)]
        for r in 0..<R {
            for c in 0..<C {
                for (dr, dc) in dirs {
                    var pieces = 0
                    var empties = 0
                    for k in 0..<4 {
                        let nr = r + k*dr
                        let nc = c + k*dc
                        guard nr >= 0, nr < R, nc >= 0, nc < C else {
                            pieces = -1; break
                        }

                        if board[nr][nc] == player {
                            pieces += 1
                        } else if board[nr][nc] == nil {
                            empties += 1
                        }
                    }
                    if pieces == length, empties == 4 - length {
                        count += 1
                    }
                }
            }
        }
        return count
    }

    private func columnOrder() -> [Int] {
        cachedColumnOrder
    }

    private func lowestEmpty(column: Int, board: [[C4Player?]]) -> Int? {
        for r in stride(from: Connect4Engine.rows - 1, through: 0, by: -1) {
            if board[r][column] == nil {
                return r
            }
        }
        return nil
    }

    private func isFull() -> Bool {
        isFull(board: board)
    }

    private func isFull(board: [[C4Player?]]) -> Bool {
        board[0].allSatisfy { $0 != nil }
    }

    private func checkWin(for player: C4Player, on board: [[C4Player?]]) -> [[Int]]? {
        let R = Connect4Engine.rows
        let C = Connect4Engine.columns
        let dirs = [(0, 1), (1, 0), (1, 1), (1, -1)]
        for r in 0..<R {
            for c in 0..<C {
                for (dr, dc) in dirs {
                    var cells = [[Int]]()
                    for k in 0..<4 {
                        let nr = r + k*dr
                        let nc = c + k*dc
                        guard nr >= 0, nr < R, nc >= 0, nc < C else {
                            break
                        }

                        if board[nr][nc] == player {
                            cells.append([nr, nc])
                        } else {
                            break
                        }
                    }
                    if cells.count == 4 {
                        return cells
                    }
                }
            }
        }
        return nil
    }
}

struct GameConnect4View: View {
    // MARK: Internal

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Score bar
                HStack(spacing: 12) {
                    ScoreC4Pill(label: "You", value: engine.playerWins, color: C4Player.human.color)
                    ScoreC4Pill(label: "Draws", value: engine.draws, color: .gray)
                    ScoreC4Pill(label: "CPU", value: engine.computerWins, color: C4Player.computer.color)
                }
                .padding(.horizontal)

                // Status banner
                statusBanner

                // Board + column tap targets
                boardSection

                Spacer(minLength: 0)
            }
            .padding(.vertical)
            .navigationTitle("Connect 4")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            engine.reset()
                        }
                    } label: {
                        Label("New Game", systemImage: "arrow.clockwise")
                            .frame(maxWidth: .infinity)
                            .background(Color.accentColor)
                            .foregroundStyle(.white)
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    MCCancelButton { dismiss() }
                }
            }
        }
    }

    // MARK: Private

    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    @StateObject private var engine: Connect4Engine = .init()

    private var statusBanner: some View {
        Group {
            switch engine.gameState {
            case .playing:
                HStack(spacing: 8) {
                    if engine.isComputerThinking {
                        ProgressView().scaleEffect(0.8)
                        Text("CPU is thinking…").foregroundStyle(.secondary)
                    } else {
                        Circle()
                            .fill(engine.currentTurn.color)
                            .frame(width: 12, height: 12)
                            .shadow(color: engine.currentTurn.color.opacity(0.5), radius: 4)
                        Text(engine.currentTurn == .human ? "Your turn — tap a column" : "CPU's turn")
                            .foregroundStyle(.primary)
                    }
                }
                .font(.subheadline.weight(.medium))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule().fill(reduceTransparency ? Color.gray : Color(.systemGray5))
                )

            case let .won(winner):
                Text(winner == .human ? "🎉 You Win!" : "🤖 CPU Wins!")
                    .font(.title3.bold())
                    .foregroundStyle(winner.color)
                    .padding(.horizontal, 20)
.padding(.vertical, 10)
                    .background(Capsule().fill(winner.color.opacity(reduceTransparency ? 1.0 : 0.15)))
                    .transition(.scale.combined(with: .opacity))

            case .draw:
                Text("It's a Draw!")
                    .font(.title3.bold())
                    .foregroundStyle(.orange)
                    .padding(.horizontal, 20)
.padding(.vertical, 10)
                    .background(Capsule().fill(Color.orange.opacity(reduceTransparency ? 1.0 : 0.15)))
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(reduceMotion ? .none : .spring(response: 0.3), value: engine.gameState)
    }

    private var boardSection: some View {
        GeometryReader { proxy in
            let totalW = proxy.size.width - 32 // horizontal padding
            let cellSize = totalW / CGFloat(Connect4Engine.columns)
            let boardH = cellSize * CGFloat(Connect4Engine.rows)

            VStack(spacing: 0) {
                // Column arrow hints (only when it's the human's turn)
                HStack(spacing: 0) {
                    ForEach(0..<Connect4Engine.columns, id: \.self) { col in
                        let canDrop = engine.lowestEmpty(column: col) != nil
                        Image(systemName: "chevron.down")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(
                                engine.hoverColumn == col && canDrop
                                    ? C4Player.human.color
                                    : Color.clear
                            )
                            .frame(width: cellSize, height: 24)
                            .animation(reduceMotion ? .none : .easeInOut(duration: 0.15), value: engine.hoverColumn)
                    }
                }

                // The board itself
                ZStack {
                    // Blue board background
                    RoundedRectangle(cornerRadius: 14)
                        .fill(reduceTransparency ? Color.blue : Color.blue.opacity(0.85))
                        .shadow(color: .blue.opacity(0.3), radius: 8, y: 4)

                    // Cells grid
                    VStack(spacing: 0) {
                        ForEach(0..<Connect4Engine.rows, id: \.self) { row in
                            HStack(spacing: 0) {
                                ForEach(0..<Connect4Engine.columns, id: \.self) { col in
                                    C4CellView(
                                        player: engine.board[row][col],
                                        isWinning: engine.winningCells.contains([row, col]),
                                        isLastDropped: engine.lastDropped.map { $0.row == row && $0.col == col } ?? false,
                                        cellSize: cellSize
                                    )
                                }
                            }
                        }
                    }
                    .padding(6)

                    // Invisible tap columns overlaid on top
                    HStack(spacing: 0) {
                        ForEach(0..<Connect4Engine.columns, id: \.self) { col in
                            Color.clear
                                .frame(width: cellSize)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    guard engine.gameState == .playing,
                                          engine.currentTurn == .human else {
                                              return
                                          }

                                    withAnimation(reduceMotion ? .none : .spring(response: 0.35, dampingFraction: 0.65)) {
                                        engine.humanDrop(column: col)
                                    }
                                }
                                // Hover effect via drag
                                .simultaneousGesture(
                                    DragGesture(minimumDistance: 0)
                                        .onChanged { _ in
                                            if engine.gameState == .playing, engine.currentTurn == .human {
                                                engine.hoverColumn = col
                                            }
                                        }
                                        .onEnded { _ in engine.hoverColumn = nil }
                                )
                                .accessibilityLabel("Column \(col + 1)")
                                .accessibilityHint(engine.lowestEmpty(column: col) != nil ? "Double tap to drop your piece" : "Column is full")
                                .accessibilityAddTraits(.isButton)
                        }
                    }
                }
                .frame(height: boardH)
            }
        }
        .frame(height: CGFloat(Connect4Engine.rows) * ((UIScreen.main.bounds.width - 32) / CGFloat(Connect4Engine.columns)) + 24)
        .padding(.horizontal, 16)
    }
}

private struct C4CellView: View {
    // MARK: Internal

    let player: C4Player?
    let isWinning: Bool
    let isLastDropped: Bool
    let cellSize: CGFloat

    var body: some View {
        ZStack {
            // The disc
            Circle()
                .fill(discColor)
                .shadow(
                    color: player != nil ? player!.color.opacity(0.5) : .clear,
                    radius: isWinning ? 6 : 2
                )
                .scaleEffect(isWinning ? 1.12 : 1.0)
                .animation(
                    reduceMotion ? .none : isWinning
                        ? .spring(response: 0.3).repeatForever(autoreverses: true)
                        : .spring(response: 0.3),
                    value: isWinning
                )

            // Shine highlight
            if player != nil, !reduceTransparency {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [.white.opacity(0.35), .clear],
                            center: .init(x: 0.35, y: 0.3),
                            startRadius: 0,
                            endRadius: cellSize * 0.4
                        )
                    )
            }
        }
        .frame(
            width: cellSize - 10,
            height: cellSize - 10
        )
        .frame(width: cellSize, height: cellSize)
        .transition(
            unsafe reduceMotion
                ? .opacity
                : .asymmetric(
                    insertion: .move(edge: .top).combined(with: .opacity),
                    removal: .opacity
                )
        )
        .accessibilityLabel(player == nil ? "Empty" : (player == .human ? "Your piece" : "CPU piece"))
    }

    // MARK: Private

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    private var discColor: Color {
        guard let player else {
            return reduceTransparency
                ? Color(.systemGray4)
                : Color(.systemBackground).opacity(0.85)
        }

        return player.color
    }
}

private struct ScoreC4Pill: View {
    // MARK: Internal

    let label: String
    let value: Int
    let color: Color

    var body: some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            Text("\(value)")
                .font(.title2.bold())
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(reduceTransparency ? Color.gray : color.opacity(0.1))
        )
    }

    // MARK: Private

    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
}
