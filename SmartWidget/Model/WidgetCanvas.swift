import CoreGraphics
import Foundation

// MARK: Question 1 — the data structure that represents a widget layout.

/// The canvas is a *tree of nodes*. A node is either a single widget, or a
/// container that divides its area evenly among its children — left to
/// right (a `row`) or top to bottom (a `column`).
///
/// For example:
///
///     WidgetCanvas(.row(.widget(a), .column(.widget(b), .widget(c))))
///
///     ┌─────────┬─────────┐
///     │         │    b    │
///     │    a    ├─────────┤
///     │         │    c    │
///     └─────────┴─────────┘
///
/// The tree alone determines every frame — there is nothing else to keep in
/// sync, so two layouts that draw the same canvas are `==`.
struct WidgetCanvas: Equatable {
    /// The whole canvas, or `nil` while nothing has been dropped on it yet.
    private(set) var root: Node?

    var isEmpty: Bool {
        root == nil
    }

    var widgets: [WidgetInstance] {
        root?.widgets ?? []
    }

    init(_ root: Node? = nil) {
        self.root = root
    }

    /// Which way to divide the area it is given.
    enum Axis: Equatable {
        case horizontal
        case vertical
    }

    ///Two node types: either a widget, or a container.
    indirect enum Node: Equatable {
        case widget(WidgetInstance)
        case container(axis: Axis, children: [Node])
    }
}

extension WidgetCanvas.Node {
    typealias Axis = WidgetCanvas.Axis

    /// Children side by side, sharing the width.
    static func row(_ children: Self...) -> Self {
        splitting(children, along: .horizontal)
    }

    /// Children stacked, sharing the height.
    static func column(_ children: Self...) -> Self {
        splitting(children, along: .vertical)
    }

    /// A container of `children` along `axis`.
    ///
    /// A child node that divides the same way as its parent is absorbed into it:
    /// `.row(a, b, c)` will be built instead of `.row(a, .row(b, c))`.
    static func splitting(_ children: [Self], along axis: Axis) -> Self {
        let flattened = children.flatMap { child -> [Self] in
            guard case let .container(childAxis, grandchildren) = child, childAxis == axis else { return [child] }
            return grandchildren
        }

        precondition(!flattened.isEmpty, "a container needs at least one child")
        return flattened.count == 1 ? flattened[0] : .container(axis: axis, children: flattened)
    }

    /// The widgets under this node, depth first.
    fileprivate var widgets: [WidgetInstance] {
        switch self {
        case let .widget(widget):
            return [widget]
        case let .container(_, children):
            return children.flatMap(\.widgets)
        }
    }
}

// MARK: - Question 2: computing each widget's frame

extension WidgetCanvas {
    /// A widget and the rectangle it occupies, in canvas coordinates.
    ///
    /// A placement is derived, never stored: it is rebuilt on every layout pass
    /// from the tree above, so a frame and the branch it came from cannot
    /// disagree.
    struct Placement: Identifiable, Equatable {
        var id: UUID { widget.id }
        
        let widget: WidgetInstance
        let frame: CGRect
    }

    /// Computes a frame for every widget in the layout.
    ///
    /// The whole rule is "divide evenly", applied at each level: a container hands
    /// each child an equal share of its own rectangle, and a widget fills the
    /// rectangle it is handed.
    ///
    /// - Parameters:
    ///   - size: the canvas to fill.
    ///   - spacing: the gutter between adjacent widgets.
    ///
    /// - Returns: one placement per widget, depth first. Empty if the layout is
    ///   empty, or if `spacing` leaves any widget no room.
    func placements(in size: CGSize, spacing: CGFloat = 0) -> [Placement] {
        guard let root else { return [] }

        return Self.placements(of: root, in: CGRect(origin: .zero, size: size), spacing: spacing) ?? []
    }

    /// Places `node` inside `rect`, or returns `nil` if it does not fit.
    private static func placements(of node: Node, in rect: CGRect, spacing: CGFloat) -> [Placement]? {
        switch node {
        case let .widget(widget):
            guard rect.width > 0, rect.height > 0 else { return nil }
            return [Placement(widget: widget, frame: rect)]
        case let .container(axis, children):
            guard let slices = rect.slices(along: axis, count: children.count, spacing: spacing) else { return nil }

            var placed: [Placement] = []
            for (child, slice) in zip(children, slices) {
                guard let childPlacements = placements(of: child, in: slice, spacing: spacing) else { return nil }
                placed += childPlacements
            }
            return placed
        }
    }
}

// MARK: - Question 3: resolving a drop

extension WidgetCanvas {
    /// The side of a widget that a drop landed nearest to.
    enum Edge: Equatable {
        case leading, trailing, top, bottom

        /// The axis a container must divide along.
        var axis: Axis {
            switch self {
            case .leading, .trailing:
                return .horizontal
            case .top, .bottom:
                return .vertical
            }
        }

        /// Whether the dropped widget goes before the one it landed on.
        var comesFirst: Bool {
            self == .leading || self == .top
        }

        /// The side of `rect` that `point` is nearest to.
        static func nearest(to point: CGPoint, in rect: CGRect) -> Edge {
            // The point's distance from the rect's leading / top edge in a fraction.
            let fromLeading = (point.x - rect.minX) / rect.width
            let fromTop = (point.y - rect.minY) / rect.height
            
            let distances: [(edge: Edge, fraction: CGFloat)] = [
                (.leading, fromLeading),
                (.trailing, 1 - fromLeading),
                (.top, fromTop),
                (.bottom, 1 - fromTop),
            ]
            let minDistance = distances.min { distance1, distance2 in
                distance1.fraction < distance2.fraction
            }

            return minDistance?.edge ?? .leading
        }
    }

    /// Return a new layout after inserting `widget` at `point`.
    ///
    /// The rules, in order:
    /// 1. Dropping onto an empty canvas makes the widget the whole canvas.
    /// 2. Otherwise, walk down to the widget under `point` and ask which of its
    ///    four sides the drop is nearest to.
    /// 3. The newcomer becomes that widget's sibling, on that side.
    ///
    /// Hit testing ignores the gutter that `placements(in:spacing:)` draws, so
    /// there is no dead zone between widgets to drop into.
    ///
    /// - Parameters:
    ///   - widget: the widget being dropped.
    ///   - point: the drop location, in the canvas' own coordinate space
    ///     (origin at its top-left). Points outside the canvas resolve against
    ///     the nearest widget, so a slightly overshot drop still lands sensibly.
    ///   - size: the size of the canvas the drop was made against.
    ///
    /// - Returns: a new layout containing `widget`.
    func inserting(_ widget: WidgetInstance, at point: CGPoint, in size: CGSize) -> WidgetCanvas {
        guard let root, size.width > 0, size.height > 0 else {
            return WidgetCanvas(.widget(widget))
        }

        let inserted = Self.inserting(
            widget,
            into: root,
            at: point,
            in: CGRect(origin: .zero, size: size)
        )

        return WidgetCanvas(inserted)
    }

    /// Returns `node`, occupying `rect`, with `widget` inserted at `point`.
    private static func inserting(_ widget: WidgetInstance, into node: Node, at point: CGPoint, in rect: CGRect) -> Node {
        switch node {
        case .widget:
            // The drop has reached the widget it landed on: share out its area.
            // If the container above divides this way too, `splitting` will absorb
            // the pair into it rather than nest, which is how a drop beside a
            // neighbour joins its row instead of subdividing it.
            let edge = Edge.nearest(to: point, in: rect)
            let pair: [Node] = edge.comesFirst ? [.widget(widget), node] : [node, .widget(widget)]

            return .splitting(pair, along: edge.axis)
        case let .container(axis, children):
            let index = childIndex(for: point, along: axis, in: rect, count: children.count)
            // Hit testing uses the ungapped slices, so `slices` cannot fail here.
            guard let slice = rect.slices(along: axis, count: children.count, spacing: 0)?[index] else { return node }

            var children = children
            children[index] = inserting(widget, into: children[index], at: point, in: slice)

            return .splitting(children, along: axis)
        }
    }

    /// The slice of `rect` that `point` falls in, clamped to the ends so that a
    /// drop past the canvas edge resolves against the outermost child.
    private static func childIndex(for point: CGPoint, along axis: Axis, in rect: CGRect, count: Int) -> Int {
        let offsetX = point.x - rect.minX
        let offsetY = point.y - rect.minY

        let (offset, extent) = axis == .horizontal
            ? (offsetX, rect.width)
            : (offsetY, rect.height)

        let childSize = extent / CGFloat(count)
        let index = Int(offset / childSize)

        return min(max(index, 0), count - 1)
    }
}

private extension CGRect {
    /// Divides the rectangle into slices along `axis`, with a
    /// `spacing` gutter between neighbours and none at the ends.
    ///
    /// - Returns: the slices in order, or `nil` if the gutters leave them no room.
    func slices(along axis: WidgetCanvas.Axis, count: Int, spacing: CGFloat) -> [CGRect]? {
        let total = axis == .horizontal ? width : height
        let extent = (total - spacing * CGFloat(count - 1)) / CGFloat(count)
        guard extent > 0 else { return nil }

        return (0..<count).map { index in
            let offset = (extent + spacing) * CGFloat(index)
            return axis == .horizontal
                ? CGRect(x: minX + offset, y: minY, width: extent, height: height)
                : CGRect(x: minX, y: minY + offset, width: width, height: extent)
        }
    }
}
