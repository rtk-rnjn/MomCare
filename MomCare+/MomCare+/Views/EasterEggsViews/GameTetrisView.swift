import Combine
import SwiftUI

private enum TConst {
    static let cols: Int = 10
    static let rows: Int = 20
    static let cellSize: CGFloat = 32
    static let tickInterval: TimeInterval = 0.5 // seconds per gravity drop
    static let lockDelay: TimeInterval = 0.4 // time before locking after landing
}

enum Tetromino: CaseIterable {
    case I
    case O
    case T
    case S
    case Z
    case J
    case L

    // MARK: Internal

    var color: Color {
        switch self {
        case .I: Color.cyan
        case .O: Color.yellow
        case .T: Color.purple
        case .S: Color.green
        case .Z: Color.red
        case .J: Color.blue
        case .L: Color.orange
        }
    }

    /// All 4 rotation states as arrays of (row, col) offsets from pivot
    var rotations: [[(Int, Int)]] {
        switch self {
        case .I:
            [
                [(0, -1), (0, 0), (0, 1), (0, 2)],
                [(-1, 1), (0, 1), (1, 1), (2, 1)],
                [(1, -1), (1, 0), (1, 1), (1, 2)],
                [(-1, 0), (0, 0), (1, 0), (2, 0)]
            ]

        case .O:
            [
                [(0, 0), (0, 1), (1, 0), (1, 1)],
                [(0, 0), (0, 1), (1, 0), (1, 1)],
                [(0, 0), (0, 1), (1, 0), (1, 1)],
                [(0, 0), (0, 1), (1, 0), (1, 1)]
            ]

        case .T:
            [
                [(0, -1), (0, 0), (0, 1), (-1, 0)],
                [(0, 0), (1, 0), (-1, 0), (0, 1)],
                [(0, -1), (0, 0), (0, 1), (1, 0)],
                [(0, 0), (-1, 0), (1, 0), (0, -1)]
            ]

        case .S:
            [
                [(0, 0), (0, 1), (-1, -1), (-1, 0)], // flat
                [(0, 0), (1, 0), (-1, 1), (0, 1)], // rotated
                [(0, 0), (0, 1), (-1, -1), (-1, 0)],
                [(0, 0), (1, 0), (-1, 1), (0, 1)]
            ]

        case .Z:
            [
                [(0, 0), (0, -1), (-1, 1), (-1, 0)],
                [(0, 0), (1, 0), (-1, -1), (0, -1)],
                [(0, 0), (0, -1), (-1, 1), (-1, 0)],
                [(0, 0), (1, 0), (-1, -1), (0, -1)]
            ]

        case .J:
            [
                [(0, -1), (0, 0), (0, 1), (-1, -1)],
                [(-1, 0), (0, 0), (1, 0), (-1, 1)],
                [(0, -1), (0, 0), (0, 1), (1, 1)],
                [(-1, 0), (0, 0), (1, 0), (1, -1)]
            ]

        case .L:
            [
                [(0, -1), (0, 0), (0, 1), (-1, 1)],
                [(-1, 0), (0, 0), (1, 0), (1, 1)],
                [(0, -1), (0, 0), (0, 1), (1, -1)],
                [(-1, 0), (0, 0), (1, 0), (-1, -1)]
            ]
        }
    }
}

struct ActivePiece {
    var type: Tetromino
    var rotation: Int = 0
    var row: Int
    var col: Int

    var cells: [(Int, Int)] {
        type.rotations[rotation % 4].map { (row + $0.0, col + $0.1) }
    }

    func rotated(by delta: Int = 1) -> ActivePiece {
        var p = self
        p.rotation = (rotation + delta + 4) % 4
        return p
    }

    func moved(dr: Int = 0, dc: Int = 0) -> ActivePiece {
        var p = self
        p.row += dr
        p.col += dc
        return p
    }
}

/// nil = empty, some(Tetromino) = locked colour
typealias Board = [[Tetromino?]]

enum TetrisGameState { case playing, paused, gameOver }

@MainActor
class TetrisEngine: ObservableObject {
    // MARK: Lifecycle

    init() {
        reset()
    }

    // MARK: Internal

    // MARK: Published

    @Published var board: Board = TetrisEngine.emptyBoard()
    @Published var active: ActivePiece?
    @Published var next: Tetromino = .allCases.randomElement()!
    @Published var held: Tetromino?
    @Published var canHold: Bool = true
    @Published var score: Int = 0
    @Published var level: Int = 1
    @Published var lines: Int = 0
    @Published var gameState: TetrisGameState = .playing
    @Published var flashRows: Set<Int> = []
    @Published var highScore: Int = 0

    var ghostPiece: ActivePiece? {
        guard var g = active else {
            return nil
        }

        while isValid(g.moved(dr: 1)) {
            g = g.moved(dr: 1)
        }
        return g.row != active?.row ? g : nil
    }

    func reset() {
        board = TetrisEngine.emptyBoard()
        next = Tetromino.allCases.randomElement()!
        held = nil
        canHold = true
        score = 0
        level = 1
        lines = 0
        gameState = .playing
        flashRows = []
        spawnPiece()
        startTimer()
    }

    func togglePause() {
        switch gameState {
        case .playing:
            gameState = .paused
            stopTimer()

        case .paused:
            gameState = .playing
            startTimer()

        case .gameOver: break
        }
    }

    func moveLeft() {
        tryMove(active?.moved(dc: -1))
    }

    func moveRight() {
        tryMove(active?.moved(dc: 1))
    }

    func rotateRight() {
        tryRotate(by: 1)
    }

    func rotateLeft() {
        tryRotate(by: -1)
    }

    func softDrop() {
        guard gameState == .playing, let p = active else {
            return
        }

        let moved = p.moved(dr: 1)
        if isValid(moved) {
            active = moved
            score += 1
            resetLockTimer()
        } else {
            lockPiece()
        }
    }

    func hardDrop() {
        guard gameState == .playing, var p = active else {
            return
        }

        var dropped = 0
        while isValid(p.moved(dr: 1)) {
            p = p.moved(dr: 1); dropped += 1
        }
        active = p
        score += dropped * 2
        lockPiece()
    }

    func holdPiece() {
        guard gameState == .playing, canHold, let p = active else {
            return
        }

        let old = held
        held = p.type
        canHold = false
        if let old {
            active = spawnActive(type: old)
            if !isValid(active!) {
                endGame(); return
            }
        } else {
            spawnPiece()
        }
    }

    // MARK: Private

    private var timer: AnyCancellable?
    private var lockTimer: AnyCancellable?
    private var bag: [Tetromino] = []

    private static func emptyBoard() -> Board {
        Array(repeating: Array(repeating: nil, count: TConst.cols), count: TConst.rows)
    }

    private func tickInterval() -> TimeInterval {
        max(0.05, TConst.tickInterval - Double(level - 1) * 0.04)
    }

    private func startTimer() {
        timer?.cancel()
        timer = Timer.publish(every: tickInterval(), on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in self?.tick() }
    }

    private func stopTimer() {
        timer?.cancel(); lockTimer?.cancel()
    }

    private func tick() {
        guard gameState == .playing, let p = active else {
            return
        }

        let moved = p.moved(dr: 1)
        if isValid(moved) {
            active = moved
        } else {
            scheduleLock()
        }
    }

    private func scheduleLock() {
        guard lockTimer == nil else {
            return
        }

        lockTimer = Timer.publish(every: TConst.lockDelay, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else {
                    return
                }
                guard let p = active, !self.isValid(p.moved(dr: 1)) else {
                    lockTimer?.cancel(); lockTimer = nil; return
                }

                lockPiece()
            }
    }

    private func resetLockTimer() {
        lockTimer?.cancel(); lockTimer = nil
    }

    private func lockPiece() {
        lockTimer?.cancel(); lockTimer = nil
        guard let p = active else {
            return
        }

        // Write to board
        for (r, c) in p.cells where (0..<TConst.rows).contains(r) && (0..<TConst.cols).contains(c) {
            board[r][c] = p.type
        }

        clearLines()
        canHold = true
        spawnPiece()
    }

    private func clearLines() {
        let full = (0..<TConst.rows).filter { board[$0].allSatisfy { $0 != nil } }
        guard !full.isEmpty else {
            return
        }

        flashRows = Set(full)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in
            guard let self else {
                return
            }

            flashRows = []
            var newBoard = board.filter { !$0.allSatisfy { $0 != nil } }
            let cleared = TConst.rows - newBoard.count
            newBoard.insert(contentsOf: (0..<cleared).map { _ in Array(repeating: nil, count: TConst.cols) }, at: 0)
            board = newBoard

            let pts = [0, 100, 300, 500, 800][min(cleared, 4)] * level
            score += pts
            lines += cleared
            level = lines / 10 + 1
            startTimer() // re-sync speed after level change
        }
    }

    private func spawnPiece() {
        active = spawnActive(type: next)
        next = drawFromBag()
        if let a = active, !isValid(a) {
            endGame()
        }
    }

    private func spawnActive(type: Tetromino) -> ActivePiece {
        ActivePiece(type: type, rotation: 0,
                    row: 1, col: TConst.cols / 2)
    }

    private func drawFromBag() -> Tetromino {
        if bag.isEmpty {
            bag = Tetromino.allCases.shuffled()
        }
        return bag.removeFirst()
    }

    private func tryMove(_ candidate: ActivePiece?) {
        guard gameState == .playing, let c = candidate, isValid(c) else {
            return
        }

        active = c
        resetLockTimer()
    }

    private func tryRotate(by delta: Int) {
        guard gameState == .playing, let p = active else {
            return
        }

        var candidate = p.rotated(by: delta)
        // Wall kick attempts: 0, ±1, ±2
        let kicks = [0, 1, -1, 2, -2]
        for kick in kicks {
            candidate.col = p.col + kick
            if isValid(candidate) {
                active = candidate; resetLockTimer(); return
            }
        }
    }

    private func isValid(_ piece: ActivePiece) -> Bool {
        piece.cells.allSatisfy { r, c in
            c >= 0 && c < TConst.cols &&
            r < TConst.rows &&
            (r < 0 || board[r][c] == nil)
        }
    }

    private func endGame() {
        stopTimer()
        gameState = .gameOver
        if score > highScore {
            highScore = score
        }
    }
}

struct GameTetrisView: View {
    // MARK: Internal

    var body: some View {
        NavigationStack {
            HStack(alignment: .top, spacing: 12) {
                // Left sidebar
                leftPanel

                // Board
                boardView
                    .layoutPriority(1)

                // Right sidebar
                rightPanel
            }
            .padding(.horizontal, 10)
            .padding(.top, 8)
            .navigationTitle("Tetris")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    MCCancelButton { dismiss() }
                }
                ToolbarItem(placement: .bottomBar) {
                    Button {
                        withAnimation(.spring(response: 0.3)) { engine.reset() }
                    } label: {
                        Label("New Game", systemImage: "arrow.clockwise")
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(.white)
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        engine.togglePause()
                    } label: {
                        Image(systemName: engine.gameState == .paused ? "play.fill" : "pause.fill")
                    }
                }
            }
            .overlay {
                if engine.gameState == .gameOver {
                    gameOverOverlay
                }
                if engine.gameState == .paused {
                    pauseOverlay
                }
            }
        }
    }

    // MARK: Private

    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    @StateObject private var engine: TetrisEngine = .init()

    // Gesture state
    @State private var dragStart: CGPoint = .zero
    @State private var lastHorizontalMove: Int = 0 // track cells moved in current drag
    @State private var dragStartTime: Date = .init()
    @State private var didHardDrop: Bool = false

    // Swipe thresholds
    private let horizontalThreshold: CGFloat = TConst.cellSize * 0.6
    private let swipeDownThreshold: CGFloat = 60

    private var boardGesture: some Gesture {
        DragGesture(minimumDistance: 4)
            .onChanged { v in
                let dx = v.location.x - dragStart.x
                let dy = v.location.y - dragStart.y

                // First assignment
                if dragStart == .zero {
                    dragStart = v.startLocation
                    dragStartTime = Date()
                    lastHorizontalMove = 0
                    didHardDrop = false
                }

                // Hard drop: fast swipe down
                let elapsed = Date().timeIntervalSince(dragStartTime)
                if dy > swipeDownThreshold, abs(dx) < 40, elapsed < 0.25, !didHardDrop {
                    didHardDrop = true
                    engine.hardDrop()
                    return
                }

                // Horizontal slide: move once per cell
                let targetMove = Int(dx / horizontalThreshold)
                let delta = targetMove - lastHorizontalMove
                if delta != 0 {
                    for _ in 0..<abs(delta) {
                        if delta > 0 {
                            engine.moveRight()
                        } else {
                            engine.moveLeft()
                        }
                    }
                    lastHorizontalMove = targetMove
                }
            }
            .onEnded { v in
                let dx = v.translation.width
                let dy = v.translation.height
                let elapsed = Date().timeIntervalSince(dragStartTime)

                // If barely moved → tap → rotate
                if abs(dx) < 12, abs(dy) < 12 {
                    engine.rotateRight()
                }

                // Soft-down flick (slow downward drag that didn't trigger hard drop)
                if dy > 30, abs(dx) < 50, elapsed > 0.25 {
                    engine.softDrop()
                }

                dragStart = .zero
                lastHorizontalMove = 0
                didHardDrop = false
            }
    }

    private var boardView: some View {
        let cs = TConst.cellSize
        let w = cs * CGFloat(TConst.cols)
        let h = cs * CGFloat(TConst.rows)

        return Canvas { ctx, _ in
            // Locked cells
            for r in 0..<TConst.rows {
                for c in 0..<TConst.cols {
                    let rect = CGRect(x: CGFloat(c)*cs, y: CGFloat(r)*cs, width: cs, height: cs)
                    if let t = engine.board[r][c] {
                        let isFlash = engine.flashRows.contains(r)
                        ctx.fill(Path(roundedRect: rect.insetBy(dx: 1, dy: 1), cornerRadius: 3),
                                 with: .color(isFlash ? .white : t.color))
                    } else {
                        ctx.fill(Path(roundedRect: rect.insetBy(dx: 0.5, dy: 0.5), cornerRadius: 2),
                                 with: .color(reduceTransparency
                                              ? Color(.systemGray5)
                                              : Color(.systemGray6).opacity(0.6)))
                    }
                }
            }

            // Ghost
            if let ghost = engine.ghostPiece {
                for (r, c) in ghost.cells where r >= 0 {
                    let rect = CGRect(x: CGFloat(c)*cs, y: CGFloat(r)*cs, width: cs, height: cs)
                    ctx.stroke(Path(roundedRect: rect.insetBy(dx: 2, dy: 2), cornerRadius: 3),
                               with: .color(engine.active?.type.color.opacity(0.4) ?? .gray),
                               lineWidth: 1.5)
                }
            }

            // Active piece
            if let piece = engine.active {
                for (r, c) in piece.cells where r >= 0 {
                    let rect = CGRect(x: CGFloat(c)*cs, y: CGFloat(r)*cs, width: cs, height: cs)
                    ctx.fill(Path(roundedRect: rect.insetBy(dx: 1, dy: 1), cornerRadius: 3),
                             with: .color(piece.type.color))
                    // Shine
                    ctx.fill(Path(roundedRect: CGRect(x: CGFloat(c)*cs+3, y: CGFloat(r)*cs+3,
                                                      width: cs*0.4, height: cs*0.25)
                                    .insetBy(dx: 0, dy: 0),
                                  cornerRadius: 2),
                             with: .color(.white.opacity(reduceTransparency ? 0 : 0.35)))
                }
            }

            // Border
            ctx.stroke(Path(CGRect(x: 0, y: 0, width: w, height: h)),
                       with: .color(Color(.systemGray3)), lineWidth: 1)
        }
        .frame(width: w, height: h)
        .background(reduceTransparency ? Color(.systemGray5) : Color(.systemGray6).opacity(0.4))
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.12), radius: 6, y: 3)
        .gesture(boardGesture)
        .accessibilityLabel("Tetris board")
        .accessibilityHint("Swipe left and right to move, swipe down to hard drop, tap to rotate right, long press to hold")
    }

    private var leftPanel: some View {
        VStack(spacing: 16) {
            miniPanel(title: "HOLD") {
                MiniPieceView(type: engine.held, dimmed: !engine.canHold)
            }

            Spacer()

            // Rotate left button
            Button { engine.rotateLeft() } label: {
                Image(systemName: "rotate.left.fill")
                    .font(.title2)
                    .padding(10)
                    .background(Circle().fill(Color(.systemGray5)))
            }
        }
        .frame(width: 64)
    }

    private var rightPanel: some View {
        VStack(spacing: 16) {
            miniPanel(title: "NEXT") {
                MiniPieceView(type: engine.next, dimmed: false)
            }

            Divider()

            VStack(spacing: 8) {
                statRow(label: "SCORE", value: "\(engine.score)")
                statRow(label: "BEST", value: "\(engine.highScore)")
                statRow(label: "LEVEL", value: "\(engine.level)")
                statRow(label: "LINES", value: "\(engine.lines)")
            }
            .font(.system(size: 11, weight: .semibold, design: .monospaced))

            Spacer()

            // Rotate right button
            Button { engine.rotateRight() } label: {
                Image(systemName: "rotate.right.fill")
                    .font(.title2)
                    .padding(10)
                    .background(Circle().fill(Color(.systemGray5)))
            }
        }
        .frame(width: 72)
    }

    private var gameOverOverlay: some View {
        VStack(spacing: 14) {
            Text("GAME OVER")
                .font(.system(size: 22, weight: .black, design: .monospaced))
                .foregroundStyle(.red)
            Text("Score: \(engine.score)")
                .font(.system(size: 15, weight: .bold, design: .monospaced))
            if engine.score >= engine.highScore, engine.score > 0 {
                Text("🏆 New Best!")
                    .font(.subheadline.bold())
                    .foregroundStyle(.yellow)
            }
            Button("Play Again") {
                withAnimation(.spring(response: 0.3)) { engine.reset() }
            }
            .buttonStyle(.borderedProminent)
            .tint(.red)
        }
        .padding(28)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(.systemBackground).opacity(0.96))
                .shadow(color: .black.opacity(0.2), radius: 16, y: 6)
        )
        .transition(.scale.combined(with: .opacity))
    }

    private var pauseOverlay: some View {
        VStack(spacing: 12) {
            Text("PAUSED")
                .font(.system(size: 22, weight: .black, design: .monospaced))
            Button("Resume") { engine.togglePause() }
                .buttonStyle(.borderedProminent)
        }
        .padding(28)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(.systemBackground).opacity(0.96))
                .shadow(color: .black.opacity(0.15), radius: 12)
        )
        .transition(.opacity)
    }

    private func miniPanel<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(spacing: 6) {
            Text(title)
                .font(.system(size: 9, weight: .black, design: .monospaced))
                .foregroundStyle(.secondary)
            content()
                .frame(width: 56, height: 44)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(reduceTransparency ? Color(.systemGray4) : Color(.systemGray5).opacity(0.7))
                )
        }
    }

    private func statRow(label: String, value: String) -> some View {
        VStack(spacing: 1) {
            Text(label).foregroundStyle(.secondary).font(.system(size: 9, weight: .bold, design: .monospaced))
            Text(value).foregroundStyle(.primary).font(.system(size: 13, weight: .black, design: .monospaced))
        }
    }
}

private struct MiniPieceView: View {
    let type: Tetromino?
    let dimmed: Bool

    var body: some View {
        Canvas { ctx, size in
            guard let t = type else {
                return
            }

            let cells = t.rotations[0]
            let cs: CGFloat = 10
            // Center the 4 cells
            let minR = cells.map(\.0).min()!
            let maxR = cells.map(\.0).max()!
            let minC = cells.map(\.1).min()!
            let maxC = cells.map(\.1).max()!
            let pieceW = CGFloat(maxC - minC + 1) * cs
            let pieceH = CGFloat(maxR - minR + 1) * cs
            let ox = (size.width - pieceW) / 2 - CGFloat(minC) * cs
            let oy = (size.height - pieceH) / 2 - CGFloat(minR) * cs

            for (r, c) in cells {
                let rect = CGRect(x: ox + CGFloat(c)*cs, y: oy + CGFloat(r)*cs, width: cs, height: cs)
                ctx.fill(Path(roundedRect: rect.insetBy(dx: 1, dy: 1), cornerRadius: 2),
                         with: .color(t.color.opacity(dimmed ? 0.3 : 1.0)))
            }
        }
    }
}
