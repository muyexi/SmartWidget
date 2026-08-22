import CoreGraphics
import Testing
@testable import SmartWidget

/// Question 3 — `inserting(_:at:in:)` maps a drop coordinate onto a new layout,
/// without touching the layout it was called on.
///
/// The canvas is 200×200 throughout. With two rows each band is 100pt tall, so
/// its "new row" quarters are the first and last 25pt of the band and its
/// "join this row" middle is y = 25…75 within the band.
@Suite("WidgetLayout drop resolution")
struct WidgetLayoutDropTests {
    private let canvas = CGSize(width: 200, height: 200)

    private let a = WidgetInstance(color: .skyBlue)
    private let b = WidgetInstance(color: .hotPink)
    private let dropped = WidgetInstance(color: .vibrantOrange)

    /// The layout's shape, as colours, so failures read as a picture.
    private func shape(_ layout: WidgetLayout) -> [[WidgetInstance]] { layout.rows }

    // MARK: The empty canvas

    @Test("Dropping onto an empty canvas creates the first row")
    func dropOnEmptyCanvas() {
        let result = WidgetLayout().inserting(dropped, at: CGPoint(x: 130, y: 40), in: canvas)

        #expect(shape(result) == [[dropped]])
    }

    @Test("A canvas with no area still accepts the first widget")
    func dropOnZeroSizedCanvas() {
        let result = WidgetLayout().inserting(dropped, at: .zero, in: .zero)

        #expect(shape(result) == [[dropped]])
    }

    // MARK: Joining an existing row

    @Test("Dropping on the left half of the only widget puts the new one before it")
    func joinRowOnTheLeft() {
        let layout = WidgetLayout(rows: [[a]])
        let result = layout.inserting(dropped, at: CGPoint(x: 40, y: 100), in: canvas)

        #expect(shape(result) == [[dropped, a]])
    }

    @Test("Dropping on the right half of the only widget puts the new one after it")
    func joinRowOnTheRight() {
        let layout = WidgetLayout(rows: [[a]])
        let result = layout.inserting(dropped, at: CGPoint(x: 160, y: 100), in: canvas)

        #expect(shape(result) == [[a, dropped]])
    }

    @Test("Dropping on the boundary between two widgets adds the new one between them")
    func joinRowInTheMiddle() {
        let layout = WidgetLayout(rows: [[a, b]])
        let result = layout.inserting(dropped, at: CGPoint(x: 100, y: 100), in: canvas)

        #expect(shape(result) == [[a, dropped, b]])
    }

    // MARK: Starting a new row

    @Test("Dropping in the top quarter of a row starts a new row above it")
    func newRowAbove() {
        let layout = WidgetLayout(rows: [[a]])
        let result = layout.inserting(dropped, at: CGPoint(x: 100, y: 10), in: canvas)

        #expect(shape(result) == [[dropped], [a]])
    }

    @Test("Dropping in the bottom quarter of a row starts a new row below it")
    func newRowBelow() {
        let layout = WidgetLayout(rows: [[a]])
        let result = layout.inserting(dropped, at: CGPoint(x: 100, y: 190), in: canvas)

        #expect(shape(result) == [[a], [dropped]])
    }

    @Test("With two rows, dropping on the boundary between them starts a row in the middle")
    func newRowBetweenTwoRows() {
        let layout = WidgetLayout(rows: [[a], [b]])
        // y = 90 is the bottom quarter of the first band (0…100).
        let result = layout.inserting(dropped, at: CGPoint(x: 100, y: 90), in: canvas)

        #expect(shape(result) == [[a], [dropped], [b]])
    }

    @Test("With two rows, dropping on the lower band's middle joins the lower row")
    func joinTheSecondRow() {
        let layout = WidgetLayout(rows: [[a], [b]])
        // y = 150 is the middle of the second band (100…200); x = 150 is past b's midpoint.
        let result = layout.inserting(dropped, at: CGPoint(x: 150, y: 150), in: canvas)

        #expect(shape(result) == [[a], [b, dropped]])
    }

    // MARK: Drops that land outside the canvas

    @Test("A drop above the canvas is clamped to the first row")
    func dropAboveCanvas() {
        let layout = WidgetLayout(rows: [[a], [b]])
        let result = layout.inserting(dropped, at: CGPoint(x: 100, y: -50), in: canvas)

        #expect(shape(result) == [[dropped], [a], [b]])
    }

    @Test("A drop below the canvas is clamped to the last row")
    func dropBelowCanvas() {
        let layout = WidgetLayout(rows: [[a], [b]])
        let result = layout.inserting(dropped, at: CGPoint(x: 100, y: 400), in: canvas)

        #expect(shape(result) == [[a], [b], [dropped]])
    }

    @Test("A drop past the right edge joins the row at its end")
    func dropPastRightEdge() {
        let layout = WidgetLayout(rows: [[a, b]])
        let result = layout.inserting(dropped, at: CGPoint(x: 900, y: 100), in: canvas)

        #expect(shape(result) == [[a, b, dropped]])
    }

    // MARK: The function has no side effects

    @Test("Inserting leaves the original layout untouched")
    func insertingIsPure() {
        let layout = WidgetLayout(rows: [[a], [b]])
        let before = layout

        _ = layout.inserting(dropped, at: CGPoint(x: 100, y: 150), in: canvas)

        #expect(layout == before)
        #expect(shape(layout) == [[a], [b]])
    }

    @Test("The same drop always resolves the same way")
    func insertingIsDeterministic() {
        let layout = WidgetLayout(rows: [[a, b]])
        let point = CGPoint(x: 60, y: 100)

        #expect(layout.inserting(dropped, at: point, in: canvas) ==
                layout.inserting(dropped, at: point, in: canvas))
    }
}
