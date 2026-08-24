import CoreGraphics
import Testing
@testable import SmartWidget

/// Question 3 — `inserting(_:at:in:)` maps a drop coordinate onto a new layout,
/// without touching the layout it was called on.
///
/// The canvas is 200×200 throughout. A drop takes the side of the widget under
/// it that it is nearest to, measured as a fraction of that widget.
@Suite("WidgetCanvasLayout drop resolution")
struct CanvasLayoutDropTests {
    private let canvas = CGSize(width: 200, height: 200)

    private let a = WidgetInstance(color: .skyBlue)
    private let b = WidgetInstance(color: .hotPink)
    private let dropped = WidgetInstance(color: .vibrantOrange)

    // MARK: The empty canvas

    @Test("Dropping onto an empty canvas makes the widget the whole canvas")
    func dropOnEmptyCanvas() {
        let result = WidgetCanvasLayout().inserting(dropped, at: CGPoint(x: 130, y: 40), in: canvas)

        #expect(result == WidgetCanvasLayout(.widget(dropped)))
    }

    @Test("A canvas with no area still accepts the first widget")
    func dropOnZeroSizedCanvas() {
        let result = WidgetCanvasLayout().inserting(dropped, at: .zero, in: .zero)

        #expect(result == WidgetCanvasLayout(.widget(dropped)))
    }

    // MARK: Splitting the widget under the drop

    @Test("Dropping on a widget's leading side splits its area, newcomer first")
    func splitOnTheLeading() {
        let layout = WidgetCanvasLayout(.widget(a))
        let result = layout.inserting(dropped, at: CGPoint(x: 40, y: 100), in: canvas)

        #expect(result == WidgetCanvasLayout(.row(.widget(dropped), .widget(a))))
    }

    @Test("Dropping on a widget's trailing side splits its area, newcomer last")
    func splitOnTheTrailing() {
        let layout = WidgetCanvasLayout(.widget(a))
        let result = layout.inserting(dropped, at: CGPoint(x: 160, y: 100), in: canvas)

        #expect(result == WidgetCanvasLayout(.row(.widget(a), .widget(dropped))))
    }

    @Test("Dropping on a widget's top splits it into a column, newcomer first")
    func splitOnTheTop() {
        let layout = WidgetCanvasLayout(.widget(a))
        let result = layout.inserting(dropped, at: CGPoint(x: 100, y: 10), in: canvas)

        #expect(result == WidgetCanvasLayout(.column(.widget(dropped), .widget(a))))
    }

    @Test("Dropping on a widget's bottom splits it into a column, newcomer last")
    func splitOnTheBottom() {
        let layout = WidgetCanvasLayout(.widget(a))
        let result = layout.inserting(dropped, at: CGPoint(x: 100, y: 190), in: canvas)

        #expect(result == WidgetCanvasLayout(.column(.widget(a), .widget(dropped))))
    }

    /// The sides are measured in fractions of the widget, not in points, so a
    /// wide widget's leading edge is as easy to hit as a square one's.
    @Test("Which side is nearest is judged in fractions of the widget, not points")
    func nearestSideIsRelativeToTheWidget() {
        let wide = CGSize(width: 400, height: 100)
        let layout = WidgetCanvasLayout(.widget(a))

        // 60pt from the leading edge but only 40pt from the top: 15% against 40%.
        let result = layout.inserting(dropped, at: CGPoint(x: 60, y: 40), in: wide)

        #expect(result == WidgetCanvasLayout(.row(.widget(dropped), .widget(a))))
    }

    // MARK: Joining a container that already divides the right way

    @Test("Dropping between two widgets in a row adds a third between them")
    func joinRowInTheMiddle() {
        let layout = WidgetCanvasLayout(.row(.widget(a), .widget(b)))
        let result = layout.inserting(dropped, at: CGPoint(x: 100, y: 100), in: canvas)

        #expect(result == WidgetCanvasLayout(.row(.widget(a), .widget(dropped), .widget(b))))
    }

    @Test("Dropping between two stacked widgets adds a third between them")
    func joinColumnInTheMiddle() {
        let layout = WidgetCanvasLayout(.column(.widget(a), .widget(b)))
        // y = 90 is the bottom of a's band (0…100), so a gains a neighbour below.
        let result = layout.inserting(dropped, at: CGPoint(x: 100, y: 90), in: canvas)

        #expect(result == WidgetCanvasLayout(.column(.widget(a), .widget(dropped), .widget(b))))
    }

    // MARK: Nesting — the shape a flat list of rows could not express

    @Test("Dropping on the top of one widget in a row splits only that widget")
    func nestsWithoutDisturbingSiblings() {
        let layout = WidgetCanvasLayout(.row(.widget(a), .widget(b)))
        // x = 150 is the middle of b's half; y = 20 is near its top.
        let result = layout.inserting(dropped, at: CGPoint(x: 150, y: 20), in: canvas)

        #expect(result == WidgetCanvasLayout(
            .row(.widget(a), .column(.widget(dropped), .widget(b)))
        ))
        // a is untouched: still the full height of the left half.
        #expect(result.placements(in: canvas).first?.frame == CGRect(x: 0, y: 0, width: 100, height: 200))
    }

    @Test("Dropping beside a widget inside a column splits that band alone")
    func nestsInsideAColumn() {
        let layout = WidgetCanvasLayout(.row(.widget(a), .column(.widget(b), .widget(dropped))))
        let extra = WidgetInstance(color: .limeGreen)
        // x = 110 is the leading side of b, which occupies (100, 0, 100, 100).
        let result = layout.inserting(extra, at: CGPoint(x: 110, y: 50), in: canvas)

        #expect(result == WidgetCanvasLayout(
            .row(
                .widget(a),
                .column(.row(.widget(extra), .widget(b)), .widget(dropped))
            )
        ))
    }

    // MARK: Drops that land outside the canvas

    @Test("A drop above the canvas is clamped to the topmost widget")
    func dropAboveCanvas() {
        let layout = WidgetCanvasLayout(.column(.widget(a), .widget(b)))
        let result = layout.inserting(dropped, at: CGPoint(x: 100, y: -50), in: canvas)

        #expect(result == WidgetCanvasLayout(.column(.widget(dropped), .widget(a), .widget(b))))
    }

    @Test("A drop below the canvas is clamped to the bottommost widget")
    func dropBelowCanvas() {
        let layout = WidgetCanvasLayout(.column(.widget(a), .widget(b)))
        let result = layout.inserting(dropped, at: CGPoint(x: 100, y: 400), in: canvas)

        #expect(result == WidgetCanvasLayout(.column(.widget(a), .widget(b), .widget(dropped))))
    }

    @Test("A drop past the right edge joins the row at its end")
    func dropPastRightEdge() {
        let layout = WidgetCanvasLayout(.row(.widget(a), .widget(b)))
        let result = layout.inserting(dropped, at: CGPoint(x: 900, y: 100), in: canvas)

        #expect(result == WidgetCanvasLayout(.row(.widget(a), .widget(b), .widget(dropped))))
    }

    // MARK: The function has no side effects

    @Test("Inserting leaves the original layout untouched")
    func insertingIsPure() {
        let layout = WidgetCanvasLayout(.column(.widget(a), .widget(b)))
        let before = layout

        _ = layout.inserting(dropped, at: CGPoint(x: 100, y: 150), in: canvas)

        #expect(layout == before)
        #expect(layout.widgets.map(\.id) == [a.id, b.id])
    }

    @Test("The same drop always resolves the same way")
    func insertingIsDeterministic() {
        let layout = WidgetCanvasLayout(.row(.widget(a), .widget(b)))
        let point = CGPoint(x: 60, y: 100)

        #expect(layout.inserting(dropped, at: point, in: canvas) ==
                layout.inserting(dropped, at: point, in: canvas))
    }
}
