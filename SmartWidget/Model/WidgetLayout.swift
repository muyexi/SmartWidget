import CoreGraphics
import Foundation

/// **Question 1** — the data structure that represents a widget layout.
///
/// The canvas is a top-to-bottom stack of rows; each row is a left-to-right
/// list of widgets. Rows share the canvas height equally, and the widgets in a
/// row share that row's width equally, so this structure alone determines
/// every frame — there is nothing else to keep in sync.
///
///     WidgetLayout(rows: [[a, b], [c]])
///
///     ┌─────────┬─────────┐
///     │    a    │    b    │   row 0
///     ├─────────┴─────────┤
///     │         c         │   row 1
///     └───────────────────┘
struct WidgetLayout: Equatable {
    private(set) var rows: [[WidgetInstance]]

    var isEmpty: Bool { rows.isEmpty }

    var widgets: [WidgetInstance] { rows.flatMap { $0 } }

    init(rows: [[WidgetInstance]] = []) {
        self.rows = rows.filter { !$0.isEmpty }
    }

    // MARK: - Question 2: computing each widget's frame

    /// A widget and the rectangle it occupies, in canvas coordinates.
    ///
    /// A placement is derived, never stored: it is rebuilt on every layout pass
    /// from the structure above, so a frame and the row it came from cannot
    /// disagree.
    struct Placement: Identifiable, Equatable {
        let widget: WidgetInstance
        let frame: CGRect

        var id: UUID { widget.id }
    }

    /// Computes a frame for every widget in the layout.
    ///
    /// The whole rule is "divide evenly": rows share the canvas height, and the
    /// widgets in a row share that row's width. `spacing` is the gutter between
    /// neighbours; the canvas edges get none, so the layout always fills the
    /// area it is given.
    ///
    /// - Parameters:
    ///   - size: the canvas to fill.
    ///   - spacing: the gutter between adjacent widgets.
    /// - Returns: one placement per widget, in reading order. Empty if the
    ///   layout is empty, or if `spacing` leaves no room for the widgets.
    func placements(in size: CGSize, spacing: CGFloat = 0) -> [Placement] {
        guard !rows.isEmpty else { return [] }

        let rowHeight = (size.height - spacing * CGFloat(rows.count - 1)) / CGFloat(rows.count)
        guard rowHeight > 0 else { return [] }

        return rows.enumerated().flatMap { rowIndex, row -> [Placement] in
            let columnWidth = (size.width - spacing * CGFloat(row.count - 1)) / CGFloat(row.count)
            guard columnWidth > 0 else { return [] }

            let y = (rowHeight + spacing) * CGFloat(rowIndex)
            return row.enumerated().map { columnIndex, widget in
                Placement(
                    widget: widget,
                    frame: CGRect(
                        x: (columnWidth + spacing) * CGFloat(columnIndex),
                        y: y,
                        width: columnWidth,
                        height: rowHeight
                    )
                )
            }
        }
    }

    // MARK: - Question 3: resolving a drop

    /// How much of a row's height, at its top and at its bottom, means "start a
    /// new row here" rather than "join the row I am pointing at".
    ///
    /// A quarter at each end leaves the middle half of every row as the target
    /// for joining it, which is comfortably larger than the finger it has to
    /// catch.
    static let newRowEdgeFraction: CGFloat = 0.25

    /// Return a new layout after inserting `widget` at `point`.
    ///
    /// The rules, in order:
    /// 1. Dropping onto an empty canvas creates the first row.
    /// 2. Otherwise, find the row band under `point.y`. Land in its top or
    ///    bottom quarter and a new row is inserted above or below it.
    /// 3. Land anywhere else in the band and the widget joins that row, at the
    ///    slot chosen by `point.x`.
    ///
    /// - Parameters:
    ///   - widget: the widget being dropped.
    ///   - point: the drop location, in the canvas' own coordinate space
    ///     (origin at its top-left). Points outside the canvas are clamped to
    ///     the nearest row, so a slightly overshot drop still lands sensibly.
    ///   - size: the size of the canvas the drop was made against.
    ///
    /// - Returns: a new layout containing `widget`.
    func inserting(_ widget: WidgetInstance, at point: CGPoint, in size: CGSize) -> WidgetLayout {
        guard !rows.isEmpty, size.width > 0, size.height > 0 else {
            return WidgetLayout(rows: [[widget]])
        }

        let rowHeight = size.height / CGFloat(rows.count)
        let rowIndex = clamp(Int(point.y / rowHeight), to: 0...(rows.count - 1))

        // Where the drop sits within its row band, from 0 (top) to 1 (bottom).
        let depthInRow = clamp((point.y - CGFloat(rowIndex) * rowHeight) / rowHeight, to: 0...1)

        var updated = rows
        switch depthInRow {
        case ..<Self.newRowEdgeFraction:
            updated.insert([widget], at: rowIndex)
        case (1 - Self.newRowEdgeFraction)...:
            updated.insert([widget], at: rowIndex + 1)
        default:
            let column = columnIndex(in: rows[rowIndex], forX: point.x, rowWidth: size.width)
            updated[rowIndex].insert(widget, at: column)
        }

        return WidgetLayout(rows: updated)
    }

    /// The slot in `row` that a drop at `x` belongs in: the number of widget
    /// midpoints the drop lies past. Dropping on the left half of the first
    /// widget gives 0, on its right half gives 1, and so on.
    private func columnIndex(in row: [WidgetInstance], forX x: CGFloat, rowWidth: CGFloat) -> Int {
        let columnWidth = rowWidth / CGFloat(row.count)
        return clamp(Int((x / columnWidth).rounded()), to: 0...row.count)
    }

    private func clamp<T: Comparable>(_ value: T, to range: ClosedRange<T>) -> T {
        min(max(value, range.lowerBound), range.upperBound)
    }
}
