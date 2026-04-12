import Combine
import SwiftUI

private enum MSConst {
    static let cellSize: CGFloat = 36
    static let chunkSize: Int = 8 // cells per chunk side
    static let mineDensity: Double = 0.18 // ~18% mines per chunk
    static let worldSeed: UInt64 = 0xDEAD_BEEF_1234_5678
}

struct CellCoord: Hashable {
    let row: Int
    let col: Int
}

struct ChunkCoord: Hashable {
    let row: Int
    let col: Int
}

enum CellState: Hashable {
    case hidden
    case revealed(Int) // adjacent mine count 0-8
    case mine // revealed mine (game over)
    case flagged
}

/// An 8x8 lazily-generated chunk. Mines are seeded from chunk coords + world seed.
struct Chunk {
    // MARK: Lifecycle

    init(coord: ChunkCoord) {
        self.coord = coord
        var m = Array(repeating: Array(repeating: false, count: MSConst.chunkSize),
                      count: MSConst.chunkSize)
        // Deterministic PRNG seeded from chunk coord + world seed
        var rng = ChunkRNG(seed: MSConst.worldSeed,
                           chunkRow: coord.row,
                           chunkCol: coord.col)
        for r in 0..<MSConst.chunkSize {
            for c in 0..<MSConst.chunkSize {
                m[r][c] = rng.next01() < MSConst.mineDensity
            }
        }
        mines = m
    }

    // MARK: Internal

    let coord: ChunkCoord
    var mines: [[Bool]] // [localRow][localCol]

    func isMine(localRow: Int, localCol: Int) -> Bool {
        guard (0..<MSConst.chunkSize).contains(localRow),
              (0..<MSConst.chunkSize).contains(localCol) else {
                  return false
              }

        return mines[localRow][localCol]
    }
}

struct ChunkRNG {
    // MARK: Lifecycle

    init(seed: UInt64, chunkRow: Int, chunkCol: Int) {
        // Mix chunk coords into seed
        let r = UInt64(bitPattern: Int64(chunkRow))
        let c = UInt64(bitPattern: Int64(chunkCol))
        state = seed ^ (r &* 0x9E3779B97F4A7C15) ^ (c &* 0x6C62272E07BB0142)
        if state == 0 {
            state = 1
        }
        // Warm up
        for _ in 0..<8 {
            _ = next()
        }
    }

    // MARK: Internal

    mutating func next() -> UInt64 {
        state ^= state << 13
        state ^= state >> 7
        state ^= state << 17
        return state
    }

    mutating func next01() -> Double {
        Double(next() >> 11) / Double(1 << 53)
    }

    // MARK: Private

    private var state: UInt64
}

@MainActor
class MinesweeperEngine: ObservableObject {
    // MARK: Lifecycle

    init() {}

    // MARK: Internal

    @Published var cellStates: [CellCoord: CellState] = [:]
    @Published var isGameOver: Bool = false
    @Published var flagCount: Int = 0
    @Published var revealCount: Int = 0
    @Published var firstTap: Bool = true // protect first tap

    func reset() {
        cellStates = [:]
        chunkCache = [:]
        isGameOver = false
        flagCount = 0
        revealCount = 0
        firstTap = true
    }

    func chunk(at coord: ChunkCoord) -> Chunk {
        if let c = chunkCache[coord] {
            return c
        }
        let c = Chunk(coord: coord)
        chunkCache[coord] = c
        return c
    }

    func isMine(at cell: CellCoord) -> Bool {
        let cc = chunkCoord(for: cell)
        let lc = localCoord(for: cell)
        return chunk(at: cc).isMine(localRow: lc.row, localCol: lc.col)
    }

    func adjacentMines(at cell: CellCoord) -> Int {
        neighbors(of: cell).filter { isMine(at: $0) }.count
    }

    func tap(at cell: CellCoord) {
        guard !isGameOver else {
            return
        }

        let state = cellStates[cell]
        guard state == nil || state == .some(.hidden) else {
            return
        }

        // First tap: ensure it's not a mine
        if firstTap {
            firstTap = false
            clearMineIfNeeded(at: cell)
        }

        if isMine(at: cell) {
            cellStates[cell] = .mine
            isGameOver = true
            revealAllMines()
            return
        }

        floodReveal(from: cell)
    }

    func flag(at cell: CellCoord) {
        guard !isGameOver else {
            return
        }

        switch cellStates[cell] {
        case .hidden, nil:
            cellStates[cell] = .flagged
            flagCount += 1

        case .flagged:
            cellStates[cell] = .hidden
            flagCount -= 1

        default:
            break
        }
    }

    func stateFor(_ cell: CellCoord) -> CellState {
        cellStates[cell] ?? .hidden
    }

    func chunkCoord(for cell: CellCoord) -> ChunkCoord {
        ChunkCoord(
            row: floorDiv(cell.row, MSConst.chunkSize),
            col: floorDiv(cell.col, MSConst.chunkSize)
        )
    }

    func localCoord(for cell: CellCoord) -> CellCoord {
        CellCoord(
            row: modulo(cell.row, MSConst.chunkSize),
            col: modulo(cell.col, MSConst.chunkSize)
        )
    }

    func worldCoord(chunkCoord cc: ChunkCoord, localRow r: Int, localCol c: Int) -> CellCoord {
        CellCoord(row: cc.row * MSConst.chunkSize + r,
                  col: cc.col * MSConst.chunkSize + c)
    }

    // MARK: Private

    // Chunk cache
    private var chunkCache: [ChunkCoord: Chunk] = [:]

    private func floodReveal(from start: CellCoord) {
        var stack = [start]
        var visited = Set<CellCoord>()

        while !stack.isEmpty {
            let cell = stack.removeLast()
            guard !visited.contains(cell) else {
                continue
            }

            visited.insert(cell)

            guard cellStates[cell] != .flagged else {
                continue
            }
            guard !isMine(at: cell) else {
                continue
            }

            let count = adjacentMines(at: cell)
            cellStates[cell] = .revealed(count)
            revealCount += 1

            if count == 0 {
                stack.append(contentsOf: neighbors(of: cell).filter { !visited.contains($0) })
            }
        }
    }

    private func revealAllMines() {
        // Reveal mines in already-loaded chunks only (performance)
        for (chunkCoord, chunk) in chunkCache {
            for r in 0..<MSConst.chunkSize {
                for c in 0..<MSConst.chunkSize {
                    if chunk.mines[r][c] {
                        let world = worldCoord(chunkCoord: chunkCoord, localRow: r, localCol: c)
                        if cellStates[world] != .flagged {
                            cellStates[world] = .mine
                        }
                    }
                }
            }
        }
    }

    /// On first tap, swap mine to a different location in the chunk
    private func clearMineIfNeeded(at cell: CellCoord) {
        let cc = chunkCoord(for: cell)
        let lc = localCoord(for: cell)
        var c = chunk(at: cc)
        guard c.mines[lc.row][lc.col] else {
            return
        }

        // Find a free cell in same chunk
        c.mines[lc.row][lc.col] = false
        outerLoop: for r in 0..<MSConst.chunkSize {
            for col in 0..<MSConst.chunkSize {
                if !c.mines[r][col], !(r == lc.row && col == lc.col) {
                    c.mines[r][col] = true
                    break outerLoop
                }
            }
        }
        chunkCache[cc] = c
    }

    private func neighbors(of cell: CellCoord) -> [CellCoord] {
        let offsets = [(-1, -1), (-1, 0), (-1, 1), (0, -1), (0, 1), (1, -1), (1, 0), (1, 1)]
        return offsets.map { CellCoord(row: cell.row + $0.0, col: cell.col + $0.1) }
    }

    // Floor division (correct for negative numbers)
    private func floorDiv(_ a: Int, _ b: Int) -> Int {
        let q = a / b
        return a < 0 && a % b != 0 ? q - 1 : q
    }

    private func modulo(_ a: Int, _ b: Int) -> Int {
        let r = a % b
        return r < 0 ? r + b : r
    }
}

struct GameMinesweeperView: View {
    // MARK: Internal

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Top HUD
                hudBar

                // Infinite canvas
                GeometryReader { proxy in
                    infiniteCanvas(in: proxy)
                }
                .clipped()
                .overlay(alignment: .bottom) {
                    if showBoom {
                        boomOverlay
                    }
                }
            }
            .navigationTitle("Minesweeper ∞")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    MCCancelButton { dismiss() }
                }
                ToolbarItem(placement: .bottomBar) {
                    Button {
                        withAnimation(.spring(response: 0.3)) {
                            engine.reset()
                            offset = .zero
                            showBoom = false
                            isFlagMode = false
                        }
                    } label: {
                        Label("New Game", systemImage: "arrow.clockwise")
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(.white)
                    }
                }
            }
            .onChange(of: engine.isGameOver) { _, over in
                if over {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) {
                        showBoom = true
                    }
                }
            }
        }
    }

    // MARK: Private

    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    @StateObject private var engine: MinesweeperEngine = .init()

    // Pan offset in points (world-space origin offset)
    @State private var offset: CGSize = .zero
    @State private var dragBase: CGSize = .zero
    @State private var isFlagMode: Bool = false
    @State private var showBoom: Bool = false

    private var hudBar: some View {
        HStack(spacing: 16) {
            // Flag count
            Label("\(engine.flagCount)", systemImage: "flag.fill")
                .foregroundStyle(.red)
                .font(.subheadline.bold())

            Spacer()

            // Revealed count
            Label("\(engine.revealCount)", systemImage: "eye.fill")
                .foregroundStyle(.green)
                .font(.subheadline.bold())

            Spacer()

            // Flag mode toggle
            Button {
                isFlagMode.toggle()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: isFlagMode ? "flag.fill" : "hand.tap.fill")
                    Text(isFlagMode ? "Flag" : "Reveal")
                        .font(.subheadline.bold())
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(
                    Capsule().fill(isFlagMode ? Color.red.opacity(0.18) : Color.blue.opacity(0.12))
                )
                .foregroundStyle(isFlagMode ? .red : .blue)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            reduceTransparency
                ? Color(.systemGray5)
                : Color(.systemGray6).opacity(0.95)
        )
    }

    private var boomOverlay: some View {
        VStack(spacing: 12) {
            Text("💥")
                .font(.system(size: 56))
            Text("BOOM!")
                .font(.system(size: 28, weight: .black, design: .rounded))
                .foregroundStyle(.red)
            Text("\(engine.revealCount) cells revealed")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(28)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(reduceTransparency
                      ? Color(.systemBackground)
                      : Color(.systemBackground).opacity(0.95))
                .shadow(color: .red.opacity(0.25), radius: 16, y: 6)
        )
        .padding(.bottom, 40)
        .transition(.scale.combined(with: .opacity))
    }

    private func infiniteCanvas(in proxy: GeometryProxy) -> some View {
        let size = proxy.size
        let cs = MSConst.cellSize

        // Visible world-cell range
        let originX = -offset.width
        let originY = -offset.height
        let minCol = Int(floor(originX / cs)) - 1
        let maxCol = Int(ceil((originX + size.width) / cs)) + 1
        let minRow = Int(floor(originY / cs)) - 1
        let maxRow = Int(ceil((originY + size.height) / cs)) + 1

        // Visible chunks
        let minCR = floorDiv(minRow, MSConst.chunkSize)
        let maxCR = floorDiv(maxRow, MSConst.chunkSize)
        let minCC = floorDiv(minCol, MSConst.chunkSize)
        let maxCC = floorDiv(maxCol, MSConst.chunkSize)

        return ZStack(alignment: .topLeading) {
            // Chunk background grid lines
            chunkGrid(
                minCR: minCR, maxCR: maxCR,
                minCC: minCC, maxCC: maxCC,
                offset: offset, cs: cs
            )

            // Cells
            ForEach(minRow..<maxRow, id: \.self) { row in
                ForEach(minCol..<maxCol, id: \.self) { col in
                    let cell = CellCoord(row: row, col: col)
                    let state = engine.stateFor(cell)
                    let x = CGFloat(col) * cs + offset.width
                    let y = CGFloat(row) * cs + offset.height

                    MSCellView(
                        state: state,
                        isFlagMode: isFlagMode,
                        reduceTransparency: reduceTransparency
                    )
                    .frame(width: cs, height: cs)
                    .position(x: x + cs/2, y: y + cs/2)
                    .onTapGesture {
                        guard !engine.isGameOver else {
                            return
                        }

                        withAnimation(reduceMotion ? .none : .easeOut(duration: 0.12)) {
                            if isFlagMode {
                                engine.flag(at: cell)
                            } else {
                                engine.tap(at: cell)
                            }
                        }
                    }
                }
            }
        }
        .gesture(
            DragGesture(minimumDistance: 8)
                .onChanged { v in
                    offset = CGSize(
                        width: dragBase.width + v.translation.width,
                        height: dragBase.height + v.translation.height
                    )
                }
                .onEnded { _ in
                    dragBase = offset
                }
        )
    }

    private func chunkGrid(
        minCR: Int, maxCR: Int, minCC: Int, maxCC: Int,
        offset: CGSize, cs: CGFloat
    ) -> some View {
        Canvas { ctx, size in
            let chunkPx = cs * CGFloat(MSConst.chunkSize)
            ctx.stroke(
                {
                    var p = Path()
                    for cr in minCR...maxCR {
                        let y = CGFloat(cr) * chunkPx + offset.height
                        p.move(to: .init(x: 0, y: y))
                        p.addLine(to: .init(x: size.width, y: y))
                    }
                    for cc in minCC...maxCC {
                        let x = CGFloat(cc) * chunkPx + offset.width
                        p.move(to: .init(x: x, y: 0))
                        p.addLine(to: .init(x: x, y: size.height))
                    }
                    return p
                }(),
                with: .color(.blue.opacity(reduceTransparency ? 0.5 : 0.20)),
                lineWidth: 1.5
            )
        }
    }

    private func floorDiv(_ a: Int, _ b: Int) -> Int {
        let q = a / b
        return a < 0 && a % b != 0 ? q - 1 : q
    }
}

private struct MSCellView: View {
    // MARK: Internal

    let state: CellState
    let isFlagMode: Bool
    let reduceTransparency: Bool

    var body: some View {
        ZStack {
            // Background
            RoundedRectangle(cornerRadius: 4)
                .fill(bgColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .strokeBorder(borderColor, lineWidth: 0.5)
                )

            // Content
            switch state {
            case .hidden:
                if isFlagMode {
                    Image(systemName: "flag")
                        .font(.system(size: 11))
                        .foregroundStyle(.red.opacity(0.35))
                }

            case .flagged:
                Image(systemName: "flag.fill")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.red)

            case .mine:
                Text("💣")
                    .font(.system(size: 16))

            case let .revealed(n):
                if n > 0 {
                    Text("\(n)")
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .foregroundStyle(numberColor(n))
                }
            }
        }
        .padding(1.5)
    }

    // MARK: Private

    private var bgColor: Color {
        switch state {
        case .hidden: reduceTransparency ? Color(.systemGray4) : Color(.systemGray4)
        case .flagged: Color.red.opacity(0.12)
        case .mine: Color.red.opacity(0.85)
        case .revealed: reduceTransparency ? Color(.systemGray6) : Color(.systemGray6)
        }
    }

    private var borderColor: Color {
        switch state {
        case .hidden: Color(.systemGray3)
        case .flagged: Color.red.opacity(0.4)
        case .mine: Color.red
        case .revealed: Color(.systemGray5)
        }
    }

    private func numberColor(_ n: Int) -> Color {
        switch n {
        case 1: .blue
        case 2: .green
        case 3: .red
        case 4: Color(red: 0.0, green: 0.0, blue: 0.6)
        case 5: Color(red: 0.6, green: 0.0, blue: 0.0)
        case 6: .cyan
        case 7: .black
        case 8: .gray
        default: .primary
        }
    }
}
