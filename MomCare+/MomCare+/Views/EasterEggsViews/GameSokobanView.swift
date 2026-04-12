import Combine
import SwiftUI

enum SokobanTile: Character {
    case floor = " "
    case wall = "#"
    case goal = "."
    case box = "$"
    case boxOnGoal = "*"
    case player = "@"
    case playerOnGoal = "+"
    case void = "X" // outside playfield (padding)
}

struct SokobanLevel {
    static let all: [SokobanLevel] = SokobanLevelPack.levels

    let name: String
    let map: [[SokobanTile]]
}

enum SokobanLevelPack {
    static let levels: [SokobanLevel] = rawLevels.enumerated().map { i, raw in
        let rows = raw.components(separatedBy: "\n")
        let maxW = rows.map(\.count).max() ?? 0
        let tiles = rows.map { row -> [SokobanTile] in
            let padded = row + String(repeating: "X", count: maxW - row.count)
            return padded.map { SokobanTile(rawValue: $0) ?? .void }
        }
        return SokobanLevel(name: "Level \(i + 1)", map: tiles)
    }

    // Classic Sokoban original levels 1–20
    static let rawLevels: [String] = [
        // 1
        """
    #####
    #   #
    #$  #
  ###  $##
  #  $ $ #
### # ## #   ######
#   # ## #####  ..#
# $  $          ..#
##### ### #@##  ..#
    #     #########
    #######
""",
        // 2
        """
############
#..  #     ###
#..  # $  $  #
#..  #$####  #
#..    @ ##  #
#..  # #  $ ##
###### ##$ $ #
  # $  $ $ $ #
  #    #     #
  ############
""",
        // 3
        """
        ########
        #     @#
        # $#$ ##
        # $  $#
        ##$ $ #
######### $ # ###
#....  ## $  $  #
##...    $  $   #
#....  ##########
########
""",
        // 4
        """
########
#    ###
# ##   #
#@ $ $ #
### $$ #
#   #  #
# $ ## ###
##$  $   #
 # $ $ $ #
 ##  #   #
  ## #####
   # #
   # #
   ###
""",
        // 5
        """
 #######
 #     #
 # .$. #
## $@$ ##
#  .$.  #
#  $ $  #
#### ####
""",
        // 6
        """
######  ###
#  . ####  #
#    #  $  #
### ### $ ##
  #  @$ $ #
  # .#  $ #
  #  ##### #
  #. #     #
  ## ##  # #
   #  #### #
   #       #
   #########
""",
        // 7
        """
   #####
   #   #
   # $ #
 ### $##
 #  $ #
## ## ###
#. .    #
#   @$  #
#  .#####
####
""",
        // 8
        """
####
#  ####
#     ##
## ##  #
 # @$$ #
 #  #  #
 ## # ##
  # $ #
  #.$.#
  #. .#
  #####
""",
        // 9
        """
 #######
##  .  ##
#  . .  #
# $$$$$  #
##  @   ##
 ### ###
""",
        // 10
        """
########
#      #
# .**. #
# $  $ #
# $  $ #
# .**. #
#  @@  #
########
""",
        // 11
        """
  ####
  #  ##
  # $ #
  # . #
 ## $.##
 #  . ##
## ##$ #
#. $@  #
#   ####
#####
""",
        // 12
        """
#####
#   ##
# $  #
## $ #####
 # $ .   #
 #   . $ #
 #####.  #
     # @ #
     #####
""",
        // 13
        """
 ####
##  ###
#  $  #
#  $. #
# @$. #
##  . #
 #  ###
 ####
""",
        // 14
        """
######
#    #
# ## ##
# #   #
# $ $ #
##$ $ #
#. .@ #
#. .  #
#######
""",
        // 15
        """
  #####
  # . #
  # . #
  #   #
###$$ #
#  $$ #
# @ . #
#   ###
#####
""",
        // 16
        """
 #######
##  $  ##
# $. .$ #
#   @   #
# $. .$ #
##  $  ##
 #######
""",
        // 17
        """
#####
#@  ##
# $  #
## $ #
 #   #
 # $##
 #. .#
 #. .#
 #####
""",
        // 18
        """
 ####
 #  #
 #  ##
## $$ #
#. @. #
#  ## #
## $  #
 # .  #
 ######
""",
        // 19
        """
#####
#   ##
# $$ #
#  $ #
## $ #
 # $.#
 # . #
 #@. #
 #####
""",
        // 20
        """
  ####
  #  #
###$ #
# $  #
# . @#
##.$ #
 #.  #
 ####
"""
    ]
}

struct SokoPos: Hashable, Equatable {
    var row: Int
    var col: Int

    func offset(dr: Int, dc: Int) -> SokoPos {
        SokoPos(row: row + dr, col: col + dc)
    }
}

struct SokoSnapshot {
    let playerPos: SokoPos
    let boxes: Set<SokoPos>
}

enum SokoMoveResult { case moved, pushedBox, invalid }

@MainActor
class SokobanEngine: ObservableObject {
    // MARK: Lifecycle

    init() {
        loadLevel(0)
    }

    // MARK: Internal

    // MARK: Published

    @Published var map: [[SokobanTile]] = []
    @Published var playerPos: SokoPos = .init(row: 0, col: 0)
    @Published var boxes: Set<SokoPos> = []
    @Published var goals: Set<SokoPos> = []
    @Published var isSolved: Bool = false
    @Published var moves: Int = 0
    @Published var pushes: Int = 0
    @Published var currentLevel: Int = 0
    @Published var totalLevels: Int = SokobanLevel.all.count
    @Published var bestMoves: [Int: Int] = [:] // level → best move count

    var rows: Int {
        map.count
    }

    var cols: Int {
        map.first?.count ?? 0
    }

    func loadLevel(_ index: Int) {
        guard index < SokobanLevel.all.count else {
            return
        }

        currentLevel = index
        let level = SokobanLevel.all[index]

        // Parse static map (walls + goals), extract mutable state
        var staticMap = level.map
        var player = SokoPos(row: 0, col: 0)
        var boxSet = Set<SokoPos>()
        var goalSet = Set<SokoPos>()

        for r in staticMap.indices {
            for c in staticMap[r].indices {
                switch staticMap[r][c] {
                case .player:
                    player = SokoPos(row: r, col: c)
                    staticMap[r][c] = .floor

                case .playerOnGoal:
                    player = SokoPos(row: r, col: c)
                    staticMap[r][c] = .goal
                    goalSet.insert(.init(row: r, col: c))

                case .box:
                    boxSet.insert(.init(row: r, col: c))
                    staticMap[r][c] = .floor

                case .boxOnGoal:
                    boxSet.insert(.init(row: r, col: c))
                    staticMap[r][c] = .goal
                    goalSet.insert(.init(row: r, col: c))

                case .goal:
                    goalSet.insert(.init(row: r, col: c))

                default: break
                }
            }
        }

        map = staticMap
        playerPos = player
        boxes = boxSet
        goals = goalSet
        isSolved = false
        moves = 0
        pushes = 0
        undoStack = []
    }

    func restart() {
        loadLevel(currentLevel)
    }

    func nextLevel() {
        if currentLevel + 1 < SokobanLevel.all.count {
            loadLevel(currentLevel + 1)
        }
    }

    func previousLevel() {
        if currentLevel > 0 {
            loadLevel(currentLevel - 1)
        }
    }

    @discardableResult
    func move(dr: Int, dc: Int) -> SokoMoveResult {
        guard !isSolved else {
            return .invalid
        }

        let next = playerPos.offset(dr: dr, dc: dc)
        let beyond = next.offset(dr: dr, dc: dc)

        guard inBounds(next), passable(next) else {
            return .invalid
        }

        let snapshot = SokoSnapshot(playerPos: playerPos, boxes: boxes)

        if boxes.contains(next) {
            // Push: beyond must be free
            guard inBounds(beyond), passable(beyond), !boxes.contains(beyond) else {
                return .invalid
            }

            boxes.remove(next)
            boxes.insert(beyond)
            pushes += 1
            undoStack.append(snapshot)
            playerPos = next
            moves += 1
            checkSolved()
            return .pushedBox
        } else {
            undoStack.append(snapshot)
            playerPos = next
            moves += 1
            return .moved
        }
    }

    func undo() {
        guard let snap = undoStack.popLast() else {
            return
        }

        playerPos = snap.playerPos
        boxes = snap.boxes
        isSolved = false
        if moves > 0 {
            moves -= 1
        }
    }

    func tileAt(_ pos: SokoPos) -> SokobanTile {
        guard inBounds(pos) else {
            return .void
        }

        let base = map[pos.row][pos.col]
        if boxes.contains(pos) {
            return goals.contains(pos) ? .boxOnGoal : .box
        }
        if pos == playerPos {
            return goals.contains(pos) ? .playerOnGoal : .player
        }
        return base
    }

    var boxesOnGoalCount: Int {
        goals.intersection(boxes).count
    }

    // MARK: Private

    private var undoStack: [SokoSnapshot] = []

    private func inBounds(_ pos: SokoPos) -> Bool {
        pos.row >= 0 && pos.row < rows && pos.col >= 0 && pos.col < cols
    }

    private func passable(_ pos: SokoPos) -> Bool {
        let t = map[pos.row][pos.col]
        return t == .floor || t == .goal
    }

    private func checkSolved() {
        isSolved = goals.allSatisfy { boxes.contains($0) }
        if isSolved {
            if let prev = bestMoves[currentLevel] {
                if moves < prev {
                    bestMoves[currentLevel] = moves
                }
            } else {
                bestMoves[currentLevel] = moves
            }
        }
    }
}

struct GameSokobanView: View {
    // MARK: Internal

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // HUD
                hudBar
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        reduceTransparency
                            ? Color(.systemGray5)
                            : Color(.systemGray6).opacity(0.9)
                    )

                Spacer(minLength: 0)

                // Board
                GeometryReader { proxy in
                    boardView(in: proxy)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }

                Spacer(minLength: 0)

                // D-pad controls
                dpad
                    .padding(.bottom, 12)
            }
            .navigationTitle(SokobanLevel.all[engine.currentLevel].name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    MCCancelButton { dismiss() }
                }
                ToolbarItem(placement: .bottomBar) {
                    HStack {
                        // Prev level
                        Button {
                            withAnimation(reduceMotion ? .none : .spring(response: 0.3)) {
                                engine.previousLevel()
                            }
                        } label: {
                            Image(systemName: "chevron.left")
                        }
                        .disabled(engine.currentLevel == 0)

                        Spacer()

                        // Restart
                        Button {
                            withAnimation(reduceMotion ? .none : .spring(response: 0.3)) {
                                engine.restart()
                            }
                        } label: {
                            Label("Restart", systemImage: "arrow.clockwise")
                        }

                        Spacer()

                        // Next level
                        Button {
                            withAnimation(reduceMotion ? .none : .spring(response: 0.3)) {
                                engine.nextLevel()
                            }
                        } label: {
                            Image(systemName: "chevron.right")
                        }
                        .disabled(engine.currentLevel >= engine.totalLevels - 1)
                    }
                }
            }
            .overlay {
                if engine.isSolved {
                    solvedOverlay
                }
            }
            // Swipe gesture on the whole view
            .gesture(swipeGesture)
        }
    }

    // MARK: Private

    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    @StateObject private var engine: SokobanEngine = .init()

    // Swipe thresholds
    private let swipeThreshold: CGFloat = 28

    private var swipeGesture: some Gesture {
        DragGesture(minimumDistance: swipeThreshold)
            .onEnded { v in
                let dx = v.translation.width
                let dy = v.translation.height

                // Prevent diagonal moves — dominant axis wins
                if abs(dx) > abs(dy) {
                    // Horizontal: one step per swipe
                    let steps = max(1, Int(abs(dx) / swipeThreshold))
                    for _ in 0..<steps {
                        _ = withAnimation(reduceMotion ? .none : .easeOut(duration: 0.08)) {
                            engine.move(dr: 0, dc: dx > 0 ? 1 : -1)
                        }
                    }
                } else {
                    let steps = max(1, Int(abs(dy) / swipeThreshold))
                    for _ in 0..<steps {
                        _ = withAnimation(reduceMotion ? .none : .easeOut(duration: 0.08)) {
                            engine.move(dr: dy > 0 ? 1 : -1, dc: 0)
                        }
                    }
                }
            }
    }

    private var hudBar: some View {
        HStack {
            // Level progress
            Text("\(engine.currentLevel + 1) / \(engine.totalLevels)")
                .font(.system(size: 13, weight: .semibold, design: .monospaced))
                .foregroundStyle(.secondary)

            Spacer()

            // Moves
            Label("\(engine.moves)", systemImage: "figure.walk")
                .font(.system(size: 13, weight: .semibold, design: .monospaced))

            Spacer()

            // Pushes
            Label("\(engine.pushes)", systemImage: "hand.push.fill")
                .font(.system(size: 13, weight: .semibold, design: .monospaced))

            Spacer()

            // Boxes on goal
            let onGoal = engine.boxesOnGoalCount
            Label("\(onGoal)/\(engine.goals.count)", systemImage: "shippingbox.fill")
                .font(.system(size: 13, weight: .semibold, design: .monospaced))
                .foregroundStyle(onGoal == engine.goals.count ? .green : .primary)

            Spacer()

            // Undo
            Button { withAnimation { engine.undo() } } label: {
                Image(systemName: "arrow.uturn.backward")
                    .font(.system(size: 15, weight: .semibold))
            }
        }
    }

    private var dpad: some View {
        VStack(spacing: 4) {
            HStack {
                Spacer()
                dpadButton(icon: "arrow.up", dr: -1, dc: 0)
                Spacer()
            }
            HStack(spacing: 4) {
                Spacer()
                dpadButton(icon: "arrow.left", dr: 0, dc: -1)
                dpadButton(icon: "arrow.down", dr: 1, dc: 0)
                dpadButton(icon: "arrow.right", dr: 0, dc: 1)
                Spacer()
            }
        }
        .frame(height: 120)
    }

    private var solvedOverlay: some View {
        VStack(spacing: 16) {
            Text("🎉")
                .font(.system(size: 56))
            Text("Level Cleared!")
                .font(.system(size: 22, weight: .black, design: .rounded))
                .foregroundStyle(.green)

            VStack(spacing: 6) {
                Label("\(engine.moves) moves", systemImage: "figure.walk")
                Label("\(engine.pushes) pushes", systemImage: "hand.push.fill")
                if let best = engine.bestMoves[engine.currentLevel] {
                    Label("Best: \(best) moves", systemImage: "trophy.fill")
                        .foregroundStyle(.yellow)
                }
            }
            .font(.subheadline.weight(.semibold))

            HStack(spacing: 12) {
                Button("Replay") {
                    withAnimation(reduceMotion ? .none : .spring(response: 0.3)) {
                        engine.restart()
                    }
                }
                .buttonStyle(.bordered)

                if engine.currentLevel + 1 < engine.totalLevels {
                    Button("Next Level") {
                        withAnimation(reduceMotion ? .none : .spring(response: 0.3)) {
                            engine.nextLevel()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                }
            }
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

    private func boardView(in proxy: GeometryProxy) -> some View {
        let rows = engine.rows
        let cols = engine.cols
        guard rows > 0, cols > 0 else {
            return AnyView(EmptyView())
        }

        let maxCellW = (proxy.size.width - 16) / CGFloat(cols)
        let maxCellH = (proxy.size.height - 16) / CGFloat(rows)
        let cellSize = min(maxCellW, maxCellH, 52)

        let boardW = cellSize * CGFloat(cols)
        let boardH = cellSize * CGFloat(rows)

        return AnyView(
            ZStack {
                Canvas { ctx, _ in
                    for r in 0..<rows {
                        for c in 0..<cols {
                            let pos = SokoPos(row: r, col: c)
                            let tile = engine.tileAt(pos)
                            let rect = CGRect(x: CGFloat(c)*cellSize,
                                              y: CGFloat(r)*cellSize,
                                              width: cellSize, height: cellSize)
                            drawTile(ctx: &ctx, tile: tile, rect: rect, cellSize: cellSize)
                        }
                    }
                }
                .frame(width: boardW, height: boardH)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        )
    }

    private func dpadButton(icon: String, dr: Int, dc: Int) -> some View {
        Button {
            _ = withAnimation(reduceMotion ? .none : .easeOut(duration: 0.08)) {
                engine.move(dr: dr, dc: dc)
            }
        } label: {
            Image(systemName: icon)
                .font(.system(size: 22, weight: .semibold))
                .frame(width: 58, height: 52)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(reduceTransparency ? Color(.systemGray4) : Color(.systemGray5))
                        .shadow(color: .black.opacity(0.10), radius: 3, y: 2)
                )
                .foregroundStyle(.primary)
        }
        .buttonStyle(.plain)
    }

    private func drawTile(ctx: inout GraphicsContext, tile: SokobanTile, rect: CGRect, cellSize: CGFloat) {
        let inset = rect.insetBy(dx: 0.8, dy: 0.8)

        switch tile {
        case .void:
            break // transparent

        case .wall:
            // Outer block
            ctx.fill(Path(roundedRect: inset, cornerRadius: 3),
                     with: .color(reduceTransparency ? Color(.systemGray2) : Color(red: 0.35, green: 0.28, blue: 0.22)))
            // Mortar lines - top & left highlight
            ctx.fill(Path(CGRect(x: rect.minX, y: rect.minY, width: rect.width, height: 3)),
                     with: .color(.white.opacity(reduceTransparency ? 0 : 0.15)))
            ctx.fill(Path(CGRect(x: rect.minX, y: rect.minY, width: 3, height: rect.height)),
                     with: .color(.white.opacity(reduceTransparency ? 0 : 0.15)))
            // Shadow bottom/right
            ctx.fill(Path(CGRect(x: rect.minX, y: rect.maxY - 3, width: rect.width, height: 3)),
                     with: .color(.black.opacity(reduceTransparency ? 0 : 0.25)))

        case .floor:
            ctx.fill(Path(inset), with: .color(
                reduceTransparency ? Color(.systemGray6) : Color(red: 0.94, green: 0.90, blue: 0.82).opacity(0.7)
            ))

        case .goal:
            ctx.fill(Path(inset), with: .color(
                reduceTransparency ? Color(.systemGray5) : Color(red: 0.94, green: 0.90, blue: 0.82).opacity(0.7)
            ))
            // Dark X marker
            let m: CGFloat = cellSize * 0.22
            let cx = rect.midX
            let cy = rect.midY
            var cross = Path()
            cross.move(to: .init(x: cx - m, y: cy - m)); cross.addLine(to: .init(x: cx + m, y: cy + m))
            cross.move(to: .init(x: cx + m, y: cy - m)); cross.addLine(to: .init(x: cx - m, y: cy + m))
            ctx.stroke(cross, with: .color(.brown.opacity(0.55)), lineWidth: 2.5)

        case .box:
            ctx.fill(Path(roundedRect: inset.insetBy(dx: 2, dy: 2), cornerRadius: 5),
                     with: .color(reduceTransparency ? Color(.systemGray3) : Color(red: 0.80, green: 0.55, blue: 0.25)))
            // Shine
            ctx.fill(Path(roundedRect: CGRect(x: rect.minX+5, y: rect.minY+4, width: cellSize*0.35, height: cellSize*0.18),
                           cornerRadius: 2),
                     with: .color(.white.opacity(reduceTransparency ? 0 : 0.4)))
            // Dark border
            ctx.stroke(Path(roundedRect: inset.insetBy(dx: 2, dy: 2), cornerRadius: 5),
                        with: .color(.black.opacity(0.2)), lineWidth: 1)

        case .boxOnGoal:
            ctx.fill(Path(roundedRect: inset.insetBy(dx: 2, dy: 2), cornerRadius: 5),
                     with: .color(reduceTransparency ? Color.green : Color(red: 0.25, green: 0.72, blue: 0.35)))
            ctx.fill(Path(roundedRect: CGRect(x: rect.minX+5, y: rect.minY+4, width: cellSize*0.35, height: cellSize*0.18),
                           cornerRadius: 2),
                     with: .color(.white.opacity(reduceTransparency ? 0 : 0.45)))
            ctx.stroke(Path(roundedRect: inset.insetBy(dx: 2, dy: 2), cornerRadius: 5),
                        with: .color(.black.opacity(0.15)), lineWidth: 1)

        case .player, .playerOnGoal:
            let base = tile == .playerOnGoal ? Color(red: 0.94, green: 0.90, blue: 0.82).opacity(0.7) : Color(red: 0.94, green: 0.90, blue: 0.82).opacity(0.7)
            ctx.fill(Path(inset), with: .color(reduceTransparency ? Color(.systemGray6) : base))

            // Draw player as a little character
            let cs = cellSize
            let cx = rect.midX
            let cy = rect.midY

            // Body
            let bodyR = CGRect(x: cx - cs*0.18, y: cy - cs*0.08, width: cs*0.36, height: cs*0.32)
            ctx.fill(Path(roundedRect: bodyR, cornerRadius: 4),
                     with: .color(reduceTransparency ? .blue : Color(red: 0.2, green: 0.4, blue: 0.85)))
            // Head
            let headR = CGRect(x: cx - cs*0.14, y: cy - cs*0.38, width: cs*0.28, height: cs*0.28)
            ctx.fill(Path(ellipseIn: headR),
                     with: .color(reduceTransparency ? Color(.systemGray3) : Color(red: 0.97, green: 0.82, blue: 0.70)))
            // Legs
            ctx.fill(Path(CGRect(x: cx - cs*0.15, y: cy + cs*0.22, width: cs*0.12, height: cs*0.14)),
                     with: .color(reduceTransparency ? .gray : Color(red: 0.25, green: 0.18, blue: 0.5)))
            ctx.fill(Path(CGRect(x: cx + cs*0.03, y: cy + cs*0.22, width: cs*0.12, height: cs*0.14)),
                     with: .color(reduceTransparency ? .gray : Color(red: 0.25, green: 0.18, blue: 0.5)))
        }
    }
}
