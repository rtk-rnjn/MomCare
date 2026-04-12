import Combine
import SwiftUI

private enum SudokuConst {
    static let size: Int = 9
    static let boxSize: Int = 3
}

enum SudokuDifficulty: String, CaseIterable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
    case expert = "Expert"

    // MARK: Internal

    var clues: Int {
        switch self {
        case .easy: 38
        case .medium: 30
        case .hard: 25
        case .expert: 22
        }
    }
}

struct SudokuCell {
    var value: Int // 0 = empty
    var isGiven: Bool
    var notes: Set<Int> // pencil marks 1-9
    var isError: Bool
}

struct SudokuMove {
    let row: Int
    let col: Int
    let before: SudokuCell
    let after: SudokuCell
}

enum SudokuGenerator {
    // MARK: Internal

    // Full solved grid via backtracking + shuffle
    static func makeSolved() -> [[Int]] {
        var grid = Array(repeating: Array(repeating: 0, count: 9), count: 9)
        _ = solve(&grid, shuffle: true)
        return grid
    }

    // Dig holes to reach target clue count
    static func makePuzzle(difficulty: SudokuDifficulty) -> (puzzle: [[Int]], solution: [[Int]]) {
        let solution = makeSolved()
        var puzzle = solution

        let positions = (0..<81).map { ($0 / 9, $0 % 9) }.shuffled()
        var removed = 0
        let target = 81 - difficulty.clues

        for (r, c) in positions {
            if removed >= target {
                break
            }
            let backup = puzzle[r][c]
            puzzle[r][c] = 0
            var copy = puzzle
            if countSolutions(&copy) == 1 {
                removed += 1
            } else {
                puzzle[r][c] = backup
            }
        }
        return (puzzle, solution)
    }

    @discardableResult
    static func solve(_ grid: inout [[Int]], shuffle: Bool = false) -> Bool {
        guard let (r, c) = firstEmpty(grid) else {
            return true
        }

        var digits = Array(1...9)
        if shuffle {
            digits.shuffle()
        }
        for d in digits {
            if isLegal(grid, row: r, col: c, val: d) {
                grid[r][c] = d
                if solve(&grid, shuffle: shuffle) {
                    return true
                }
                grid[r][c] = 0
            }
        }
        return false
    }

    static func isLegal(_ grid: [[Int]], row: Int, col: Int, val: Int) -> Bool {
        // Row
        if grid[row].contains(val) {
            return false
        }
        // Col
        if (0..<9).map({ grid[$0][col] }).contains(val) {
            return false
        }
        // Box
        let br = (row / 3) * 3
        let bc = (col / 3) * 3
        for r in br..<br+3 {
            for c in bc..<bc+3 {
                if grid[r][c] == val {
            return false
        } } }
        return true
    }

    // MARK: Private

    // Count solutions (cap at 2 for uniqueness check)
    private static func countSolutions(_ grid: inout [[Int]], limit: Int = 2) -> Int {
        guard let (r, c) = firstEmpty(grid) else {
            return 1
        }

        var count = 0
        for d in 1...9 {
            if isLegal(grid, row: r, col: c, val: d) {
                grid[r][c] = d
                count += countSolutions(&grid, limit: limit)
                grid[r][c] = 0
                if count >= limit {
                    return count
                }
            }
        }
        return count
    }

    private static func firstEmpty(_ grid: [[Int]]) -> (Int, Int)? {
        for r in 0..<9 {
            for c in 0..<9 {
                if grid[r][c] == 0 {
            return (r, c)
        } } }
        return nil
    }
}

@MainActor
class SudokuEngine: ObservableObject {
    // MARK: Lifecycle

    init() {
        newGame(difficulty: .medium)
    }

    // MARK: Internal

    // MARK: Published

    @Published var cells: [[SudokuCell]] = []
    @Published var solution: [[Int]] = []
    @Published var selected: (Int, Int)?
    @Published var isNoteMode: Bool = false
    @Published var isSolved: Bool = false
    @Published var mistakes: Int = 0
    @Published var difficulty: SudokuDifficulty = .medium
    @Published var isGenerating: Bool = false
    @Published var elapsedSeconds: Int = 0
    @Published var hintsUsed: Int = 0

    func newGame(difficulty: SudokuDifficulty) {
        self.difficulty = difficulty
        isSolved = false
        mistakes = 0
        hintsUsed = 0
        elapsedSeconds = 0
        selected = nil
        isGenerating = true
        undoStack = []
        stopTimer()

        Task.detached(priority: .userInitiated) {
            let (puzzle, sol) = SudokuGenerator.makePuzzle(difficulty: difficulty)
            await MainActor.run {
                self.solution = sol
                self.cells = puzzle.map { row in
                    row.map { v in SudokuCell(value: v, isGiven: v != 0, notes: [], isError: false) }
                }
                self.isGenerating = false
                self.startTimer()
            }
        }
    }

    func select(row: Int, col: Int) {
        if selected?.0 == row, selected?.1 == col {
            selected = nil
        } else {
            selected = (row, col)
        }
    }

    func enterDigit(_ d: Int) {
        guard let (r, c) = selected,
              !cells[r][c].isGiven,
              !isSolved else {
                  return
              }

        let before = cells[r][c]

        if isNoteMode {
            var cell = cells[r][c]
            cell.value = 0
            if cell.notes.contains(d) {
                cell.notes.remove(d)
            } else {
                cell.notes.insert(d)
            }
            cell.isError = false
            cells[r][c] = cell
        } else {
            var cell = cells[r][c]
            if cell.value == d {
                cell.value = 0; cell.isError = false
            } else {
                cell.value = d
                cell.notes = []
                cell.isError = (solution[r][c] != d)
                if cell.isError {
                    mistakes += 1
                }
                // Remove matching notes from peers
                if !cell.isError {
                    clearPeerNotes(row: r, col: c, digit: d)
                }
            }
            cells[r][c] = cell
        }

        undoStack.append(SudokuMove(row: r, col: c, before: before, after: cells[r][c]))
        checkSolved()
    }

    func erase() {
        guard let (r, c) = selected, !cells[r][c].isGiven, !isSolved else {
            return
        }

        let before = cells[r][c]
        cells[r][c].value = 0
        cells[r][c].notes = []
        cells[r][c].isError = false
        undoStack.append(SudokuMove(row: r, col: c, before: before, after: cells[r][c]))
    }

    func undo() {
        guard let move = undoStack.popLast() else {
            return
        }

        cells[move.row][move.col] = move.before
        selected = (move.row, move.col)
    }

    func hint() {
        // Find first empty or wrong cell, fill with solution
        let target: (Int, Int)? = if let (sr, sc) = selected, !cells[sr][sc].isGiven,
           cells[sr][sc].value == 0 || cells[sr][sc].isError {
            (sr, sc)
        } else {
            (0..<9)
.flatMap { r in (0..<9).map { (r, $0) } }
                .filter { !cells[$0.0][$0.1].isGiven && (cells[$0.0][$0.1].value == 0 || cells[$0.0][$0.1].isError) }
                .first
        }
        guard let (r, c) = target else {
            return
        }

        let before = cells[r][c]
        cells[r][c].value = solution[r][c]
        cells[r][c].notes = []
        cells[r][c].isError = false
        cells[r][c].isGiven = true // treat hinted as given so it can't be erased
        undoStack.append(SudokuMove(row: r, col: c, before: before, after: cells[r][c]))
        selected = (r, c)
        hintsUsed += 1
        clearPeerNotes(row: r, col: c, digit: solution[r][c])
        checkSolved()
    }

    func highlightState(row: Int, col: Int) -> CellHighlight {
        guard let (sr, sc) = selected else {
            return .none
        }

        if row == sr && col == sc {
            return .selected
        }

        let selVal = cells[sr][sc].value
        let curVal = cells[row][col].value

        // Same value highlight
        if selVal != 0 && curVal == selVal {
            return .sameValue
        }

        // Peer (same row / col / box)
        if row == sr || col == sc {
            return .peer
        }
        let br = (row / 3) * 3 == (sr / 3) * 3
        let bc = (col / 3) * 3 == (sc / 3) * 3
        if br, bc {
            return .peer
        }

        return .none
    }

    // MARK: Private

    private var undoStack: [SudokuMove] = []
    private var timerCancellable: AnyCancellable?

    private func startTimer() {
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self, !self.isSolved else {
                    return
                }

                elapsedSeconds += 1
            }
    }

    private func stopTimer() {
        timerCancellable?.cancel()
    }

    private func clearPeerNotes(row: Int, col: Int, digit: Int) {
        for r in 0..<9 {
            cells[r][col].notes.remove(digit)
        }
        for c in 0..<9 {
            cells[row][c].notes.remove(digit)
        }
        let br = (row / 3) * 3
        let bc = (col / 3) * 3
        for r in br..<br+3 {
            for c in bc..<bc+3 {
                cells[r][c].notes.remove(digit)
            }
        }
    }

    private func checkSolved() {
        let solved = (0..<9).allSatisfy { r in
            (0..<9).allSatisfy { c in cells[r][c].value == solution[r][c] }
        }
        if solved {
            isSolved = true
            stopTimer()
        }
    }
}

enum CellHighlight { case none, peer, sameValue, selected }

struct GameSudokuView: View {
    // MARK: Internal

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // HUD
                hudBar

                if engine.isGenerating {
                    Spacer()
                    ProgressView("Generating puzzle…")
                        .font(.subheadline)
                    Spacer()
                } else {
                    // Grid
                    gridView
                        .padding(.horizontal, 12)

                    // Number pad
                    numberPad

                    // Action row
                    actionRow
                }
            }
            .padding(.bottom, 8)
            .navigationTitle("Sudoku")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    MCCancelButton { dismiss() }
                }
                ToolbarItem(placement: .bottomBar) {
                    Menu {
                        ForEach(SudokuDifficulty.allCases, id: \.self) { d in
                            Button(d.rawValue) {
                                engine.newGame(difficulty: d)
                            }
                        }
                    } label: {
                        Label("New Game", systemImage: "arrow.clockwise")
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(.white)
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        ForEach(SudokuDifficulty.allCases, id: \.self) { d in
                            Button {
                                engine.newGame(difficulty: d)
                            } label: {
                                Label(d.rawValue,
                                      systemImage: engine.difficulty == d ? "checkmark" : "")
                            }
                        }
                    } label: {
                        Text(engine.difficulty.rawValue)
                            .font(.subheadline.weight(.semibold))
                    }
                }
            }
            .overlay {
                if engine.isSolved {
                    solvedOverlay
                }
            }
        }
    }

    // MARK: Private

    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    @StateObject private var engine: SudokuEngine = .init()

    private var hudBar: some View {
        HStack {
            // Timer
            Label(timeString(engine.elapsedSeconds), systemImage: "clock")
                .font(.system(size: 13, weight: .semibold, design: .monospaced))
                .foregroundStyle(.secondary)

            Spacer()

            // Mistakes
            HStack(spacing: 4) {
                ForEach(0..<3, id: \.self) { i in
                    Image(systemName: i < engine.mistakes ? "xmark.circle.fill" : "circle")
                        .foregroundStyle(i < engine.mistakes ? .red : Color(.systemGray4))
                        .font(.system(size: 16))
                }
            }

            Spacer()

            // Hints used
            Label("\(engine.hintsUsed)", systemImage: "lightbulb.fill")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.yellow)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 6)
        .background(
            reduceTransparency
                ? Color(.systemGray5)
                : Color(.systemGray6).opacity(0.8)
        )
    }

    private var gridView: some View {
        GeometryReader { proxy in
            let totalSize = proxy.size.width
            let cellSize = totalSize / 9

            ZStack(alignment: .topLeading) {
                // Cells
                ForEach(0..<9, id: \.self) { row in
                    ForEach(0..<9, id: \.self) { col in
                        let cell = engine.cells[row][col]
                        let highlight = engine.highlightState(row: row, col: col)

                        SudokuCellView(
                            cell: cell,
                            highlight: highlight,
                            cellSize: cellSize,
                            reduceTransparency: reduceTransparency
                        )
                        .frame(width: cellSize, height: cellSize)
                        .position(
                            x: CGFloat(col) * cellSize + cellSize / 2,
                            y: CGFloat(row) * cellSize + cellSize / 2
                        )
                        .onTapGesture { engine.select(row: row, col: col) }
                    }
                }

                // Grid lines (thin inner, thick box borders)
                Canvas { ctx, size in
                    let cs = size.width / 9

                    // Thin cell lines
                    for i in 1..<9 {
                        let x = cs * CGFloat(i)
                        let y = cs * CGFloat(i)
                        let thin = i % 3 != 0

                        let hPath = Path { p in p.move(to: .init(x: 0, y: y)); p.addLine(to: .init(x: size.width, y: y)) }
                        let vPath = Path { p in p.move(to: .init(x: x, y: 0)); p.addLine(to: .init(x: x, y: size.height)) }

                        ctx.stroke(hPath, with: .color(thin ? Color(.systemGray4) : Color(.systemGray2)),
                                   lineWidth: thin ? 0.5 : 2)
                        ctx.stroke(vPath, with: .color(thin ? Color(.systemGray4) : Color(.systemGray2)),
                                   lineWidth: thin ? 0.5 : 2)
                    }

                    // Outer border
                    ctx.stroke(Path(CGRect(origin: .zero, size: size)),
                               with: .color(Color(.systemGray2)), lineWidth: 2)
                }
                .allowsHitTesting(false)
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.08), radius: 6, y: 3)
    }

    private var numberPad: some View {
        HStack(spacing: 6) {
            ForEach(1...9, id: \.self) { d in
                let count = filledCount(for: d)
                Button {
                    withAnimation(reduceMotion ? .none : .easeOut(duration: 0.1)) {
                        engine.enterDigit(d)
                    }
                } label: {
                    VStack(spacing: 2) {
                        Text("\(d)")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                        // small dot row showing remaining count
                        HStack(spacing: 2) {
                            ForEach(0..<(9 - count), id: \.self) { _ in
                                Circle().frame(width: 3, height: 3)
                            }
                        }
                        .foregroundStyle(Color.accentColor.opacity(0.5))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(digitBg(for: d))
                    )
                    .foregroundStyle(count >= 9 ? Color(.systemGray3) : .primary)
                }
                .disabled(count >= 9)
            }
        }
        .padding(.horizontal, 12)
    }

    private var actionRow: some View {
        HStack(spacing: 0) {
            // Undo
            actionButton(icon: "arrow.uturn.backward", label: "Undo") {
                engine.undo()
            }

            // Erase
            actionButton(icon: "delete.left", label: "Erase") {
                withAnimation(reduceMotion ? .none : .easeOut(duration: 0.1)) {
                    engine.erase()
                }
            }

            // Notes toggle
            actionButton(
                icon: engine.isNoteMode ? "pencil.circle.fill" : "pencil.circle",
                label: "Notes",
                tint: engine.isNoteMode ? .blue : .primary
            ) {
                engine.isNoteMode.toggle()
            }

            // Hint
            actionButton(icon: "lightbulb", label: "Hint", tint: .yellow) {
                withAnimation(reduceMotion ? .none : .spring(response: 0.3)) {
                    engine.hint()
                }
            }
        }
        .padding(.horizontal, 12)
    }

    private var solvedOverlay: some View {
        VStack(spacing: 14) {
            Text("🎉")
                .font(.system(size: 52))
            Text("Puzzle Solved!")
                .font(.system(size: 22, weight: .black, design: .rounded))
                .foregroundStyle(.green)
            Text(timeString(engine.elapsedSeconds))
                .font(.system(size: 16, weight: .semibold, design: .monospaced))
                .foregroundStyle(.secondary)
            if engine.hintsUsed == 0, engine.mistakes == 0 {
                Text("✨ Perfect solve!")
                    .font(.subheadline.bold())
                    .foregroundStyle(.yellow)
            }
            Button("New Game") {
                engine.newGame(difficulty: engine.difficulty)
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)
        }
        .padding(32)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(Color(.systemBackground).opacity(0.97))
                .shadow(color: .black.opacity(0.18), radius: 20, y: 8)
        )
        .transition(.scale.combined(with: .opacity))
        .animation(reduceMotion ? .none : .spring(response: 0.4, dampingFraction: 0.7), value: engine.isSolved)
    }

    private func actionButton(
        icon: String,
        label: String,
        tint: Color = .primary,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                Text(label)
                    .font(.system(size: 10, weight: .semibold))
            }
            .foregroundStyle(tint)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(reduceTransparency ? Color(.systemGray5) : Color(.systemGray6).opacity(0.7))
            )
        }
        .padding(.horizontal, 3)
    }

    private func timeString(_ s: Int) -> String {
        unsafe String(format: "%02d:%02d", s / 60, s % 60)
    }

    private func filledCount(for digit: Int) -> Int {
        engine.cells.flatMap { $0 }.filter { $0.value == digit }.count
    }

    private func digitBg(for digit: Int) -> Color {
        guard let (sr, sc) = engine.selected else {
            return reduceTransparency ? Color(.systemGray5) : Color(.systemGray6).opacity(0.7)
        }

        let selVal = engine.cells[sr][sc].value
        if selVal == digit {
            return Color.accentColor.opacity(reduceTransparency ? 0.6 : 0.18)
        }
        return reduceTransparency ? Color(.systemGray5) : Color(.systemGray6).opacity(0.7)
    }
}

private struct SudokuCellView: View {
    // MARK: Internal

    let cell: SudokuCell
    let highlight: CellHighlight
    let cellSize: CGFloat
    let reduceTransparency: Bool

    var body: some View {
        ZStack {
            // Background
            Rectangle().fill(bgColor)

            if cell.value != 0 {
                // Value
                Text("\(cell.value)")
                    .font(.system(size: cellSize * 0.52, weight: cell.isGiven ? .black : .semibold, design: .rounded))
                    .foregroundStyle(valueColor)
            } else if !cell.notes.isEmpty {
                // Notes grid 3×3
                notesGrid
            }
        }
    }

    // MARK: Private

    private var bgColor: Color {
        switch highlight {
        case .selected:
            Color.accentColor.opacity(reduceTransparency ? 0.5 : 0.25)

        case .sameValue:
            Color.accentColor.opacity(reduceTransparency ? 0.35 : 0.12)

        case .peer:
            reduceTransparency
                ? Color(.systemGray4)
                : Color(.systemGray5).opacity(0.85)

        case .none:
            Color(.systemBackground)
        }
    }

    private var valueColor: Color {
        if cell.isError {
            return .red
        }
        if cell.isGiven {
            return .primary
        }
        return Color.accentColor
    }

    private var notesGrid: some View {
        let noteSize = cellSize * 0.28
        return VStack(spacing: 0) {
            ForEach(0..<3, id: \.self) { nRow in
                HStack(spacing: 0) {
                    ForEach(1...3, id: \.self) { nCol in
                        let digit = nRow * 3 + nCol
                        Text(cell.notes.contains(digit) ? "\(digit)" : "")
                            .font(.system(size: noteSize * 0.85, weight: .medium, design: .monospaced))
                            .foregroundStyle(Color.accentColor.opacity(0.8))
                            .frame(width: cellSize / 3, height: cellSize / 3)
                    }
                }
            }
        }
    }
}
