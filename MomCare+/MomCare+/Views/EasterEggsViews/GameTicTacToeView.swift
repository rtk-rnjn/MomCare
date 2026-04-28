import Combine
import SwiftUI

enum TTTPlayer {
    case human
    case computer

    // MARK: Internal

    var mark: String {
        switch self {
        case .human: "X"
        case .computer: "O"
        }
    }

    var color: Color {
        switch self {
        case .human: .blue
        case .computer: .red
        }
    }
}

enum TTTGameState: Equatable {
    case playing
    case won(TTTPlayer)
    case draw
}

@MainActor
class TicTacToeEngine: ObservableObject {
    // MARK: Lifecycle

    init() {
        reset()
    }

    // MARK: Internal

    @Published var board: [TTTPlayer?] = Array(repeating: nil, count: 9)
    @Published var gameState: TTTGameState = .playing
    @Published var currentTurn: TTTPlayer = .human
    @Published var winningLine: [Int]?
    @Published var playerWins: Int = 0
    @Published var computerWins: Int = 0
    @Published var draws: Int = 0
    @Published var isComputerThinking: Bool = false

    func reset() {
        board = Array(repeating: nil, count: 9)
        gameState = .playing
        currentTurn = .human
        winningLine = nil
        isComputerThinking = false
    }

    func humanTap(at index: Int) {
        guard gameState == .playing,
              currentTurn == .human,
              board[index] == nil,
              !isComputerThinking else {
                  return
              }

        board[index] = .human

        if let line = checkWin(for: .human) {
            winningLine = line
            gameState = .won(.human)
            playerWins += 1
            return
        }
        if isBoardFull() {
            gameState = .draw
            draws += 1
            return
        }

        currentTurn = .computer
        isComputerThinking = true

        Task {
            // Small delay so the computer "thinks"
            try? await Task.sleep(nanoseconds: 450_000_000)
            computerMove()
        }
    }

    // MARK: Private

    private let winLines: [[Int]] = [
        [0, 1, 2], [3, 4, 5], [6, 7, 8], // rows
        [0, 3, 6], [1, 4, 7], [2, 5, 8], // cols
        [0, 4, 8], [2, 4, 6] // diagonals
    ]

    private func computerMove() {
        guard gameState == .playing else {
            isComputerThinking = false
            return
        }

        let move = bestMove()
        board[move] = .computer
        isComputerThinking = false

        if let line = checkWin(for: .computer) {
            winningLine = line
            gameState = .won(.computer)
            computerWins += 1
            return
        }
        if isBoardFull() {
            gameState = .draw
            draws += 1
            return
        }

        currentTurn = .human
    }

    // Minimax AI
    private func bestMove() -> Int {
        var bestScore = Int.min
        var bestIndex = -1
        var localBoard = board

        for i in 0..<9 where localBoard[i] == nil {
            localBoard[i] = .computer
            let score = minimax(board: localBoard, depth: 0, isMaximizing: false)
            localBoard[i] = nil
            if score > bestScore {
                bestScore = score
                bestIndex = i
            }
        }
        return bestIndex
    }

    private func minimax(board: [TTTPlayer?], depth: Int, isMaximizing: Bool) -> Int {
        if checkWin(for: .computer, in: board) != nil {
            return 10 - depth
        }
        if checkWin(for: .human, in: board) != nil {
            return depth - 10
        }
        if board.allSatisfy({ $0 != nil }) {
            return 0
        }

        var localBoard = board

        if isMaximizing {
            var best = Int.min
            for i in 0..<9 where localBoard[i] == nil {
                localBoard[i] = .computer
                best = max(best, minimax(board: localBoard, depth: depth + 1, isMaximizing: false))
                localBoard[i] = nil
            }
            return best
        } else {
            var best = Int.max
            for i in 0..<9 where localBoard[i] == nil {
                localBoard[i] = .human
                best = min(best, minimax(board: localBoard, depth: depth + 1, isMaximizing: true))
                localBoard[i] = nil
            }
            return best
        }
    }

    private func checkWin(for player: TTTPlayer) -> [Int]? {
        checkWin(for: player, in: board)
    }

    private func checkWin(for player: TTTPlayer, in board: [TTTPlayer?]) -> [Int]? {
        for line in winLines where line.allSatisfy({ board[$0] == player }) {
            return line
        }
        return nil
    }

    private func isBoardFull() -> Bool {
        board.allSatisfy { $0 != nil }
    }
}

struct GameTicTacToeView: View {
    // MARK: Internal

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Score bar
                HStack(spacing: 16) {
                    ScorePill(label: "You", value: engine.playerWins, color: TTTPlayer.human.color)
                    ScorePill(label: "Draws", value: engine.draws, color: .gray)
                    ScorePill(label: "CPU", value: engine.computerWins, color: TTTPlayer.computer.color)
                }

                // Status banner
                statusBanner

                // Board
                boardView
                    .padding(.horizontal)
            }
            .padding(.vertical)
            .navigationTitle("Tic Tac Toe")
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

    @StateObject private var engine: TicTacToeEngine = .init()

    private var statusBanner: some View {
        Group {
            switch engine.gameState {
            case .playing:
                HStack(spacing: 8) {
                    if engine.isComputerThinking {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("CPU is thinking…")
                            .foregroundStyle(.secondary)
                    } else {
                        Circle()
                            .fill(engine.currentTurn.color)
                            .frame(width: 12, height: 12)
                        Text(engine.currentTurn == .human ? "Your turn" : "CPU's turn")
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
                    .background(
                        Capsule().fill(winner.color.opacity(reduceTransparency ? 1.0 : 0.15))
                    )
                    .transition(.scale.combined(with: .opacity))

            case .draw:
                Text("It's a Draw!")
                    .font(.title3.bold())
                    .foregroundStyle(.orange)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        Capsule().fill(Color.orange.opacity(reduceTransparency ? 1.0 : 0.15))
                    )
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(reduceMotion ? .none : .spring(response: 0.3), value: engine.gameState)
    }

    private var boardView: some View {
        GeometryReader { proxy in
            let size = proxy.size.width
            let cellSize = (size - 4) / 3 // 2 dividers of 2pt each

            VStack(spacing: 0) {
                ForEach(0..<3, id: \.self) { row in
                    HStack(spacing: 0) {
                        ForEach(0..<3, id: \.self) { col in
                            let index = row * 3 + col
                            TTTCellView(
                                player: engine.board[index],
                                isWinningCell: engine.winningLine?.contains(index) ?? false,
                                size: cellSize
                            )
                            .onTapGesture {
                                withAnimation(reduceMotion ? .none : .spring(response: 0.25, dampingFraction: 0.6)) {
                                    engine.humanTap(at: index)
                                }
                            }

                            if col < 2 {
                                Rectangle()
                                    .fill(Color(.systemGray3))
                                    .frame(width: 2, height: cellSize)
                            }
                        }
                    }

                    if row < 2 {
                        Rectangle()
                            .fill(Color(.systemGray3))
                            .frame(height: 2)
                    }
                }
            }
            .background(reduceTransparency ? Color.gray : Color(.systemGray5).opacity(0.5))
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.06), radius: 8, y: 4)
            .accessibilityElement(children: .contain)
        }
        .aspectRatio(1, contentMode: .fit)
        .padding(.horizontal)
    }
}

private struct TTTCellView: View {
    // MARK: Internal

    let player: TTTPlayer?
    let isWinningCell: Bool
    let size: CGFloat

    var body: some View {
        ZStack {
            Rectangle()
                .fill(
                    isWinningCell
                        ? (player?.color ?? .clear).opacity(reduceTransparency ? 0.5 : 0.18)
                        : Color.clear
                )
                .animation(reduceMotion ? .none : .easeInOut(duration: 0.25), value: isWinningCell)

            if let player {
                Text(player.mark)
                    .font(.system(size: size * 0.42, weight: .bold, design: .rounded))
                    .foregroundStyle(player.color)
                    .scaleEffect(isWinningCell ? 1.15 : 1.0)
                    .animation(reduceMotion ? .none : .spring(response: 0.3), value: isWinningCell)
                    .transition(unsafe reduceMotion ? .opacity : .scale.combined(with: .opacity))
            }
        }
        .frame(width: size, height: size)
        .contentShape(Rectangle())
        .accessibilityLabel(player?.mark ?? "Empty")
        .accessibilityHint(player == nil ? "Double tap to place your mark" : "")
        .accessibilityAddTraits(player == nil ? .isButton : [])
    }

    // MARK: Private

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
}

private struct ScorePill: View {
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
